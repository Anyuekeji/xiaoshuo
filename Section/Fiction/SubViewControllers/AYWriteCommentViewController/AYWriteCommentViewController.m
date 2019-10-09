//
//  AYWriteCommentViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYWriteCommentViewController.h"
#import "UITextView+Placeholder.h" //uitextview 设置placehodle

@interface AYWriteCommentViewController ()<UITextViewDelegate>
@property (assign, nonatomic) BOOL  cartoon;
@property (strong, nonatomic) UITextView *commentContentView;
@property (strong, nonatomic) NSString *bookID;
@property (assign, nonatomic) NSInteger level;
@property (strong, nonatomic) UIButton *publicBtn;//发送按钮

@property (strong, nonatomic) UILabel *wordNumLable;//剩余字数lable
@end

@implementation AYWriteCommentViewController
-(instancetype)initWithPara:(NSDictionary*)paras
{
    self = [super init];
    if (self) {
        self.cartoon = [paras[@"cartoon"] boolValue];
        self.bookID = paras[@"bookId"];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurUi];
    [self configureData];
}
-(void)configureData
{
    self.title = AYLocalizedString(@"写评论");
    self.level =5;
}
-(void)configurUi
{
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *commentLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:RGB(102, 102, 102) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    commentLable.translatesAutoresizingMaskIntoConstraints = NO;
    commentLable.text = AYLocalizedString(@"评论");
    [self.view addSubview:commentLable];
    
    UILabel *commentTipLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE] textColor:RGB(102, 102, 102) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    commentTipLable.translatesAutoresizingMaskIntoConstraints = NO;
    commentTipLable.text = [NSString stringWithFormat:@"(%@)",AYLocalizedString(@"必填")];
    [self.view addSubview:commentTipLable];
    
    UIButton *publicBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:[UIColor whiteColor] title:AYLocalizedString(@"发表") image:nil];
    publicBtn.backgroundColor = RGB(250, 85, 108);
    publicBtn.layer.cornerRadius = 18;
    publicBtn.clipsToBounds = YES;
    [self.view addSubview:publicBtn];
    publicBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.publicBtn = publicBtn;
    LEWeakSelf(self)

    [publicBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if ([AYUserManager isUserLogin]) {
            [self uploadComment];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [self uploadComment];
            }];
        }
    }];

    UIView *levelView = [UIView new];
    levelView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:levelView];
    for (int i=0; i<5; i++)
    {
        UIImageView* starView = [[UIImageView alloc] initWithImage:LEImage(@"stat_light")];
        starView.frame = CGRectMake(i*(18+10), 0, 18, 18);
        starView.tag = 13264+i;
        [levelView addSubview:starView];
       [starView setEnlargeEdgeWithTop:8 right:5 bottom:8 left:5];
        [starView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            LEStrongSelf(self)
            UIImageView *clickeView =(UIImageView*)ges.view;
            if (clickeView) {
                int clickeIndex = (int)clickeView.tag-13264;
                self.level = clickeIndex+1;
                if (clickeIndex>=0)
                {
                    static BOOL firstClicked = NO;
                    [levelView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        UIImageView *statImageView = (UIImageView*)obj;
                        statImageView.image =LEImage(@"stat_shadow");
                    }];
                    if (clickeIndex ==0)
                    {
                            UIImageView *starImageView = [levelView viewWithTag:13264+0];
//                        if (firstClicked) {
//                           // starImageView.image =LEImage(@"stat_shadow");
//                        }
//                        else
//                        {
//                            starImageView.image =LEImage(@"stat_light");
//                        }
                        starImageView.image =LEImage(@"stat_light");

                        firstClicked = !firstClicked;
                    }
                    else
                    {
                        for (int j = clickeIndex; j>=0; j--)
                        {
                            UIImageView *starImageView = [levelView viewWithTag:13264+j];
//                            if (j ==0)
//                            {
//                                firstClicked = YES;
//                            }
                            if (starImageView) {
                                starImageView.image =LEImage(@"stat_light");
                            }
                        }
                    }
           
                }
            }
        }];
    }
    UITextView *commentContentView = [UITextView new];
    commentContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:commentContentView];
    commentContentView.font = [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
    commentContentView.textColor = RGB(51, 51, 51);
    commentContentView.placeholder = AYLocalizedString(@"请打分并说明您的看法...（1000字以内）");
    commentContentView.placeholderColor = RGB(153, 153, 153);
    commentContentView.backgroundColor = RGB(243, 243, 243);
    self.commentContentView = commentContentView;
    self.commentContentView.delegate = self;
    NSDictionary * _binds = @{@"commentContentView":commentContentView, @"levelView":levelView, @"commentTipLable":commentTipLable, @"commentLable":commentLable, @"publicBtn":publicBtn};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[commentLable]-15-[levelView(==130@999)]-5-[commentTipLable]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_binds]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[commentContentView]-15-|" options:0 metrics:nil views:_binds]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[publicBtn]-15-|" options:0 metrics:nil views:_binds]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:levelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:20.0f]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[commentLable]-15-[commentContentView(==140@999)]-(20@999)-[publicBtn(==36@999)]-(>=50@999)-|" options:0 metrics:nil views:_binds]];
    
    self.wordNumLable = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth-30-150-15-5, 140-15-12, 150, 12)];
    self.wordNumLable.textColor= UIColorFromRGB(0x333333);
    self.wordNumLable.font = [UIFont systemFontOfSize:12];
    [self.commentContentView addSubview:_wordNumLable];
    self.wordNumLable.textAlignment = NSTextAlignmentRight;
    self.wordNumLable.text= @"1000";

}
-(void)uploadComment
{
    if (![self isCanSendComment]) {
        return;
    }
    
    if (self.commentContentView.text.length<=0) {
        occasionalHint(AYLocalizedString(@"评论内容不能为空"));
        return;
    }
    [self showHUD];
    self.publicBtn.enabled = NO;
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [self hideHUD];
        [params addValue:@(self.level) forKey:@"star"];
        [params addValue:self.commentContentView.text forKey:@"content"];
        if (self.cartoon) {
            [params addValue:self.bookID forKey:@"cartoon_id"];
        }
        else
        {
            [params addValue:self.bookID  forKey:@"book_id"];
        }

    }];
    [ZWNetwork post:@"HTTP_Post_Upload_Comment" parameters:para success:^(id record)
     {
         [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDetailNeedRefreshEvents object:nil];
         [self hideHUD];
         [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultWriteCommentTime];
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             self.publicBtn.enabled = YES;
         });
   
     } failure:^(LEServiceError type, NSError *error) {
         [self hideHUD];
         occasionalHint([error localizedDescription]);
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             self.publicBtn.enabled = YES;
         });
     }];
}
#pragma mark - private -
-(BOOL)isCanSendComment
{
    NSDate *beforeData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultWriteCommentTime];
    if (!beforeData) {
        return YES;
    }
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval time = [currentDate timeIntervalSinceDate:beforeData];//秒
    if(time<30)//半分钟发一次
    {
        occasionalHint(AYLocalizedString(@"操作太频繁"));
        return NO;
    }
    
    return YES;
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
    if (parameters && [parameters isKindOfClass:NSDictionary.class]) {
        return YES;
    }
    return NO;}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYWriteCommentViewController alloc] initWithPara:parameters];
}


@end
