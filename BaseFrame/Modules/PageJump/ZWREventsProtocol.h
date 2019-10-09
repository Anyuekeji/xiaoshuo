//
//  ZWREventsProtocol.h
//  CallU
//
//  Created by Leaf on 16/6/22.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  具备响应事件的控制器或者对象需要实现本协议
 */
@protocol ZWREventsProtocol <NSObject>

@required
/**
 *  事件传入参数验证
 *
 *  @param parameters 参数
 *
 *  @return 是否通过验证
 */
+ (BOOL) eventAvaliableCheck : (id) parameters;
/**
 *  事件构造实例对象
 *
 *  @param parameters 事件传入参数
 *
 *  @return 实例
 */
+ (id) eventRecievedObjectWithParams : (id) parameters;

@optional
/**
 *  设置回调
 *
 *  @param block 回调
 *  @controller 当前的controller
 *  @return 实例
 */
+ (void) eventSetCallBack:(void(^)(id obj)) block controller:(UIViewController*)controller;
@end
