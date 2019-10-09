//
//  AYAdverseViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/17.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYAdverseViewController.h"
#import "UITextView+Placeholder.h" //uitextview 设置placehodle
@interface AYAdverseViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextView *adverseTextView;
@property (weak, nonatomic) IBOutlet UIButton *publicBtn;
@property (strong, nonatomic) UILabel *wordNumLable;//剩余字数lable

@end

@implementation AYAdverseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureData];
    // Do any additional setup after loading the view from its nib.
}

-(void)configureUI
{
    _adverseTextView.layer.cornerRadius = 5.0f;
    _emailTextfield.layer.cornerRadius = 5.0f;
    _adverseTextView.backgroundColor = RGB(244, 244, 244);
    _emailTextfield.backgroundColor= RGB(244, 244, 244);
    _publicBtn.layer.cornerRadius = 18.0f;
    [_publicBtn setTitle:AYLocalizedString(@"提交") forState:UIControlStateNormal];
    _publicBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_publicBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    LEWeakSelf(self)
    [_publicBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if ([AYUserManager isUserLogin])
        {
            [self uploadAdverse];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [self uploadAdverse];
            }];
        }
    }];
    _adverseTextView.delegate = self;
    self.wordNumLable = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth-30-150-15-5, 140-15-12, 150, 12)];
    self.wordNumLable.textColor= UIColorFromRGB(0x333333);
    self.wordNumLable.font = [UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE];
    [self.adverseTextView addSubview:_wordNumLable];
    self.wordNumLable.textAlignment = NSTextAlignmentRight;
    self.wordNumLable.text= @"1500";
    self.adverseTextView.layer.borderWidth = 1.0f;
    self.adverseTextView.layer.borderColor =UIColorFromRGB(0xf7f7f7).CGColor;
    
//    UIButton *faceBookBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE+1] textColor:UIColorFromRGB(0x333333) title:[NSString stringWithFormat:@"  %@",AYLocalizedString(@"联系FB")] image:LEImage(@"login_facebook")];
//    faceBookBtn.frame = CGRectMake((ScreenWidth-200)/2.0f, ScreenHeight-44-60-[AYUtitle al_safeAreaInset:self.view].bottom-STATUS_BAR_HEIGHT-[AYUtitle al_safeAreaInset:self.view].top-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0), 200, 50);
//    faceBookBtn.layer.borderWidth = 1.0f;
//    faceBookBtn.layer.cornerRadius = 25;
//    faceBookBtn.layer.borderColor = UIColorFromRGB(0x666666).CGColor;
//
//    [self.view addSubview:faceBookBtn];
//    LEWeakSelf(self)
//    [faceBookBtn addAction:^(UIButton *btn) {
//        LEStrongSelf(self)
//        [self evokeFacebook];
//    }];
}
-(void)configureData
{
    self.title = AYLocalizedString(@"意见反馈");
    _adverseTextView.placeholder = AYLocalizedString(@"请输入您宝贵的意见和建议！");

    _emailTextfield.placeholder = AYLocalizedString(@"请留下邮箱");
}
#pragma mark - private -
-(BOOL)isCanSendComment
{
    NSDate *beforeData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultWriteAdversiseTime];
    if (!beforeData) {
        return YES;
    }
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval time = [currentDate timeIntervalSinceDate:beforeData];//秒
    if(time<60)//半分钟发一次
    {
        occasionalHint(AYLocalizedString(@"操作太频繁"));
        return NO;
    }
    
    return YES;
}
-(void)evokeFacebook
{
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/1699295950216055"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL])
    {
        [[UIApplication sharedApplication] openURL:facebookURL];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com"]];
    }
}

#pragma mark - network -
-(void)uploadAdverse
{
    if(self.adverseTextView.text.length<=0)
    {
        occasionalHint(AYLocalizedString(@"意见不能为空"));
        return;
    }
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    if(![pre evaluateWithObject:self.emailTextfield.text])
    {
        occasionalHint(AYLocalizedString(@"请输入正确的邮箱"));
        return;
    }//此处返回的是BOOL类型,YES or NO;
    [self showHUD];
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
            [params addValue:self.adverseTextView.text forKey:@"content"]; //删除的小说id
            [params addValue:self.emailTextfield.text forKey:@"email"]; //删除的小说id

        }];
    [ZWNetwork post:@"HTTP_Post_FeedBack" parameters:para success:^(id record)
     {
         [self hideHUD];
         [self.navigationController popViewControllerAnimated:YES];
         [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultWriteAdversiseTime];
     } failure:^(LEServiceError type, NSError *error) {
         [self hideHUD];
         occasionalHint([error localizedDescription]);
     }];
}
#pragma mark - uitextviewdelegate -
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 1000)
    {
        textView.text = [textView.text substringToIndex:1000];
        //这里为动态显示已输入字数，可按情况添加
        self.wordNumLable.text = @"0";
    }
    else
    {
        //这里为动态显示已输入字数，可按情况添加
        self.wordNumLable.text = [NSString stringWithFormat:@"%lu",1000-textView.text.length];
    }
    
}

#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYAdverseViewController controller];
}
@end
