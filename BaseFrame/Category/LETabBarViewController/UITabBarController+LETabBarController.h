//
//  UIViewController+LETabBarController.h
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/8.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

/**-----------------------------------------------------------------------------
 * @name UITabBarController+LETabBarController
 * -----------------------------------------------------------------------------
 *  添加了部分类方法，更加便捷操作
 */
@interface UITabBarController (LETabBarController)

#pragma mark - 类方法
+ (id) controller;

/**
 *  返回自动隐藏navigationbar的导航控制器，rootViewController是TabBarController
 */
+ (id) navigationController;

/**
 *  设置Tabbar通用标题属性
 *
 *  @param font         字体
 *  @param color        颜色
 *  @param shadowColor  阴影
 *  @param shadowOffset 阴影偏移或者NANSIZE
 *  @param controlState 状态
 */
+ (void) setAppearanceTitleFont : (UIFont *) font color : (UIColor *) color shadowColor : (UIColor *) shadowColor shadowOffset : (CGSize) shadowOffset forState : (UIControlState ) controlState;

+ (void) setTitlePositionAdjustment : (UIOffset) offset;
/**
 *  设置某个tabbarItem的标题和图片
 *
 *  @param tabbarItem    将被改变的实例
 *  @param title         标题
 *  @param normalImage   正常图片
 *  @param selectedImage 选中图片
 */
+ (void) setTabBarItem : (UITabBarItem *) tabbarItem title : (NSString *) title normalImage : (UIImage *) normalImage selectedImage : (UIImage *) selectedImage;

/**
 *  设置自身某个index下tabbarItem的标题和图片
 *
 *  @param index    将被改变的实例
 *  @param title         标题
 *  @param normalImage   正常图片
 *  @param selectedImage 选中图片
 */
- (void) setTabBarItemAtIndex : (NSInteger) index title : (NSString *) title normalImage : (UIImage *) normalImage selectedImage : (UIImage *) selectedImage;

/**
 *  设置某个tabbarItem的图片
 *
 *  @param tabbarItem    将被改变的实例
 *  @param normalImage   正常图片
 *  @param selectedImage 选中时图片
 */
+ (void) setTabBarItem : (UITabBarItem *) tabbarItem normalImage : (UIImage *) normalImage selectedImage : (UIImage *) selectedImage;
/**
 *  设置自身某个index下tabbarItem的的图片
 *
 *  @param index    将被改变的实例
 *  @param normalImage   正常图片
 *  @param selectedImage 选中时图片
 */
- (void) setTabBarItemAtIndex : (NSInteger) index nromalImage : (UIImage *) normalImage selectedImage : (UIImage *) selectedImage;

/**
 *  设置某个tabbarItem标题属性
 *
 *  @param tabbarItem   将被改变的实例
 *  @param font         标题字体
 *  @param color        颜色
 *  @param shadowColor  阴影
 *  @param shadowOffset 阴影偏移或者NANSIZE
 *  @param controlState 状态
 */
+ (void) setTabBarItem : (UITabBarItem *) tabbarItem font : (UIFont *) font color : (UIColor *) color shadowColor : (UIColor *) shadowColor shadowOffset : (CGSize) shadowOffset forState : (UIControlState) controlState;
/**
 *  设置自身某个index下tabbarItem的标题属性
 *
 *  @param index   将被改变的实例
 *  @param font         标题字体
 *  @param color        颜色
 *  @param shadowColor  阴影
 *  @param shadowOffset 阴影偏移或者NANSIZE
 *  @param controlState 状态
 */
- (void) setTabBarItemAtIndex : (NSInteger) index font : (UIFont *) font color : (UIColor *) color shadowColor : (UIColor *) shadowColor shadowOffset : (CGSize) shadowOffset forState : (UIControlState) controlState;

@end
