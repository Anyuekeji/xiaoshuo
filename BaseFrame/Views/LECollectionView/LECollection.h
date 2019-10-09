//
//  LECollection.h
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/10.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "UIView+LEAF.h"
#import "LERefreshControl.h"

@protocol LECollectionLazyLoadDelegate;

@interface LECollection : UICollectionView

@property (nonatomic, readonly, strong) LERefreshControl * topRefreshControl;
@property (nonatomic, readonly, strong) LERefreshControl * bottomRefreshControl;
@property (nonatomic, readonly, assign, getter=isSupportTopRefresh) BOOL supportTopRefresh;
@property (nonatomic, readonly, assign, getter=isSupportBottomRefresh) BOOL supportBottomRefresh;

@property (nonatomic, readonly, assign, getter=isInRefreshEvent) BOOL inRefreshEvent;
@property (nonatomic, readonly, assign, getter=isHadRefreshing) BOOL hadRefreshing;

@property (nonatomic, weak) id<LECollectionLazyLoadDelegate> lazyLoadDelegate;

/**
 *  是否取消粘性,如果取消，必须设置stickHeight高度
 */
@property (nonatomic, assign) BOOL cancelStick;
/**
 *  取消粘性后，必须设置这个值才会生效
 */
@property (nonatomic, assign) CGFloat stickHeight;

/**
 *  实例，不带刷新控件
 */
+ (id) collectionView;
/**
 *  实例,带顶部刷新控件
 */
+ (id) collectionViewWithTopRefreshControl : (LERefreshControl *) topRefreshControl;
/**
 *  实例,带底部延时加载控件
 */
+ (id) collectionViewWithBottomRefreshControl : (LERefreshControl *) bottomRefreshControl;
/**
 *  实例，带顶部和底部刷新空间
 */
+ (id) collectionViewWithTopRefreshControl:(LERefreshControl *)topRefreshControl bottomRefreshControl : (LERefreshControl *) bottomRefreshControl;
/**
 *  实例，带顶部和底部刷新空间
 */
+ (id) collectionViewWithFrame : (CGRect) frame topRefreshControl : (LERefreshControl *) topRefreshControl bottomRefreshControl : (LERefreshControl *) bottomRefreshControl;

/**
 *  如果需要刷新控件，请在UITableViewDelegate中将scrollViewDidScroll委托指回
 */
- (void) collectionViewDidScroll : (UIScrollView *) scrollView;
/**
 *  如果需要刷新控件，请在UITableViewDelegate中将scrollViewDidEndDragging:willDecelerate:委托指回
 */
- (void) collectionViewDidEndDragging : (UIScrollView *) scrollView;

/**
 *  只执行一次的刷行动作
 */
- (void) launchRefreshing;
/**
 *  可多次执行
 */
- (void) refreshing;

/**
 *  在非refreshEvent状态下直接重新加载数据，在refreshEvent状态下将等待到超时
 */
- (void) reloadAfterRefreshEvent;

@end

#pragma mark - LazyLoadDelgate
@protocol LECollectionLazyLoadDelegate <NSObject>

@optional
/**
 *  在子线程中的刷新委托,如果实现了ChokeAction:协议，将不调用
 */
- (void) leCollectionRefreshAction;
/**
 *  刷新委托执行完成
 */
- (void) leCollectionRefreshActionDone;
/**
 *  阻塞主线程的刷新委托，需要在执行完成之后调用completeBlock
 *
 *  @param completeBlock 一旦调用，LECollection开始结束动作
 */
- (void) leCollectionRefreshChokeAction : (void(^)(void)) completeBlock;
/**
 *  在子线程中的加载委托,如果实现了ChokeAction:协议，将不调用
 */
- (void) leCollectionLoadMoreAction;
/**
 *  加载委托执行完成
 */
- (void) leCollectionLoadMoreActionDone;
/**
 *  如果依据返回，将决定BottomRefreshControl改变为fetchSpecial状态
 *
 *  @return 是否已经加载所有数据
 */
- (BOOL) leCollectionLoadNotAnyMore;
/**
 *  阻塞主线程的加载委托，需要在执行完成之后调用completeBlock
 *
 *  @param completeBlock 一旦调用，LECollection开始结束动作
 */
- (void) leCollectionLoadMoreChokeAction : (void(^)(void)) completeBlock;
/**
 *  将要开始刷新动作
 */
- (void) leCollectionWillBeginRefreshAction;
/**
 *  将要开始加载动作
 */
- (void) leCollectionWillBeginLoadMoreAction;

@end
