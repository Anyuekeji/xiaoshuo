//
//  AppDelegate+JPush.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/28.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import "AppDelegate.h"
// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (JPush)<JPUSHRegisterDelegate>
-(void)initJPush:(NSDictionary *)launchOptions;
@end

NS_ASSUME_NONNULL_END
