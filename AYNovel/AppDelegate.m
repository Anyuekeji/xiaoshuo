//
//  AppDelegate.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AppDelegate.h"
#import "AYRootViewController.h"
#import "AppDelegate+ShareSdk.h"
#import "AYLogiinViewController.h"
#import "AppDelegate+Realm.h"
#import "IAPManager.h"
#import <Bugly/Bugly.h>
#import "AppDelegate+LaunchAd.h"
#import "AYLaunchADManager.h" //启动广告
#import <YYKit/YYKit.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import "AppDelegate+JPush.h" //推送
#import "AYNavigationController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AYBannerModel.h"
#import "AYADSkipManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "AYAdmobManager.h"

#define BUGLY_APP_ID @"010c1772bf"

@interface AppDelegate ()

@end

@implementation AppDelegate
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)initBugly
{
    [Bugly startWithAppId:BUGLY_APP_ID];
    BuglyConfig * config = [[BuglyConfig alloc] init];
    #if DEBUG
    config.debugMode = YES;
    #endif
    config.blockMonitorEnable = YES;
    config.unexpectedTerminatingDetectionEnable = YES;
}
-(void)initFacebook:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBSDKSettings setClientToken:@"39a2ad1358133e30c6a004b71532e5ce"];
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
        if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
            [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
                if (error || !url || [url absoluteString].length<=0)
                {
                    if (error)
                    {
                        NSLog(@"Received error while fetching deferred app link %@", error);
                    }
                }
                if (url)
                {
                    [[UIApplication sharedApplication] setStatusBarHidden:NO];
                    [self parseQueryString:[url host]];
                }
            }];
        }
}
-(void)initWithGoogleAd
{
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-2617109421747439~8302239382"];
  //  [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];

    [[AYAdmobManager shared] createAdBannerView:self.window.rootViewController];//提前加载广告
    [[AYAdmobManager shared] createSmallAdBannerView:self.window.rootViewController];//提前加载广告
    [[AYAdmobManager shared] createContainSelectAdBannerView:self.window.rootViewController];
    [[AYAdmobManager shared] createGADRewardBasedVideoAd];//提前加载广告

}
//更新用户的金币
-(void)updateUserCoin: (void(^)(void)) completeBlock
{
    if (![AYUserManager isUserLogin]) {
        return;
    }
   // HTTP_Post_Get_Money
    [ZWNetwork post:@"HTTP_Post_Get_Money" parameters:nil success:^(id record)
     {
         if ([record isKindOfClass:NSDictionary.class])
         {
             if (![record[@"remainder"] isKindOfClass:NSNull.class]) {
                 NSString *myMoney = [record[@"remainder"] stringValue];
                 if (myMoney)
                 {
                     [AYUserManager userItem].coinNum = myMoney;
                     [AYUserManager save];
                 }
             }
             if(completeBlock)
             {
                 completeBlock();
             }
             
         }
     } failure:^(LEServiceError type, NSError *error) {
         if(completeBlock)
         {
             completeBlock();
         }
         occasionalHint([error localizedDescription]);

     }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initShareSdk];//初始化sharesdk
    [self initBugly];//初始化bugly
    [self initRealm];
    [self initJPush:launchOptions];
    [self initFacebook:application didFinishLaunchingWithOptions:launchOptions];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //网络初始化
    [ZWNetwork sharedInstance];
    [self changeToLoginOrMainViewController:NO];
    //默认自动解锁收费章节
    NSNumber *autoUnlock = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultAutoUnlockChapter];
    if (!autoUnlock) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserDefaultAutoUnlockChapter];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    /**启动IAP工具类*/
    [[IAPManager shared] startManager];
    [self loadLaunchAd]; // 加载广告
    [self initWithGoogleAd];

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    [self updateUserCoin:nil];
    if([AYUserManager isUserLogin])
    {
        [[AYGlobleConfig shared] updateTaskStatus:^{
            
        } failure:^(NSString * _Nonnull errorString) {
            
        }];
        //获取邀请奖励信息
        [[AYGlobleConfig shared] getInviteRuleData];
    }
    //获取广告信息
    [[AYGlobleConfig shared] getAdvertiseInfo:^{
        
    }];
    // your other code here.... }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /**结束IAP工具类*/
    [[IAPManager shared] stopManager];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return YES;
}


-(void)changeToLoginOrMainViewController:(BOOL)login
{
    if (!login)
    {
        UINavigationController * rootViewController = [AYRootViewController navigationController];
        rootViewController.navigationBar.translucent = NO;
        self.window.rootViewController = rootViewController;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultIsLogin];
    }
    else
    {
        self.window.rootViewController = [[AYLogiinViewController alloc] init];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultIsLogin];
    }
    [self.window makeKeyAndVisible];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    AYLog(@"url recieved: %@", url);
    AYLog(@"query string: %@", [url host]);
    if([[url absoluteString] containsString:@"thnovel"])
    {
        [self parseQueryString:[url host]];
    }
    return YES;
}
- (NSDictionary *)parseQueryString:(NSString *)query {
    if(query && query.length>0 && [query containsString:@"type"])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        
        
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [dict setObject:val forKey:key];
        }
        AYBannerModel *bannerModel = [AYBannerModel new];
        NSString *type =dict[@"type"];
        if (type)
        {
            bannerModel.bannerType = @([type integerValue]);
            NSString *subType =dict[@"subtype"];
            if (subType)
            {
                bannerModel.bannerDestinationType = @([subType integerValue]);
                bannerModel.bannerID =dict[@"subid"];
            }
            else
            {
                NSString *urlType =dict[@"url"];
                if (urlType)
                {
                    bannerModel.bannerLinkUrl =urlType;
                }
                
            }
            [AYADSkipManager adSkipWithModel:bannerModel];
        }
        return dict;
    }
    return nil;
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    //line回调
    if ([[url absoluteString] containsString:@"line3rdp.com"])
    {
        return YES;
    }
    if (@available(iOS 9.0, *)) {
       [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                      openURL:url
                                                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                        ];
        
    } else {
        // Fallback on earlier versions
    }
 //   NSLog(@"application:openURL:options:");
     [self application:app handleOpenURL:url];
    return  YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {

    [[SDImageCache sharedImageCache] clearMemory];
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
    [[SDWebImageManager sharedManager] cancelAll];
}

@end
