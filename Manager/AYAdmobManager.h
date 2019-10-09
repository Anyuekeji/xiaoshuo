//
//  AYAdmobManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/5.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h> //admob

NS_ASSUME_NONNULL_BEGIN

@interface AYAdmobManager : NSObject
singleton_interface(AYAdmobManager)

//创建横幅广告
-(GADBannerView*)createAdBannerView:(UIViewController*)viewController;

//创建带有不想看广告选择横幅广告
-(UIView*)createContainSelectAdBannerView:(UIViewController*)viewController;

//创建小的横幅广告
-(GADBannerView*)createSmallAdBannerView:(UIViewController*)viewController;

@property(nonatomic, strong) GADBannerView *adBannerView;

@property(nonatomic, strong) UIView *containSelectAdBannerView;


@property(nonatomic, strong) GADBannerView *smallAdBannerView;


//创建激励视频广告
-(void)createGADRewardBasedVideoAd;


//显示激励视频广告
-(void)showGADRewardBasedVideoAd:(void(^)(id obj)) callBack controller:(UIViewController*)controller;

//广告操作回调
@property (nonatomic, copy) void (^admobActionBlock)(AYAdmobAction admobAction);

@end

NS_ASSUME_NONNULL_END
