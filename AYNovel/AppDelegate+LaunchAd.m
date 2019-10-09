//
//  AppDelegate+LaunchAd.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/23.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import "AppDelegate+LaunchAd.h"
#import "AYLaunthAdView.h" //启动广告
#import "AYLaunchADManager.h"
#import "AYLaunchAdModel.h"

@implementation AppDelegate (LaunchAd)
-(void)loadLaunchAd
{
    AYLaunchAdModel *adModel = [AYLaunchADManager launchAdModel];
    if (adModel && adModel.bannerStatus)
    {
        NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        if ([timeSp longLongValue]>[adModel.bannerEndtime longLongValue] || ![AYLaunchADManager hasCatcheImage]) {
            AYLog(@"广告过期,不显示广告");
            [AYLaunchADManager fetchLaunchAd];
            return;
        }
        else
        {
            AYLaunthAdView *adView = [[AYLaunthAdView alloc] initWithFrame:self.window.bounds];
            [self.window addSubview:adView];
        }

    }
    [AYLaunchADManager fetchLaunchAd];
}

@end
