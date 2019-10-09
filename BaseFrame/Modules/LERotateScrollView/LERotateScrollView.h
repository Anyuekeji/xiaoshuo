//
//  LERotateScrollView.h
//  JCTopic
//
//  Created by liuyunpeng on 14/10/30.
//  Copyright (c) 2014年 jc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**-----------------------------------------------------------------------------
 * @name LERotateScrollView
 * -----------------------------------------------------------------------------
 *  是可以无限循环的滚动页面
 *  注意：如果滑动速度非常快，建议用比较大的cacheCount值
 *       计算复杂度随缓存大小增加而增加
 *       如果你启用了自动滚动，必须在dealloc之前访问abolishTimer方法
 */
@class LERotateScrollView;
@class iCarousel;

#pragma mark - LERotateScrollViewDataSource
@protocol LERotateScrollViewDataSource <NSObject>

@required
- (NSUInteger) numberOfPageInRotateScrollView : (LERotateScrollView *) rotateScrollView;
- (UIView *) rotateScrollView :(LERotateScrollView *) rotateScrollView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@end

#pragma mark - LERotateScrollViewDelegate
@protocol LERotateScrollViewDelegate <NSObject>

@optional
- (BOOL) leRotateScrollViewWarp : (LERotateScrollView *) rotateScrollView;
- (void) leRotateScrollView : (LERotateScrollView *) rotateScrollView didClickPageAtIndex : (NSInteger) index;
- (void) leRotateScrollView : (LERotateScrollView *) rotateScrollView didMovedToPageAtIndex : (NSInteger) index;

@end

#pragma mark - LERotateScrollView
@interface LERotateScrollView : UIView

@property (nonatomic, readonly, strong) iCarousel * iCarouselView;
@property (nonatomic, readonly, strong) UIPageControl * pageControl;

@property (nonatomic, weak) id<LERotateScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<LERotateScrollViewDelegate> delegate;

//是否自动滚动|默认YES
@property (nonatomic, assign, getter=isAutoScrolling) BOOL autoScrolling;
//自动滚动时间间隙
@property (nonatomic, assign) NSTimeInterval timeInterval;
//当前页面
@property (nonatomic, readonly, assign) NSInteger currentPage;

/**
 * 获得实例
 */
+ (id) viewWithFrame : (CGRect) frame;
/**
 * 获得实例
 */
+ (id) view;
/**
 *  初始化界面操作，必需访问super
 */
- (void) setUp;
/**
 * 重新加载数据，自动在主线程中执行逻辑
 */
- (void) reloadData;
/**
 * 停掉计时器
 * 当您启用了autoScrolling，必须在组件持有对象中访问此方法
 */
- (void) abolishTimer;
/**
 * 暂停计时器
 */
- (void) pauseTimer;
/**
 * 恢复计时器
 */
- (void) resumeTimer;
#pragma mark - 必需重写
/**
 *  必需实现的数据逻辑
 */
- (NSUInteger) numberOfPages;
/**
 *  提供页面
 *
 *  @param index 页面所在索引
 *  @param view  复用页面
 */
- (UIView *) viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;
#pragma mark - 可以使用
/**
 *  自动滚动的时常
 *
 *  @return 默认3s
 */
- (NSTimeInterval) timeInterval;
/**
 *  出现了这个页面
 */
- (void) didAppearView : (UIView *) view atIndexPath : (NSInteger) index;

/**
 *  设置翻页组件到底边的距离
 *
 *  @param verticalToBottom 距离
 */
- (void) setPageControlBottomOffset : (CGFloat) verticalToBottom;

@end
