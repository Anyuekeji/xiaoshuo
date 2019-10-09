//
//  ZWR2SegmentViewController.h
//  CallU
//
//  Created by Leaf on 2017/3/27.
//  Copyright © 2017年 2.1.6. All rights reserved.
//

#import "LEBaseViewController.h"
#import "ZWR2SegmentItem.h"


@class LESegment;
@protocol ZWR2BaseSegmentViewControllerDelegate;

/**
 分页控制器的基本控制器类,不要直接使用此类；
 */
@interface ZWR2BaseSegmentViewController : LEBaseViewController

//MARK:数据源
/** 数据对象，不要改写Setter方法，牵涉到页面刷新 */
@property (nonatomic, strong) NSArray<ZWR2SegmentItem *> * segments;
/** 当前选中索引 */
@property (nonatomic, assign) NSUInteger currentIndex;
/** 分段控制器事件代理 */
@property (nonatomic, weak) id<ZWR2BaseSegmentViewControllerDelegate> delegate;

//MARK:界面
/** 分段控制器的头部  */
@property (nonatomic, strong) LESegment * segmentControl;

/**segment top 约束*/
@property (nonatomic, readonly, strong) NSLayoutConstraint * segmenControlTopContraint;
/**
 当前选中的数据源
 */
- (ZWR2SegmentItem *) currentSelectedSegmentItem;
/**
 *  当前选中控制器
 *
 *  @return 控制器
 */
- (UIViewController<ZWR2SegmentViewControllerProtocol> *) currentSelectedViewController;

/**
 *  设置背景颜色
 */
- (void) setSegmentBackgroundColor : (UIColor *) backgroundColor;
/**
 *  获取背景颜色
 */
- (UIColor *) segmentBackgroundColor;
/**
 *  添加一个视图到顶部分段控制器右边，注意view.width宽度必须赋值
 */
- (void) addViewToSegmentControlRight : (UIView *) view;
/**
 *  设置顶部分段控制器固定段宽
 */
- (void) setSegmentTypeToFixedWidth : (CGFloat) width;
/**
 *  在一个段位置添加红点
 *
 *  @param index 位置
 */
- (void) addRedPointAtIndex : (NSUInteger) index;
/**
 *  为一个子控制添加红点
 *
 *  @param segmentItem 已经加入的子控制器分段数据体
 */
- (void) addRedPointAtSegmentItem : (ZWR2SegmentItem *) segmentItem;
/**
 *  移除一个段位置上的红点
 *
 *  @param index 位置
 */
- (void) removeRedPointAtIndex : (NSUInteger) index;
/**
 *  为一个子控制器移除红点
 *
 *  @param segmentItem 已经加入的子控制器分段数据体
 */
- (void) removeRedPointAtSegmentItem : (ZWR2SegmentItem *) segmentItem;

@end

@protocol ZWR2BaseSegmentViewControllerDelegate <NSObject>

@optional
/**
 *  分段控制器重置了子控制器组会调用此方法
 */
- (void) zwr2SegmentViewControllerDidResetContent : (ZWR2BaseSegmentViewController *) segmentViewController;

/**
 *  分段控制器选择了选择了子控制器调用此方法
 */
- (void) zwr2SegmentViewController : (ZWR2BaseSegmentViewController *) segmentViewController switchToSegmentItem : (ZWR2SegmentItem *) segmentItem;
/**
 *  分段控制器加载了子控制器调用此方法
 */
- (void) zwr2SegmentViewController : (ZWR2BaseSegmentViewController *) segmentViewController didLoadSegmentItem : (ZWR2SegmentItem *) segmentItem;
/**
 *  分段控制器移除了子控制器调用此方法
 */
- (void) zwr2SegmentViewController:(ZWR2BaseSegmentViewController *)segmentViewController didRemoveSegmentItem : (ZWR2SegmentItem *) segmentItem;

@end
