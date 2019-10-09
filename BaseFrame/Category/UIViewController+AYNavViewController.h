//
//  UIViewController+AYNavViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (AYNavViewController)
/**
 *  返回一个导航栏按钮
 *
 *  @param title          标题
 *  @param normalColor    正常颜色
 *  @param highlightColor 高亮颜色
 *  @param normalImage    正常图片
 *  @param highlightImage 高亮图片
 *  @param target         委托
 *  @param action         响应函数
 *
 *  @return 实例
 */
- (UIBarButtonItem *) barButtonItemWithTitle : (NSString *) title
                                 normalColor : (UIColor *) normalColor
                              highlightColor : (UIColor *) highlightColor
                                 normalImage : (UIImage *) normalImage
                              highlightImage : (UIImage *) highlightImage
                                  leftBarItem:(BOOL)leftBarItem
                                      target : (id) target
                                      action : (SEL) action;

/**
 *  简单配置退回按钮，自动dismiss或者自动pop
 */
- (void) configurateBackBarButtonItem;
/**
 *  退出动作，可重写
 */
- (void) backAction;
/**
 退出动作，带执行完成回调
 */
- (void) backActionWithComplete : (void (^)()) completion;

/**
 *  返回一个按钮
 *
 *  @param normalTitle    正常标题
 *  @param highlightTitle 高亮标题
 *  @param selectedTitle  选中标题
 *  @param disableTitle   不可用标题
 *  @param normalColor    正常标题颜色
 *  @param highlightColor 高亮标题颜色
 *  @param selectedColor  选中标题颜色
 *  @param disableColor   不可用标题颜色
 *  @param normalImage    正常图片
 *  @param highlightImage 高亮图片
 *  @param selectedImage  选中图片
 *  @param disableImage   不可用图片
 *  @param target         代理
 *  @param action         响应函数
 *  @param controlEvents  触发事件类型
 *
 *  @return 实例
 */
- (UIButton *) buttonWithTitle : (NSString *) normalTitle
                highlightTitle : (NSString *) highlightTitle
                 selectedTitle : (NSString *) selectedTitle
                  disableTitle : (NSString *) disableTitle
                   normalColor : (UIColor *) normalColor
                highlightColor : (UIColor *) highlightColor
                 selectedColor : (UIColor *) selectedColor
                  disableColor : (UIColor *) disableColor
                   normalImage : (UIImage *) normalImage
                highlightImage : (UIImage *) highlightImage
                 selectedImage : (UIImage *) selectedImage
                  disableImage : (UIImage *) disableImage
                        target : (id) target
                        action : (SEL) action
                         event : (UIControlEvents) controlEvents;

/**
 *  设置导航栏颜色
 *
 *  @param color 色值
 */
- (void) setNavigationBarColor : (UIColor *) color;

/**
 *  设置左边导航栏按钮｜会修正位置8个物理像素偏移
 */
- (void) setLeftBarButtonItem : (UIBarButtonItem *) item;
/**
 *  设置右边导航栏按钮｜会修正位置8个物理像素偏移
 */
- (void) setRightBarButtonItem : (UIBarButtonItem *) item;
/**
 *  设置左边导航栏按钮组｜会修正位置8个物理像素偏移
 */
- (void) setLeftBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems;
/**
 *  设置左边导航栏按钮为空
 */
- (void) setLeftBarButtonItemsEmpty;
/**
 *  设置左边导航栏按钮组
 *
 *  @param leftBarButtonItems 按钮组
 *  @param space              修正物理像素偏移
 */
- (void) setLeftBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems fixedSpace : (CGFloat) space;
/**
 *  设置右边导航栏按钮组｜会修正位置8个物理像素偏移
 */
- (void) setRightBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems;
/**
 *  设置右边导航栏按钮组
 *
 *  @param leftBarButtonItems 按钮组
 *  @param space              修正物理像素偏移
 */
- (void) setRightBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems fixedSpace : (CGFloat) space;

/**
 *  是否显示导航栏|默认显示
 */
- (BOOL) shouldShowNavigationBar;
/**
 *  是否显示工具栏|默认隐藏
 */
- (BOOL) shouldShowToolBar;


@end

NS_ASSUME_NONNULL_END
