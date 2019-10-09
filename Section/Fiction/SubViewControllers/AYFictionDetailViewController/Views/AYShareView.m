//
//  AYShareView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYShareView.h"
#import "LEItemView.h" //上面图片下面名字的视图
#import <ShareSDK/ShareSDK.h>
#import "AYNavigationController.h"
#import "NSString+PJR.h"
#import "AYRewardView.h"

@interface AYShareView()
//回调
@end


@implementation AYShareView

+(void)showShareViewInView:(UIView*)parentView shareParams:(NSMutableDictionary*) shareParams
{
    if(!parentView)
    {
        parentView = [AYUtitle getAppDelegate].window;
    }
    UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
    [shaodowView setBackgroundColor:[UIColor blackColor]];
    shaodowView.alpha=0;
    [parentView addSubview:shaodowView];
    
    AYShareView* shareView = [[AYShareView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 40+80+15) shareParams:shareParams];
    shareView.tag = SHAREVIEW_TAG;
    [parentView addSubview:shareView];
    LEWeakSelf(shareView)
    LEWeakSelf(shaodowView)

    [shaodowView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(shareView)
        LEStrongSelf(shaodowView)

        [UIView animateWithDuration:0.3 animations:^{
            shaodowView.alpha = 0;
            shareView.top = ScreenHeight;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [shareView removeFromSuperview];
            }
        }];
    }];
    shareView.ShareViewAction = ^{
        LEStrongSelf(shareView)
        [UIView animateWithDuration:0.3 animations:^{
            shaodowView.alpha = 0;
            shareView.top = ScreenHeight;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [shareView removeFromSuperview];
            }
        }];
    };
    [UIView animateWithDuration:0.3f animations:^{
        shaodowView.alpha = 0.5f;
        shareView.top = parentView.height-shareView.height;
    }];
}
-(instancetype)initWithFrame:(CGRect)frame shareParams:(NSMutableDictionary*) shareParams
{
    self = [super initWithFrame:frame];
    if (self) {
        self.shareParas = shareParams;
        [self configureUI];
    }
    return self;
}
-(void)dealloc
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
-(void)configureUI
{
    self.backgroundColor = [UIColor whiteColor];
    UILabel *shareLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    shareLable.frame = CGRectMake(0, 10, ScreenWidth, 16);
    shareLable.text = AYLocalizedString(@"分享");
    [self addSubview:shareLable];
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = UIColorFromRGB(0xeaeaea).CGColor;
    lineLayer.frame =CGRectMake(0, 40, ScreenWidth, 1.0f);
    [self.layer addSublayer:lineLayer];
    
    CGFloat itemHeight =80;
    CGFloat itemWidth = ScreenWidth/3.0f;
    NSArray *itemArray = @[@"Facebook",@"Line",/*@"Twitter", @"Google",@"Gmail",*/AYLocalizedString(@"Copy Link")];
    NSArray *itemImageArray = @[@"login_facebook",@"login_line",/*@"login_twitter", @"login_google",@"login_gmail",*/@"login_copylink"];
    LEWeakSelf(self)
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LEItemView *itemView = [[LEItemView alloc] initWithTitle:obj icon:itemImageArray[idx] isBigMode:NO numInOneLine:3];
        itemView.frame = CGRectMake((idx%3)*itemWidth,41+idx/3*(itemHeight), itemWidth, itemHeight);
        [self addSubview:itemView];
        itemView.tag = 16353+idx;
        [itemView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            LEStrongSelf(self)
            [self shareToPlatforWithType:ges.view.tag-16353+1];
        }];
    }];
}
-(void)shareToPlatforWithType:(AYSharePlatformType) platformType
{
    LEWeakSelf(self)
    switch (platformType) {
        case AYSharePlatformTypeFacebook:
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            //进行分享
            [ShareSDK share:SSDKPlatformTypeFacebook //传入分享的平台类型
                 parameters:[self createShareParasWithPlatType:platformType]
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
            {
                LEStrongSelf(self)
                [self showShowResult:state error:error];
            }];
        }
            break;
        case AYSharePlatformTypeGoogle:
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [ShareSDK share:SSDKPlatformTypeGooglePlus //传入分享的平台类型
                 parameters:[self createShareParasWithPlatType:platformType]
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
             {
                 LEStrongSelf(self)
                    [self showShowResult:state error:error];
             }];
        }
            break;
        case AYSharePlatformTypeTwitter:
        {
            [ShareSDK share:SSDKPlatformTypeTwitter //传入分享的平台类型
                 parameters:[self createShareParasWithPlatType:platformType]
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
             {
                 LEStrongSelf(self)

                 [self showShowResult:state error:error];
             }];
        }
            break;
        case AYSharePlatformTypeLine: //line
        {
            [ShareSDK share:SSDKPlatformTypeLine //传入分享的平台类型
                 parameters:[self createShareParasWithPlatType:platformType]
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
             {
                 LEStrongSelf(self)
                 
                 [self showShowResult:state error:error];
             }];
        }
            break;
        case AYSharePlatformTypeGmail:
        {
            NSString *customURL = [NSString stringWithFormat:@"googlegmail:///co?to=&subject=%@&body=%@",@"",self.shareParas[@"link"]];
            if ([[UIApplication sharedApplication]
                 canOpenURL:[NSURL URLWithString:customURL]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURL]];
            }
            else
            {
                occasionalHint(AYLocalizedString(@"未安装Gmail"));
            }
        }
            break;
        case AYSharePlatformTypeCopyLink:
        {
            UIPasteboard * pastboard = [UIPasteboard generalPasteboard];
            pastboard.string = self.shareParas[@"link"];
            occasionalHint(AYLocalizedString(@"复制成功"));
        }
            break;
        default:
            break;
    }
    
}

-(NSMutableDictionary*)createShareParasWithPlatType:(AYSharePlatformType) platformType
{
     NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //通用参数设置
    //图片必须为网络图片
    [parameters SSDKSetupShareParamsByText:self.shareParas[@"desc"]
                                    images:self.shareParas[@"image"]
                                       url:[NSURL URLWithString:self.shareParas[@"link"]]
                                     title:self.shareParas[@"title"]
                                      type:SSDKContentTypeWebPage];
    switch (platformType)
    {
    case AYSharePlatformTypeFacebook:
        {
            
            
             // [parameters SSDKEnableUseClientShare];
//
//            [parameters SSDKSetupFacebookParamsByText:self.shareParas[@"desc"] image:self.shareParas[@"image"] url:[NSURL URLWithString:self.shareParas[@"link"]] urlTitle:self.shareParas[@"title"] urlName:nil attachementUrl:nil hashtag:nil quote:nil type:SSDKContentTypeWebPage];

          
        }
        break;
    case AYSharePlatformTypeGoogle:
        {

        }
        
        break;
    case AYSharePlatformTypeTwitter:
        {
            //图片最多4张 GIF只能1张
//            NSString *path1 = [[NSBundle mainBundle] pathForResource:@"COD13" ofType:@"jpg"];
//            NSString *path2 = [[NSBundle mainBundle] pathForResource:@"D11" ofType:@"jpg"];
//            NSString *path3 = [[NSBundle mainBundle] pathForResource:@"D45" ofType:@"jpg"];
            //    NSString *path4 = [[NSBundle mainBundle] pathForResource:@"res6" ofType:@"gif"];
            //通用参数设置
//            [parameters SSDKSetupShareParamsByText:@"Share SDK"
//                                            images:@[path1,path2,path3]
//                                               url:nil
//                                             title:nil
//                                              type:SSDKContentTypeImage];
            //平台定制
            //        [parameters SSDKSetupTwitterParamsByText:@"Share SDK"
            //                                          images:path4
            //                                        latitude:0
            //                                       longitude:0
            //
        }
        
        break;
        case AYSharePlatformTypeLine:
        {
            //通用参数设置
            NSString *shareText = [NSString stringWithFormat:@"%@%@",self.shareParas[@"desc"],self.shareParas[@"link"]];
            //通用参数设置
            [parameters SSDKSetupShareParamsByText:shareText
                                            images:nil
                                               url:nil
                                             title:self.shareParas[@"title"]
                                              type:SSDKContentTypeText];
        }
    default:
        break;
    }
    return parameters;
}
-(void)showShowResult:(SSDKResponseState)state error:(NSError*)error
{

    switch (state) {
            
        case SSDKResponseStateBegin:
            AYLog(@"开始分享");
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            return;
            break;
        case SSDKResponseStateFail:
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
           AYLog(@"分享失败：%@",[error localizedDescription]);
            occasionalHint([error localizedDescription]);
        }
            break;
        case SSDKResponseStateSuccess:
            AYLog(@"分享成功");
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            if([AYGlobleConfig shared].shareTaskFinished)
            {
                occasionalHint(AYLocalizedString(@"分享成功"));
            }
//            else
//            {
//                [self requestShareReward];
//            }
            [self requestShareReward];

            break;
        case SSDKResponseStateCancel:
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            AYLog(@"取消分享");
            break;
        default:
            break;

    }
}
#pragma mark - private methods -
-(UIViewController*)getParentViewController
{
    if (_shareParentViewController) {
        return _shareParentViewController;
    }
    UIResponder *nextResponser = self.nextResponder;
    while (nextResponser) {
        if ([nextResponser isKindOfClass:UIViewController.class]) {
            return (UIViewController*)nextResponser;
        }
        nextResponser = nextResponser.nextResponder;
    }
    return nil;
}
#pragma mark - network -
-(void)requestShareReward
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:self.shareParas[@"bookId"]?self.shareParas[@"bookId"]:@"" forKey:@"book_id"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_day_Share" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             if (record[@"remainder"])
             {
                 AYMeModel *meModel = [AYUserManager userItem];
                 meModel.coinNum = [record[@"remainder"] stringValue];
                 [AYUserManager save];
             }
            [AYRewardView showRewardViewWithTitle:AYLocalizedString(@"分享成功") coinStr:@"20" detail:AYLocalizedString(@"每日首次分享奖励20") actionStr:AYLocalizedString(@"明日再来")];
             [AYGlobleConfig shared].shareTaskFinished = YES;
         }
     } failure:^(LEServiceError type, NSError *error) {
        // occasionalHint([error localizedDescription]);
     }];
}
@end
