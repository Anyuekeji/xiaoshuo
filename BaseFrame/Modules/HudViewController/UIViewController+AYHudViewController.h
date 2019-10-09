//
//  UIViewController+AYHudViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (AYHudViewController)<MBProgressHUDDelegate>

- (MBProgressHUD *) HUD;
#pragma mark - 封装显示
/**
 *  仅菊花
 */
- (void) showHUD;
/**
 *  菊花+标题
 */
- (void) showHUDWithTitle : (NSString *) title;
/**
 *  菊花+标题+详细
 */
- (void) showHUDWithTitle : (NSString *) title detail : (NSString *) detail;
/**
 *  扇形进度条，请用updateHUDProgress更新
 */
- (void) showHUDWithDeterminateTitle : (NSString *) title detail : (NSString *) detail;
/**
 *  横向进度条，请用updateHUDProgress更新
 */
- (void) showHUDWithDeterminateHorizontalBarTitle : (NSString *) title detail : (NSString *) detail;
/**
 *  环形进度条，请用updateHUDProgress更新
 */
- (void) showHUDWithAnnularTitle : (NSString *) title detail : (NSString *) detail;
/**
 *  更新进度条，必须在创建对应类型之后,将在主线程执行
 */
- (void) updateHUDProgress : (float) progress;
/**
 *  只有文字
 */
- (void) showHUDTextTitle : (NSString *) title detail : (NSString *) detail hideAfter : (NSTimeInterval) delay;
/**
 *  自定义View
 */
- (void) showHUDWithCustomerView : (UIView *) customerView title : (NSString *) title detail : (NSString *) detail hideAfter : (NSTimeInterval) delay;
/**
 *  隐藏进度条，将在主线程执行
 */
- (void) hideHUD;
/**
 *  显示执行成功
 */
- (void) showHUDWithComplete;
/**
 *  显示执行成功,带文案
 */
- (void) showHUDWithCompleteMess : (NSString *) mess;
/**
 *  显示执行失败
 */
- (void) showHUDWithErrorMess : (NSString *) messTitle detail : (NSString *) detail;
/**
 *  显示执行警告
 */
- (void) showHUDWithWarningMess : (NSString *) messTitle detail : (NSString *) detail;

#pragma mark - Window 界面的HUD
/**
 *  显示仅仅文字和详细，依附于Window，delay必须大于0
 */
- (void) showWindowHUDWithMess : (NSString *) messTitle detail : (NSString *) detail hideAfter : (NSTimeInterval) delay;
/**
 *  显示执行成功，带文案，依附于window
 */
- (void) showWindowHUDWithCompleteMess : (NSString *) mess;
/**
 *  显示执行失败，依附于window
 */
- (void) showWindowHUDWithErrorMess : (NSString *) messTitle detail : (NSString *) detail;
/**
 *  显示执行警告，依附于window
 */
- (void) showWindowHUDWithWarningMess : (NSString *) messTitle detail : (NSString *) detail;

#pragma mark - HUD生产
/**
 *  生成一个NavigationControll（ViewControll）级别的HUD实例，请用self.HUD访问
 *
 *  @param mode             模式
 *  @param title            标题
 *  @param detail           简述
 *  @param autoThreadRemove 是否需要自动判定移除
 *  @param delay            移除动画，在autoThreadRemove为NO状态设定生效
 */
- (void) createHUDWithMode : (MBProgressHUDMode) mode
                     title : (NSString *) title
                    detail : (NSString *) detail
      needAutoThreadRemove : (BOOL) autoThreadRemove
                 hideAfter : (NSTimeInterval) delay;

/**
 *  生成一个Window级别的HUD实例，请用self.HUD访问
 *
 *  @param mode             模式
 *  @param customerView     附属view
 *  @param title            标题
 *  @param detail           简述
 *  @param autoThreadRemove 是否需要自动判定移除
 *  @param delay            移除动画，在autoThreadRemove为NO状态设定生效
 */
- (void) windowHUDWithMode : (MBProgressHUDMode) mode
              customerView : (UIView *) customerView
                     title : (NSString *) title
                    detail : (NSString *) detail
      needAutoThreadRemove : (BOOL) autoThreadRemove
                 hideAfter : (NSTimeInterval) delay;


@end

NS_ASSUME_NONNULL_END
