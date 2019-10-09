//
//  ANBaseViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+AYNavViewController.h"

NS_ASSUME_NONNULL_BEGIN
/**-----------------------------------------------------------------------------
 * @name ANBaseViewController
 * -----------------------------------------------------------------------------
 *  已经集成了键盘事件，自动退出工具，注意dealloc方法重写
 */
@interface LEAFViewController : UIViewController
/**
 *  是否已经在最前
 */
@property (nonatomic, readonly, assign, getter=isVisiable) BOOL visiable;

/**
 *  获取一个控制器实例
 */
+ (id) controller;

/**
 *  获得LENavigationController且rootViewController是本viewController
 */
+ (id) navigationController;

/**
 *  配置导航栏，这里已经实现了退回按钮逻辑，请使用super或者重写时使用configurateBackBarButtonItem
 */
- (void) setUpNavigationItem;

/**
 *  滑动栏位contentInsets
 */
- (UIEdgeInsets) contentInsets;

@end

NS_ASSUME_NONNULL_END
