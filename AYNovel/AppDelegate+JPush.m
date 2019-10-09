//
//  AppDelegate+JPush.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/28.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import "AppDelegate+JPush.h"
#import "AYBannerModel.h"
#import "AYFictionModel.h"
#import "AYCartoonChapterModel.h"
#import "AYCartoonModel.h"
#import "AYADSkipManager.h" //banner跳转管理
#import <objc/runtime.h>

// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define JPUSH_APPKEY @"31cf2a6d3e55eb10401669e9"

static char jpushRegisgerId;


// 如果需要使用 idfa 功能所需要引入的头文件（可选）
//#import <AdSupport/AdSupport.h>
@implementation AppDelegate (JPush)

-(void)initJPush:(NSDictionary *)launchOptions
{
    [self configurePushNotification];
    //Required
    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
   // 添加初始化 APNs 代码
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    //初始化 JPush 代码
    // Required
    // init Push
    // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
    // 如需继续使用 pushConfig.plist 文件声明 appKey 等配置内容，请依旧使用 [JPUSHService setupWithOption:launchOptions] 方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_APPKEY
                          channel:@"App Store"
                 apsForProduction:(SERVER_TYPE==0)?1:0
            advertisingIdentifier:nil];
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(registrationID && registrationID.length>0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            objc_setAssociatedObject(self, &jpushRegisgerId, registrationID, OBJC_ASSOCIATION_COPY_NONATOMIC);
            if([AYUserManager isUserLogin])
            {
                [self uploadPushRegesterId:registrationID];
            }
        }
        else
        {
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
}

-(void)configurePushNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSuccess:) name:kNotificationLoginSuccess object:nil];

}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings
{
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)(void))completionHandler {
    
    AYBannerModel *bannerModel  = [AYBannerModel itemWithDictionary:userInfo];
    AYLog(@"get remotenotificatin userinfo is %@",userInfo);
    [self jumpToBookDetination:bannerModel];
}
#endif

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    AYLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    
    if ([[UIDevice currentDevice].systemVersion floatValue]<10.0 || application.applicationState>0) {
    }
    completionHandler(UIBackgroundFetchResultNewData);
}


#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    
//    UNNotificationRequest *request = notification.request; // 收到推送的请求
//    UNNotificationContent *content = request.content; // 收到推送的消息内容
//
//    NSNumber *badge = content.badge;  // 推送消息的角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;  // 推送消息的声音
//    NSString *subtitle = content.subtitle;  // 推送消息的副标题
//    NSString *title = content.title;  // 推送消息的标题
    AYBannerModel *bannerModel  = [AYBannerModel itemWithDictionary:userInfo];
    AYLog(@"get remotenotificatin userinfo is %@",userInfo);
    [self jumpToBookDetination:bannerModel];
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        AYLog(@"iOS10 前台收到远程通知:%@",userInfo);
        
    }
    else {
        // 判断为本地通知
//        AYLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
//    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
//    UNNotificationContent *content = request.content; // 收到推送的消息内容
    AYBannerModel *bannerModel  = [AYBannerModel itemWithDictionary:userInfo];
    [self jumpToBookDetination:bannerModel];
    AYLog(@"get remotenotificatin userinfo is %@",userInfo);

//    NSNumber *badge = content.badge;  // 推送消息的角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;  // 推送消息的声音
//    NSString *subtitle = content.subtitle;  // 推送消息的副标题
//    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        AYLog(@"iOS10 收到远程通知:%@", userInfo);
        
    }
    else {
        // 判断为本地通知
//        AYLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

#ifdef __IPHONE_12_0
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)){
    NSString *title = nil;
    if (notification) {
        title = @"从通知界面直接进入应用";
    }else{
        title = @"从系统设置界面进入应用";
    }

}
#endif

#pragma mark - network -
-(void)uploadPushRegesterId:(NSString*)resgerId
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:resgerId forKey:@"regsiterion_id"];
    }];
    [ZWNetwork post:@"HTTP_Post_Upload_Push_ID" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class]) {
                     }
     } failure:^(LEServiceError type, NSError *error) {
     }];
}
-(void)jumpToBookDetination:(AYBannerModel*)bookModel
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [AYADSkipManager adSkipWithModel:bookModel];
}
#pragma mark - event handle -

-(void)handleLoginSuccess:(NSNotification*)notify
{
    NSString* jpushId = (NSString*)objc_getAssociatedObject(self, &jpushRegisgerId);
    if (jpushId && jpushId.length>0) {
        [self uploadPushRegesterId:jpushId];
    }
}
@end
