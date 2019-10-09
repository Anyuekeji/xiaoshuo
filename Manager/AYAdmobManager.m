//
//  AYAdmobManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/5.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYAdmobManager.h"

@interface AYAdmobManager()<GADRewardBasedVideoAdDelegate>

@property (copy, nonatomic) void(^GADRewardBasedVideoAdCallBack)(id obj);

@end

@implementation AYAdmobManager

singleton_implementation(AYAdmobManager)

-(GADBannerView*)createAdBannerView:(UIViewController*)viewController
{
    if (_adBannerView) {
        _adBannerView = nil;
    }
    _adBannerView= [self AdBannerView:viewController];
    return _adBannerView;
}
-(GADBannerView*)AdBannerView:(UIViewController*)viewController{
      GADBannerView *temp_adBannerView= [[GADBannerView alloc]
                    initWithAdSize:kGADAdSizeMediumRectangle];
    temp_adBannerView.adUnitID = @"ca-app-pub-2617109421747439/9649790702";
    temp_adBannerView.rootViewController = viewController;
    temp_adBannerView.left =(ScreenWidth-temp_adBannerView.bounds.size.width)/2.0f;
   // temp_adBannerView.top =(ScreenHeight-temp_adBannerView.height)/2.0f;
    [temp_adBannerView loadRequest:[GADRequest request]];
    return temp_adBannerView;
}
-(UIView*)createContainSelectAdBannerView:(UIViewController*)viewController
{
    if (_containSelectAdBannerView) {
        _containSelectAdBannerView = nil;
    }
    GADBannerView *adBanView = [self AdBannerView:viewController];
    _containSelectAdBannerView = [[UIView alloc] init];
    _containSelectAdBannerView.frame = CGRectMake(0, 0, ScreenWidth, adBanView.height+50);
    adBanView.top =0;
    [_containSelectAdBannerView addSubview:adBanView];
    
    UIButton *canleADBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [canleADBtn setTitle:AYLocalizedString(@"不想看广告") forState:UIControlStateNormal];
    [canleADBtn setTitleColor:UIColorFromRGB(0xff6666) forState:UIControlStateNormal];
    [canleADBtn setTitleColor:UIColorFromRGB(0xff6666) forState:UIControlStateHighlighted];
    canleADBtn.frame = CGRectMake(adBanView.left, adBanView.height+20, adBanView.width, 39);
    canleADBtn.layer.borderWidth = 1.0f;
    canleADBtn.layer.borderColor =UIColorFromRGB(0xff6666).CGColor;
    canleADBtn.layer.cornerRadius = 18.0f;
    canleADBtn.clipsToBounds = YES;
    canleADBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_containSelectAdBannerView addSubview:canleADBtn];
    LEWeakSelf(self)
    [canleADBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        dispatch_async(dispatch_get_main_queue(), ^{
          //  [self adPopSelectView:viewController];
            if (self.admobActionBlock) {
                self.admobActionBlock(AYAdmobActionDoNotLookAdvertise);
            }
        });
    }];
    return _containSelectAdBannerView;
}

-(GADBannerView*)createSmallAdBannerView:(UIViewController*)viewController
{
    if (_smallAdBannerView) {
        _smallAdBannerView = nil;
    }
    _smallAdBannerView= [[GADBannerView alloc]
                    initWithAdSize:kGADAdSizeLargeBanner];
    _smallAdBannerView.adUnitID = @"ca-app-pub-2617109421747439/964979070";
    _smallAdBannerView.rootViewController = viewController;
    _smallAdBannerView.left =(ScreenWidth-_smallAdBannerView.bounds.size.width)/2.0f;
    _smallAdBannerView.top =(ScreenHeight-_adBannerView.height)/2.0f;
    [_smallAdBannerView loadRequest:[GADRequest request]];
    return _smallAdBannerView;
}
-(void)createGADRewardBasedVideoAd
{
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:[DFPRequest request] withAdUnitID:@"ca-app-pub-2617109421747439/3888351652"];
    if (self.admobActionBlock) {
        self.admobActionBlock(AYAdmobActionVideoAdvertiseLoadStart);
    }
}
-(void)showGADRewardBasedVideoAd:(void(^)(id obj)) callBack controller:(UIViewController*)controller
{
    self.GADRewardBasedVideoAdCallBack = callBack;
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:controller];
    }
    else
    {
       occasionalHint(AYLocalizedString(@"广告正在加载中"));
    }
}
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
    [self createGADRewardBasedVideoAd];
    NSString *rewardMessage =
    [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
     reward.type,
     [reward.amount doubleValue]];
    AYLog(@"%@", rewardMessage);
    if (self.GADRewardBasedVideoAdCallBack) {
        self.GADRewardBasedVideoAdCallBack(@(YES));
    }
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    AYLog(@"Reward based video ad is received.");
    if (self.admobActionBlock) {
        self.admobActionBlock(AYAdmobActionVideoAdvertiseLoadFinished);
    }
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    AYLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    AYLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    AYLog(@"Reward based video ad has completed.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    AYLog(@"Reward based video ad is closed.");
    [self createGADRewardBasedVideoAd];
    
//    if (self.GADRewardBasedVideoAdCallBack) {
//        self.GADRewardBasedVideoAdCallBack(@(NO));
//    }
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    AYLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    AYLog(@"Reward based video ad failed to load.");
   // [self createGADRewardBasedVideoAd];
}
@end
