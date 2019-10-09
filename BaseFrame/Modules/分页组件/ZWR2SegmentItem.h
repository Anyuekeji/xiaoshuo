//
//  ZWRSegmentItem.h
//  CallU
//
//  Created by Leaf on 2017/3/27.
//  Copyright © 2017年 2.1.6. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZWR2SegmentItem;

@protocol ZWR2SegmentViewControllerProtocol <NSObject>

@required
/**
 通过此方法返回实例

 @param object 数据对象
 @return 实例控制器
 */
+ (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewControllerWithSegmentRegisterItem : (id) object segmentItem : (ZWR2SegmentItem *) segmentItem;

@optional
/**
 *  如果主界面是一个ScrollView或者其子类请在这里返回｜为了ZWRSlideSegmentViewController滚动动画
 */
- (UIScrollView *) scrollView;
/**
 *  当从显示栏位移除的时候会调用此方法，可实现相关移除逻辑
 */
- (void) segmentDidRemoveViewController;
/**
 *  当进入显示栏位的时候将会调用此方法，可实现相关逻辑
 */
- (void) segmentDidLoadViewController;
/**
 *  如果主界面触发viewWillAppear:｜切换到本页面，将同时访问当前已经显示页面的此方法
 */
- (void) segmentViewWillAppear;
/**
 *  如果主界面触发viewWillDisappear:｜从本页面切走，将同时访问当前已经显示页面的此方法
 */
- (void) segmentViewWillDisappear;

@end

/**
 用来构造分页控制器数据源的对象：注意控制器内不能强指针持有本对象，否则会有引用循环
 */
@interface ZWR2SegmentItem : NSObject

/** 寄存对象，用来生成控制器 */
@property (nonatomic, strong) id registerItem;
/** 段名称 */
@property (nonatomic, strong) NSString * segmentTitle;
/** 段唯一标示 */
@property (nonatomic, strong) id segmentIdentifier;
/** 需要实例的类对象 */
@property (nonatomic, strong) Class<ZWR2SegmentViewControllerProtocol> viewControllerClass;

@property (nonatomic, strong) UIViewController<ZWR2SegmentViewControllerProtocol> * viewController;

+ (ZWR2SegmentItem *) segmentItemWithIdentifier : (id) segmentIdentifier
                                          title : (NSString *) title
                         forViewControllerClass : (Class<ZWR2SegmentViewControllerProtocol>) clazz
                                   registerItem : (id) registerItem;


- (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewController;

- (BOOL) isCreatedViewController;

@end
