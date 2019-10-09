//
//  UIViewController+AYKeyboardViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
/**-----------------------------------------------------------------------------
 * @name UIViewController+AYKeyboardViewController
 * -----------------------------------------------------------------------------
 *  添加了键盘事件
 *  注意，如果你使能了键盘监听，必须在dealloc中使用setUpForDismissKeyboard:NO
 */

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (AYKeyboardViewController)<UIGestureRecognizerDelegate>

/**
 *  是否加键盘事件
 *
 *  @param setUpForDissmissKeyboard 传入YES或者NO开启关闭键盘事件
 */
- (void) setUpForDismissKeyboard : (BOOL) setUpForDissmissKeyboard;

/**
 *  开关点击手势事件
 *
 *  @param enable 是否开启
 */
- (void) enableTapGesture : (BOOL) enable;

/**
 *  键盘将要出现会启用本方法，请在子类中实现逻辑
 *
 *  @param size 键盘大小
 *  @param time 动画执行时间
 */
- (void) keyboardWillShowWithSize : (CGSize) size duration : (NSTimeInterval) time;

/**
 *  键盘将要消失会启用本方法，请在子类中实现逻辑
 *
 *  @param size 键盘大小
 *  @param time 动画执行时间
 */
- (void) keyboardWillHideWithSize : (CGSize) size duration : (NSTimeInterval) time;
@end

NS_ASSUME_NONNULL_END
