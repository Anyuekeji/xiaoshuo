//
//  AYLogiinViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYLogiinViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "UIButton+BottomLine.h" //底部横线
#import "AYMeModel.h"
#import "AYNavigationController.h"
#import "LERMLRealm.h"
#import "ZWDeviceSupport.h"
#import "AYSignManager.h"

@interface AYLogiinViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readMeTopConstrains;//readme顶部约束
@property (weak, nonatomic) IBOutlet UIView *loginFacebook;
@property (weak, nonatomic) IBOutlet UIView *loginTwitter;
@property (weak, nonatomic) IBOutlet UIView *loginZalo;
@property (weak, nonatomic) IBOutlet UIView *loginGoogle;
@property (weak, nonatomic) IBOutlet UILabel *facebookLable;
@property (weak, nonatomic) IBOutlet UILabel *zaloLable;
@property (weak, nonatomic) IBOutlet UILabel *twitterLable;
@property (weak, nonatomic) IBOutlet UILabel *googelLable;
@property (copy, nonatomic) void(^callBack)(id obj);
@property (assign, nonatomic)  UIStatusBarStyle currentBarStyle;
@property (weak, nonatomic) IBOutlet UILabel *appNameLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookBottomConstrains;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ZaloBottomContrains;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zaloLeft;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTextField;  //邀请码
@property (weak, nonatomic) IBOutlet UIView *IDContainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coypRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *coypRightLable;
@end

@implementation AYLogiinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUi];
    [self configureData];
    // Do any additional setup after loading the view from its nib.
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return _currentBarStyle;
}
-(void)dealloc
{

}
#pragma mark - configure -
-(void)configureUi
{
    _coypRightLable.text =  [NSString stringWithFormat:@"Copyright © 2019 %@",[AYUtitle getAppName]];
    _inviteCodeTextField.placeholder = AYLocalizedString(@"请输入好友ID");
    _logoTopConstraint.constant = (ScreenHeight -160-120-40-30)/2.0f;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  //  self.view.backgroundColor = UIColorFromRGB(0xff2455);
    _loginGoogle.layer.cornerRadius = _loginGoogle.height/2.0f;
    _loginGoogle.layer.borderWidth = 1.0f;
    _loginGoogle.layer.borderColor = UIColorFromRGB(0xbfbfbf).CGColor;
    _loginGoogle.clipsToBounds = YES;

    _loginZalo.layer.cornerRadius = _loginZalo.height/2.0f;
    _loginZalo.layer.borderWidth = 1.0f;
    _loginZalo.layer.borderColor = UIColorFromRGB(0xbfbfbf).CGColor;
    _loginZalo.clipsToBounds = YES;
    _loginTwitter.layer.cornerRadius = _loginTwitter.height/2.0f;
    _loginFacebook.layer.cornerRadius = _loginFacebook.height/2.0f;
    _loginFacebook.layer.borderWidth = 1.0f;
    _loginFacebook.layer.borderColor = UIColorFromRGB(0xbfbfbf).CGColor;
    _loginFacebook.clipsToBounds = YES;
//    _vistorLogin.hidden = YES;
//    [_vistorLogin  setBottomLineStyleWithColor:[UIColor whiteColor]];
    _facebookLable.text = [NSString stringWithFormat:@"%@ %@",AYLocalizedString(@"Sign in with"),@"Facebook"];
    _twitterLable.text = [NSString stringWithFormat:@"%@ %@",AYLocalizedString(@"Sign in with"),@"Twitter"];
    _zaloLable.text = [NSString stringWithFormat:@"%@ %@",AYLocalizedString(@"Sign in with"),@"Line"];
    _googelLable.text = [NSString stringWithFormat:@"%@ %@",AYLocalizedString(@"Sign in with"),@"Google"];
    _appNameLable.text = AYLocalizedString(@"越南小说");
    //暂时去掉twitter ,下次加上就注销掉下面的代码
   _loginTwitter.hidden = YES;
  //  _ZaloBottomContrains.constant-=_loginTwitter.height+7;
    if (isIPhone4 || isIPhone5) {
        _facebookBottomConstrains.constant -=_loginTwitter.height+5+24;
        _googleBottomConstraint.constant -=_loginTwitter.height+6+24;
        _ZaloBottomContrains.constant-= 24;
    }
    else
    {
        _facebookBottomConstrains.constant -=_loginTwitter.height+5;
        _googleBottomConstraint.constant -=_loginTwitter.height+6;
    }

    //最新间距
    CGFloat faceBookTextWidth = LETextWidth(_facebookLable.text, _facebookLable.font);
    CGFloat max_dis = (ScreenWidth-66 - faceBookTextWidth - 20)/2.0f-12;
    self.zaloLeft.constant = max_dis;
    self.facebookLeft.constant = max_dis;
    self.twitterLeft.constant = max_dis;
    self.googleLeft.constant = max_dis;
  //   NSString *vistorSwitch =  [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultVistorModeSwitch];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:LEImage(@"btn_back_nav") forState:UIControlStateNormal];
    backBtn.backgroundColor = UIColorFromRGBA(0xF7F7F7, 0.5f);
    backBtn.frame = CGRectMake(15, 30+(_ZWIsIPhoneXSeries()?20:0), 36, 36);
    backBtn.layer.cornerRadius = 18.0f;
    [self.view addSubview:backBtn];
    LEWeakSelf(self)
    [backBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.IDContainView.layer.borderWidth = 1.0f;
    self.IDContainView.layer.borderColor = UIColorFromRGB(0xff6666).CGColor;
    self.IDContainView.layer.cornerRadius = 18.0f;
    self.IDContainView.clipsToBounds = YES;
    
    self.coypRightConstraint.constant = (_ZWIsIPhoneXSeries()?30:15);
    
//    UIButton *vistorLogin = [UIButton buttonWithType:UIButtonTypeCustom];
//    [vistorLogin setTitle:@"vistor login" forState:UIControlStateNormal];
//    [vistorLogin setBottomLineStyleWithColor:[UIColor whiteColor]];
//    vistorLogin.frame  = CGRectMake((ScreenWidth-100)/2.0f, ScreenHeight-[AYUtitle al_safeAreaInset:self.view].bottom-STATUS_BAR_HEIGHT-30, 100, 30);
//    [self.view addSubview:vistorLogin];
//
//        [vistorLogin addAction:^(UIButton *btn) {
//            LEStrongSelf(self)
//            AYMeModel *model = [AYMeModel new];
//            model.myId = [ZWDeviceSupport deviceUUID];
//          //  model.myNickName=[ZWDeviceSupport deviceUUID];
//            model.myNickName=[ZWDeviceSupport deviceUUID];
//            model.myToken =@"";
//            model.myHeadImage=@"";
//            model.gender  = @(1);
//            model.login_type = @(5);
//            [self uploadUserInfo:model];
//        }];
}
-(void)configureData
{
    LEWeakSelf(self)
    //谷歌登录
    [_loginGoogle addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        [self showHUD];

        [ShareSDK getUserInfo:SSDKPlatformTypeGooglePlus
               onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
         {
             [self hideHUD];

             LEStrongSelf(self)
             if (state == SSDKResponseStateSuccess)
             {
                 AYLog(@"uid=%@",user.uid);
            AYLog(@"nickname=%@",user.nickname);
                 AYLog(@"icon=%@",user.icon);
                 
                 AYMeModel *model = [AYMeModel new];
                 model.myId = user.uid;
                 model.myToken =user.credential.token;
                 model.myNickName=user.nickname;
                 model.myHeadImage=user.icon;
                 model.expireTime = @(user.credential.expired);
                 model.gender = @(user.gender);
                 model.login_type = @(2);

                 [self uploadUserInfo:model];
   
             }
             else
             {
                 NSLog(@"%@",error);
                 occasionalHint([error localizedDescription]);

             }
         }];
    }];
    //facebook登录
    [_loginFacebook addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        [self showHUD];

        [ShareSDK getUserInfo:SSDKPlatformTypeFacebook
               onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
         {
             [self hideHUD];
             LEStrongSelf(self)
             if (state == SSDKResponseStateSuccess)
             {
                 AYLog(@"uid=%@",user.uid);
             AYLog(@"nickname=%@",user.nickname);
                 AYLog(@"icon=%@",user.icon);
                 
                 AYMeModel *model = [AYMeModel new];
                 model.myId = user.uid;
                 model.myToken =user.credential.token;
                 model.myNickName=user.nickname;
                 model.myHeadImage=user.icon;
                 model.gender = @(user.gender);
                 model.login_type = @(1);

                 [self uploadUserInfo:model];
             }
             else
             {
                 NSLog(@"%@",error);
                 occasionalHint([error localizedDescription]);
             }
         }];
    }];
    //line登录
    [_loginZalo addTapGesutureRecognizer:^(UITapGestureRecognizer *ges)
     {
         LEStrongSelf(self)
         [self getLineInfo];

    }];

}
#pragma mark - network -
-(void)uploadUserInfo:(AYMeModel*)useModel
{
    [self showHUD];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
            [params addValue:[useModel.myId stringValue] forKey:@"uid"];
            [params addValue:useModel.myToken  forKey:@"token"];
            [params addValue:useModel.myNickName  forKey:@"nickname"];
            [params addValue:useModel.myHeadImage  forKey:@"icon"];
           // [params addValue:useModel.expireTime  forKey:@"expired"];
            [params addValue:useModel.gender?useModel.gender:@(1)  forKey:@"sex"];
            [params addValue:useModel.login_type  forKey:@"login_type"];
            [params addValue:@(0)  forKey:@"channel_id"];
            [params addValue:@(0)  forKey:@"plat_id"];
            [params addValue:self.inviteCodeTextField.text  forKey:@"invite_code"];
        
            //[params addValue:[ZWDeviceSupport ipAddress]  forKey:@"ip"];
//           [params addValue:[ZWDeviceSupport deviceUUID]
//                             forKey:@"deviceToken"];
        }];
        [ZWNetwork post:@"HTTP_Post_Upload_Logininfo" parameters:para success:^(id record)
         {
            [self hideHUD];
             if (record && [record isKindOfClass:NSDictionary.class]) {
                 NSDictionary *userDic =record[@"user"];
                 //去掉后面的多位小数
                 CGFloat coinNumFloat =[userDic[@"remainder"] floatValue];
                 useModel.coinNum =[NSString stringWithFormat:@"%.1f",coinNumFloat];
                 useModel.myToken =userDic[@"token"];
                 useModel.myId = [userDic[@"id"] stringValue];
                 [AYUserManager setUserItemByItem:useModel];
                 //发送登录成功通知
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess object:nil];
                 [LERMLRealm switchRealm];
                 [[AYGlobleConfig shared] updateTaskStatus:nil failure:nil];
                 //更新签到数据
                 [[AYSignManager shared] loadUserSignNumDay:^{
                     
                 } failure:^(NSString * _Nonnull errorString) {
                     
                 }];
                 if ([[AYUtitle getAppDelegate].window.rootViewController isKindOfClass:AYLogiinViewController.class]) {
                     [[AYUtitle getAppDelegate] changeToLoginOrMainViewController:NO];
                 }
                 else
                 {
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 if (self.callBack) {
                     self.callBack(@(YES));
                 }
             }
         } failure:^(LEServiceError type, NSError *error) {
             [self hideHUD];
             occasionalHint([error localizedDescription]);

         }];
    });
}
-(void)getLineInfo
{
    [self showHUD];
    [ShareSDK getUserInfo:SSDKPlatformTypeLine
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               [self hideHUD];
               switch (state) {
                   case SSDKResponseStateSuccess:
                   {
                       AYLog(@"uid=%@",user.uid);
                       AYLog(@"nickname=%@",user.nickname);
                       AYLog(@"icon=%@",user.icon);
                       
                       AYMeModel *model = [AYMeModel new];
                       model.myId = user.uid;
                       if(!model.myId)
                       {
                           model.myId = user.credential.uid;
                       }
                       model.myToken =user.credential.token;
                       model.myNickName=user.nickname;
                       model.myHeadImage=user.icon;
                       model.expireTime = @(user.credential.expired);
                       model.gender = @(user.gender);
                       model.login_type = @(3);
                       
                       [self uploadUserInfo:model];
                       break;
                   }
                   case SSDKResponseStateFail:
                   {
                       AYLog(@"get line userinfo faild: %@",[error localizedDescription]);
                       
                       break;
                   }
                       break;
                   case SSDKResponseStateCancel:
                   {
                       
                       break;
                   }
                   default:
                       break;
               }
           }];
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYLogiinViewController controller];
}
+ (void) eventSetCallBack:(void(^)(id obj)) block controller:(UIViewController*)controller;
{
    if ([controller isKindOfClass:[AYLogiinViewController class]]){
        AYLogiinViewController *viewController = (AYLogiinViewController*)controller;
        viewController.callBack= block;
    }
}
@end
