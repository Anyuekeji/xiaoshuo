//
//  LEDynamic.h
//  xiaoyuanplus
//
//  Created by 刘云鹏 on 14/12/10.
//  Copyright (c) 2014年 刘云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LERefreshControlState) {
    LERefreshControlStateNormal = 0,            /*  正常  */
    LERefreshControlStateAwaken = 1,            /*  唤醒  */
    LERefreshControlStateRespond = 2,           /*  响应  */
    LERefreshControlStateStepEnd = 3,           /*  单步结束  */
    LERefreshControlStateForcedSpecial = 4      /*  特殊状态  */
};

/**-----------------------------------------------------------------------------
 * @name LERefreshControl
 * -----------------------------------------------------------------------------
 *  刷新控件，刷新空间有多个状态，注意每个状态之间的转换
 *  注意：需要详细阅读注释
 *       子类状态变化需要继承
 */
@interface LERefreshControl : UIView

@property (nonatomic, readonly, assign) LERefreshControlState state;

/*  所有子view请在这个层中添加 */
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) NSLayoutConstraint * contentViewTopConstraint;

@property (nonatomic, assign, readonly, getter=isAutoLayout) BOOL autoLayout;

/**
 *  吸附到顶部或者底部
 */
@property (nonatomic, assign, readonly, getter=isAbsorb) BOOL adsorb;

/**
 *  实例，必须自动布局translatesAutoresizingMaskIntoConstraints=NO已经设定
 */
+ (id) control;

/**
 *  实例，自动吸附到顶部或者底部
 */
+ (id) controlWithAdsorb;

/**
 *  实例，非自动布局
 */
+ (id) controlWithFrame : (CGRect) frame;

/**
 *  初始化数据,请callsuper
 */
- (void) initParams;

/**
 *  改变当前状态
 *
 *  @param newState 新状态，请用枚举
 *
 *  @return 是否成功改变
 */
- (BOOL) refreshControlStateChangedTo : (LERefreshControlState) newState;

#pragma mark - 状态动作
/**
 *  正常状态，可能需要做指示动画逆转
 */
- (void) normalStateAction;
/**
 *  唤醒状态,可以做指示动画显示
 */
- (void) awakenStateAction;
/**
 *  响应状态，持续性动画开始
 */
- (void) respondStateAction;
/**
 *  单步结束，持续性动画结束
 */
- (void) stepEndStateAction;
/**
 *  特殊状态，主要给lazyload结束用
 */
- (void) forcedSpecialAction;
/**
 *  重置高度，将显示由顶向下范围内容,在顶部refreshControl中继承实现
 *
 *  @param newHeight 新高度，不能为负，自动矫正
 */
- (void) resizeHeightTo : (CGFloat) newHeight;

/**
 *  只有吸附开启时才有效｜调用本方法主要用于回弹动画,请慎重使用
 */
- (void) reTransilationTo : (CGFloat) newHeight;

/**
 *  高度,默认44.0f
 */
- (CGFloat) controlHeight;

/**
 *  唤醒高度,负数
 */
- (CGFloat) awakenHeight;

@end
