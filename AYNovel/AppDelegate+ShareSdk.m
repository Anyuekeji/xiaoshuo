//
//  AppDelegate+ShareSdk.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AppDelegate+ShareSdk.h"
#import <ShareSDK/ShareSDK.h>
//#import <LineSDK/LineSDK.h>


@implementation AppDelegate (ShareSdk)
-(void)initShareSdk
{
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {

        //Google+
        [platformsRegister setupGooglePlusByClientID:@"167247457029-0muless39o4fklkmd55eug5vt37bie8v.apps.googleusercontent.com" clientSecret:@"" redirectUrl:@"http://localhost"];
     //   [platformsRegister setupTwitterWithKey:<#(NSString *)#> secret:<#(NSString *)#> redirectUrl:<#(NSString *)#>];
        
    [platformsRegister setupFacebookWithAppkey:@"642299609555471" appSecret:@"39a2ad1358133e30c6a004b71532e5ce" displayName:@"อ่านเลย-นิยายและการ์ตูนออนไลน์"];
        
    [platformsRegister setupLineAuthType:SSDKAuthorizeTypeBoth];

    }];
}

@end
