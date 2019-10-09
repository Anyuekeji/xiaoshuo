//
//  AYFriendChargeViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/18.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYFriendChargeViewController.h"
#import "AYChargeSelectView.h"

@interface AYFriendChargeViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *friendImagView;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UITextField *friendIDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *chargeMoneyTextfield;
@property (weak, nonatomic) IBOutlet UIView *friendIDView;
@property (weak, nonatomic) IBOutlet UIView *friendChargeMondyView;
@property (weak, nonatomic) IBOutlet UIButton *chargeMoney;
@property (assign, nonatomic)  BOOL charge; //是否是帮好友充值界面
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chargeBtnTopConstraint;
@property (assign, nonatomic)  NSInteger chargeUserId;
@property (weak, nonatomic) IBOutlet UILabel *rewardLable;
@property (weak, nonatomic) IBOutlet UILabel *stepLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContraints;

@end

@implementation AYFriendChargeViewController
-(instancetype)initWithPara:(BOOL)charge
{
    self = [super init];
    if (self) {
        self.charge = charge;
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeHelpFriendChargeInfo];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureUI];
    [self configureNotification];
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
-(void)configureUI
{
    _friendImagView.image = LEImage(@"me_defalut_icon");
    _friendImagView.clipsToBounds = YES;
    _friendImagView.layer.cornerRadius = _friendImagView.width/2.0f;
    _friendIDView.layer.borderColor= [UIColor redColor].CGColor;
    _friendIDView.layer.borderWidth =1.0f;
    _friendIDView.layer.cornerRadius= 27.5f;
    

    
    _friendChargeMondyView.layer.borderColor= [UIColor redColor].CGColor;
    _friendChargeMondyView.layer.borderWidth =1.0f;
    _friendChargeMondyView.layer.cornerRadius= 27.5f;
    
    [_chargeMoney setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chargeMoney setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _chargeMoney.titleLabel.font = [UIFont systemFontOfSize:18];
    _chargeMoney.layer.cornerRadius = 21.3f;
    _chargeMoney.clipsToBounds = YES;
    
    //_friendIDTextfield.delegate = self;
    _friendIDTextfield.keyboardType = UIKeyboardTypeNumberPad;
  //  _chargeMoneyTextfield.delegate = self;
    _friendIDTextfield.textAlignment = NSTextAlignmentCenter;
    _chargeMoneyTextfield.textAlignment = NSTextAlignmentCenter;

    [self changeTextFieldPlaceHoder:_friendIDTextfield text:AYLocalizedString(@"好友ID号")];
    [self changeTextFieldPlaceHoder:_chargeMoneyTextfield text:AYLocalizedString(@"金币数")];

    LEWeakSelf(self)
    [self.chargeMoney addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if (self.chargeUserId>0)
        {
            if (self.chargeUserId == [[AYUserManager userId] integerValue]) {
                occasionalHint(AYLocalizedString(@"不能给自己充值，请输入好友id"));
                return ;
            }
            [[NSUserDefaults standardUserDefaults] setObject:@(self.chargeUserId) forKey:kUserDefaultFriendChargeId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [AYChargeSelectContainView showChargeSelectInView:self.view compete:^{
                occasionalHint(AYLocalizedString(@"帮好友充值成功"));
                [AYUtitle updateUserCoin:^{
                    
                }];
            }];
        }
        else
        {
            occasionalHint(AYLocalizedString(@"请输入正确的好友id"));
        }
    }];
    
    if (_charge)
    {
        self.friendChargeMondyView.hidden = YES;
        self.chargeBtnTopConstraint.constant = -40;
        [_chargeMoney setTitle:AYLocalizedString(@"去充值") forState:UIControlStateNormal];
        _rewardLable.text = AYLocalizedString(@"奖励：每次替好友充值成功，奖励金币的20%");
        _stepLable.text = AYLocalizedString(@"充值步骤：\n步骤一：输入好友的id \n步骤二： 确认好友id和名字 \n步骤三：点击去充值，帮助你的好友完成充值");
        
        CGFloat rewardLableHeight = LETextHeight(self.rewardLable.text, self.rewardLable.font, self.rewardLable.width);
        CGFloat stepLableHeight = LETextHeight(self.stepLable.text, self.stepLable.font, self.stepLable.width);
        CGFloat dis = (ScreenHeight-self.chargeMoney.origin.y-self.chargeMoney.height-stepLableHeight-rewardLableHeight)/2.0f;
        self.bottomContraints.constant = dis;


    }

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:LEImage(@"btn_back_nav") forState:UIControlStateNormal];
    backBtn.backgroundColor = UIColorFromRGBA(0xffffff, 0.5f);
    backBtn.frame = CGRectMake(15, 30+(_ZWIsIPhoneXSeries()?20:0), 36, 36);
    backBtn.layer.cornerRadius = 18.0f;
    [self.view addSubview:backBtn];
    [backBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
    

    
}
-(void)configureNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}
-(void)changeTextFieldPlaceHoder:(UITextField*)textField text:(NSString*)holderText
{
  //  NSString *holderText = AYLocalizedString(@"好友ID号");
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName
                        value:UIColorFromRGB(0xcccccc)
                        range:NSMakeRange(0, holderText.length)];
    [placeholder addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:20]
                        range:NSMakeRange(0, holderText.length)];
    textField.attributedPlaceholder = placeholder;
}

#pragma mark - event handle -

-(void)handleTextFieldChanged:(UITextField*)textField
{
    if (self.friendIDTextfield.text.length<=0) {
        self.friendName.text = @"";
        self.friendImagView.image = LEImage(@"me_defalut_icon");
        
    }
    self.chargeUserId = -1;
    //HTTP_Post_UserIno
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@([self.friendIDTextfield.text integerValue]) forKey:@"users_id"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_UserIno" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *recordArray = (NSArray*)record;
             if (recordArray.count>0)
             {
                 NSDictionary *dic = recordArray[0];
                 self.chargeUserId =dic[@"id"]?[dic[@"id"] integerValue]:0;
                 self.friendName.text =[dic[@"nickname"] isValid]?dic[@"nickname"]:@"";
                 if (![dic[@"avater"] isKindOfClass:NSNull.class]) {
                                LEImageSet(self.friendImagView, dic[@"avater"], @"me_defalut_icon");
                 }
      
             }
         }
     } failure:^(LEServiceError type, NSError *error) {
         
     }];
}
#pragma mark - private -
-(void)removeHelpFriendChargeInfo
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFriendChargeId]) {
        //清除帮好友充值id 标记
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultFriendChargeId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if ([parameters isKindOfClass:NSNumber.class]) {
        return YES;

    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYFriendChargeViewController alloc] initWithPara:[parameters boolValue]];
}
@end
