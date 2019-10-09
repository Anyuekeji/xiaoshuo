//
//  AYCartoonViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"


NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonViewModel : AYBaseViewModle
/**
 *  数据组
 */
- (NSInteger) numberOfSections;
/**
 *  数据行
 */
- (NSInteger) numberOfRowsInSection:(NSInteger)section;

/**
 *  获取对象所在索引
 */
- (NSIndexPath *) indexPathForObject : (id) object;
/**
 *  获取对象
 */
- (id) objectForIndexPath : (NSIndexPath *) indexPath;
/**
 *  是否已经加载完毕
 */
@property (nonatomic, readonly, assign, getter=isNotAnyMoreData) BOOL notAnyMoreData;
/**
 *  轮播图的页数
 */
- (NSUInteger) numberOfPageInRotateScrollView;

/**
 *  轮播图某一页的数据
 */
- (id) objectForPage:(NSInteger)pageIndex;
/**
 *  清除数据
 */
-(void)clearList;

/**
 *  模式
 */
@property (nonatomic, assign) AYFictionViewType viewType;
/**
 *  获取漫画页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取推荐小说页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getRecommendCartoonListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取小说页面数据
 *
 *  @param searchText     搜索文本
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonListBySearchText : (NSString*) searchText refresh:(BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取限时免费漫画页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonFreeListDataByAction : (BOOL) isRefresh success : (void(^)(long endTime)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *  获取热门畅销小说页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonUserBuyListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;


/**
 *  获取随机小说页面数据 用于用户猜一猜
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonGuessListDataBySuccess : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取漫画页面Banner数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
@end

NS_ASSUME_NONNULL_END
