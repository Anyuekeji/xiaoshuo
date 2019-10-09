//
//  ZWREventsManager.h
//  CallU
//
//  Created by Leaf on 16/6/17.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWREventsProtocol.h"
#import "ZWREventsRegisted.h"

@class ZWAdSeatItem;

/**
 *  事件管理器具｜所有app内功能跳转都可以通过本事件管理器分发事件和实现跳转
 */
@interface ZWREventsManager : NSObject

+ (BOOL) presentAppStoreByAppURL : (NSURL *) vAppURL dismissAction : (void(^)(BOOL success, NSString * errorMess)) dismissBlock;
/**
 *  用户appstore好评或者跳转功能｜应用内打开，这个需要测试下载后评论功能
 */
+ (void) presentAppStoreByAppId : (NSNumber *) vAppId dismissAction : (void(^)(BOOL success, NSString * errorMess)) dismissBlock;

/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
 *  @param animate    是否支持动画

 */
+ (BOOL) sendViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters animate:(BOOL)animate;

/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
 */
+ (BOOL) sendViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters;
/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
    @blcok  回调
 */
+ (BOOL) sendViewControlleWithCallBackEvent : (NSString *) receivedClassName parameters : (id) parameters animated:(BOOL)animated  callBack:(void(^)(id obj)) block;

/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，且该方法会进行过滤，不允许连续对同一种控制器进行push操作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称，且不允许连续对同一种控制器进行push操作
 *  @param parameters    事件触发必要参数
 */
+ (BOOL) sendNotCoveredViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters;


/**
 *  发送一个事件｜目前事件接受对象只能是控制器｜会触发导航栏堆栈动作，请不要在此执行过程中做导航栏操作
 *
 *  @param receivedClassName 事件接受对象！只能是控制器类名称
 *  @param parameters    事件触发必要参数
 *  @param adSeatItem    如果是广告需要传入广告参数｜非必填
 */
+ (BOOL) sendViewControllerEvent : (NSString *) receivedClassName parameters : (id) parameters adSeatItem : (ZWAdSeatItem *) adSeatItem;



#pragma mark - 获取顶层控制器

+ (ZWREventsManager *) sharedInstance;

/**
 顶层导航控制器压栈动作

 @param viewController 将要push的页面
 @param allowCovered 是否允许覆盖
 @return 调用结果
 */
- (BOOL) topNavigationControllerPushViewController : (UIViewController *) viewController allowCovered : (BOOL) allowCovered animate:(BOOL)animate;

@end
