//
//  ZWREventsManager.m
//  CallU
//
//  Created by Leaf on 16/6/17.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "ZWREventsManager.h"
#import <StoreKit/StoreKit.h>
#import <objc/runtime.h>
#import "NSString+BlockHelper.h"

/*跳转到appstore好评需要此支持*/
#import "AYNavigationController.h"
#import "LEHud.h"
//#import "UIViewController+ZWUMStatistic.h"

@interface ZWREventsManager () <SKStoreProductViewControllerDelegate> {
    NSURL *_externalAppUrl;
}
@property (nonatomic, assign) BOOL cancelOpenAppStore; // 取消appStore执行操作
@property (nonatomic, copy) void(^completeBlock)(BOOL isSuccess, NSString * errorMess);
@end

@implementation ZWREventsManager

- (instancetype) init {
    if ( self = [super init] ) {
        [self setUp];
    }
    return self;
}

- (void) setUp {
    _externalAppUrl = nil;
}

//根视图
- (UIViewController *) rootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

//最顶层视图控制器
- (UIViewController *) topViewController {
    UIViewController * rootViewController = [self rootViewController];
    while ( rootViewController.presentingViewController ) {
        rootViewController = rootViewController.presentingViewController;
        AYLog(@"the rootViewController is %@",NSStringFromClass(rootViewController.class));
    }
    return rootViewController;
}

//最顶层导航控制器
- (UINavigationController *) topNavigationController {
    UIViewController * topNavigationController = [self topViewController];
    if ( [topNavigationController isKindOfClass:[UINavigationController class]] ) {
        return (UINavigationController *)topNavigationController;
    } else {
        return topNavigationController.navigationController;
    }
}

//根控制器模态显示
- (void) rootViewControllerPresentViewController : (UIViewController *) viewController {
    if ( viewController && self.rootViewController ) {
        [self.rootViewController presentViewController:viewController animated:YES completion:nil];
    } else {
        Debug(@">> ERROR : 根视图控制器模态显示页面失败!无法获取控制器对象");
    }
}

//顶层导航控制器压栈动作
- (BOOL) topNavigationControllerPushViewController : (UIViewController *) viewController allowCovered : (BOOL) allowCovered animate:(BOOL)animate {
    if ( self.topNavigationController ) {
        if (allowCovered) {
            [self.topNavigationController pushViewController:viewController animated:animate];
            return YES;
        } else if (![self.topNavigationController.visibleViewController isKindOfClass:[viewController class]]) {
            [self.topNavigationController pushViewController:viewController animated:animate];
            return YES;
        }
        return NO;
    } else {
        Debug(@">> ERROR : 顶层导航栏控制器压栈失败!没有导航控制器");
    }
    return NO;
}

- (BOOL) presentAppStoreByAppURL : (NSURL *) vAppURL dismissAction : (void(^)(BOOL success, NSString * errorMess)) dismissBlock {
    // 保存当前url
    _externalAppUrl = vAppURL;
    //
    if ( _externalAppUrl ) {
        NSNumber *appId = [self captureAppIdFromUrl:_externalAppUrl];
        if ( appId ) {
            [self presentAppStoreByAppId:appId completeBlock:dismissBlock];
            return YES;
        } else {
            _externalAppUrl = nil;
            return NO;
        }
    }
    return NO;
}

- (void) presentAppStoreByAppId : (NSNumber *) vAppId completeBlock : (void(^)(BOOL isSucces, NSString * errorMess)) completion {
    if ( !vAppId || [vAppId integerValue] <= 0 ) {
        return;
    }
    [LEHud showWithStatus:@"处理中"];
    self.cancelOpenAppStore = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( [LEHud isVisible] ) {
            self.cancelOpenAppStore = YES;
            // 内部跳转失败，则执行调起AppStore应用的跳转
            [self callAppStoreApplicationCompletion:completion];
        }
    });

    dispatch_async(dispatch_get_main_queue(), ^{
        SKStoreProductViewController * storeProductViewContorller = [[SKStoreProductViewController alloc] init];
        storeProductViewContorller.delegate = self;
        [storeProductViewContorller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: vAppId }
                                              completionBlock:^(BOOL result, NSError * _Nullable error) {
                                                  [LEHud dismiss];
                                                  if ( result && !self.cancelOpenAppStore ) {
                                                      self.completeBlock = completion;
                                                      [self rootViewControllerPresentViewController:storeProductViewContorller];
                                                  } else if ( completion && !self.cancelOpenAppStore ) {
                                                      [LEHud showErrorWithStatus:@"执行失败"];
                                                      completion(NO, error.localizedDescription);
                                                  }
                                              }];
        
    });
}

- (void)callAppStoreApplicationCompletion:(void(^)(BOOL isSucces, NSString * errorMess)) completion  {
    if ( _externalAppUrl && [[UIApplication sharedApplication] canOpenURL:_externalAppUrl] ) {
        [LEHud dismiss];
        if ( self.completeBlock ) self.completeBlock(YES, nil);
        [[UIApplication sharedApplication] openURL:_externalAppUrl];
        _externalAppUrl = nil;
    } else {
        _externalAppUrl = nil;
        [LEHud showErrorWithStatus:@"执行失败"];
        if ( completion ) completion(NO, @"执行失败");
    }
    
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    if ( self.completeBlock ) self.completeBlock(YES, nil);
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Class
+ (ZWREventsManager *) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public
+ (BOOL) presentAppStoreByAppURL : (NSURL *) vAppURL dismissAction : (void(^)(BOOL success, NSString * errorMess)) dismissBlock {
    return [[self sharedInstance] presentAppStoreByAppURL:vAppURL dismissAction:dismissBlock];
}
/**
 *  用户appstore好评或者跳转功能｜应用内打开
 */
+ (void) presentAppStoreByAppId : (NSNumber *) vAppId dismissAction : (void(^)(BOOL success, NSString * errorMess)) dismissBlock {
    [[self sharedInstance] presentAppStoreByAppId:vAppId completeBlock:dismissBlock];
}
/**
 *  发送一个事件｜目前事件接受对象只能是控制器
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
 */
+ (BOOL) sendViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters animate:(BOOL)animate {
    Class<ZWREventsProtocol> clazz = NSClassFromString(receivedClassName);
    if ( class_conformsToProtocol(clazz, @protocol(ZWREventsProtocol)) ) {
        if ( [clazz eventAvaliableCheck:parameters] ) {
            id receivedItem = [clazz eventRecievedObjectWithParams:parameters];
            if ( receivedItem && [receivedItem isKindOfClass:UIViewController.class] ) {
                return [[self sharedInstance] topNavigationControllerPushViewController:receivedItem allowCovered:YES animate:animate];
            } else {
                Debug(@">> ERROR : 事件分发失败！初始化实例失败，目前只能是控制器接受本事件!");
            }
        } else {
            Debug(@">> ERROR : 事件分发失败！<eventAvaliableCheck:>检查失败!");
        }
    } else {
        Debug(@">> ERROR : 事件分发失败!对象类没有履行ZWREventsProtocol协议");
    }
    return NO;
}
/**
 *  发送一个事件｜目前事件接受对象只能是控制器
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
 */
+ (BOOL) sendViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters {
    Class<ZWREventsProtocol> clazz = NSClassFromString(receivedClassName);
    if ( class_conformsToProtocol(clazz, @protocol(ZWREventsProtocol)) ) {
        if ( [clazz eventAvaliableCheck:parameters] ) {
            id receivedItem = [clazz eventRecievedObjectWithParams:parameters];
            if ( receivedItem && [receivedItem isKindOfClass:UIViewController.class] ) {
                return [[self sharedInstance] topNavigationControllerPushViewController:receivedItem allowCovered:YES animate:YES];
            } else {
                Debug(@">> ERROR : 事件分发失败！初始化实例失败，目前只能是控制器接受本事件!");
            }
        } else {
            Debug(@">> ERROR : 事件分发失败！<eventAvaliableCheck:>检查失败!");
        }
    } else {
        Debug(@">> ERROR : 事件分发失败!对象类没有履行ZWREventsProtocol协议");
    }
    return NO;
}
/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
 @blcok  回调
 */
+ (BOOL) sendViewControlleWithCallBackEvent : (NSString *) receivedClassName parameters : (id) parameters animated:(BOOL)animated callBack:(void(^)(id obj)) block
{
    Class<ZWREventsProtocol> clazz = NSClassFromString(receivedClassName);
    if ( class_conformsToProtocol(clazz, @protocol(ZWREventsProtocol)) ) {
        if ( [clazz eventAvaliableCheck:parameters] ) {
            id receivedItem = [clazz eventRecievedObjectWithParams:parameters];
            if ( receivedItem && [receivedItem isKindOfClass:UIViewController.class] ) {
                //设置回调
                [clazz eventSetCallBack:block controller:receivedItem];
                return [[self sharedInstance] topNavigationControllerPushViewController:receivedItem allowCovered:YES animate:animated];
            } else {
                Debug(@">> ERROR : 事件分发失败！初始化实例失败，目前只能是控制器接受本事件!");
            }
        } else {
            Debug(@">> ERROR : 事件分发失败！<eventAvaliableCheck:>检查失败!");
        }
    } else {
        Debug(@">> ERROR : 事件分发失败!对象类没有履行ZWREventsProtocol协议");
    }
    return NO;
}
/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，且该方法会进行过滤，不允许连续对同一种控制器进行push操作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称，且不允许连续对同一种控制器进行push操作
 *  @param parameters    事件触发必要参数
 */
+ (BOOL) sendNotCoveredViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters {
    Class<ZWREventsProtocol> clazz = NSClassFromString(receivedClassName);
    if ( class_conformsToProtocol(clazz, @protocol(ZWREventsProtocol)) ) {
        if ( [clazz eventAvaliableCheck:parameters] ) {
            id receivedItem = [clazz eventRecievedObjectWithParams:parameters];
            if ( receivedItem && [receivedItem isKindOfClass:UIViewController.class] ) {
                return [[self sharedInstance] topNavigationControllerPushViewController:receivedItem allowCovered:NO animate:YES];
            } else {
                Debug(@">> ERROR : 事件分发失败！初始化实例失败，目前只能是控制器接受本事件!");
            }
        } else {
            Debug(@">> ERROR : 事件分发失败！<eventAvaliableCheck:>检查失败!");
        }
    } else {
        Debug(@">> ERROR : 事件分发失败!对象类没有履行ZWREventsProtocol协议");
    }
    return NO;
}

/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
 *  @param adSeatItem    如果是广告需要传入广告参数｜非必填
 */
+ (BOOL) sendViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters adSeatItem : (ZWAdSeatItem *) adSeatItem {
    Class<ZWREventsProtocol> clazz = NSClassFromString(receivedClassName);
    if ( class_conformsToProtocol(clazz, @protocol(ZWREventsProtocol)) ) {
        if ( [clazz eventAvaliableCheck:parameters] ) {
            id receivedItem = [clazz eventRecievedObjectWithParams:parameters];
//            if ( [receivedItem respondsToSelector:@selector(_zwSetAdSeatItem:)] ) {
//                [receivedItem _zwSetAdSeatItem:adSeatItem];
//            }
            if ( receivedItem && [receivedItem isKindOfClass:UIViewController.class] ) {
                return [[self sharedInstance] topNavigationControllerPushViewController:receivedItem allowCovered:YES animate:YES];
            } else {
                Debug(@">> ERROR : 事件分发失败！初始化实例失败，目前只能是控制器接受本事件!");
            }
        } else {
            Debug(@">> ERROR : 事件分发失败！<eventAvaliableCheck:>检查失败!");
        }
    } else {
        Debug(@">> ERROR : 事件分发失败!对象类没有履行ZWREventsProtocol协议");
    }
    return NO;
}

#pragma mark - Helper
- (nullable NSNumber *)captureAppIdFromUrl:(NSURL *)URL {
    if ( [[UIApplication sharedApplication] canOpenURL:URL] ) {
        NSString *resultString = [URL.absoluteString matchExternalAppId];
        BOOL validScheme = [self mactchURLSchemeIfCanOpenInAppStore:URL];
        if ( validScheme && resultString && [resultString isNumber] ) {
            return @(resultString.integerValue);
        }
    }
    return nil;
}

/**
 *  判断当前URL Scheme是否匹配能在appleStore内打开要求
 */
- (BOOL)mactchURLSchemeIfCanOpenInAppStore:(NSURL *)URL {
    if ( URL ) {
        NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https", @"itms-apps", @"itms"]];
        return [validSchemes containsObject:URL.scheme];
    }
    return NO;
}

@end
