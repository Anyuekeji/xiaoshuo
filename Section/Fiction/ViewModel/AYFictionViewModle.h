//
//  AYFictionVIewModle.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"


NS_ASSUME_NONNULL_BEGIN

@interface AYFictionViewModle : AYBaseViewModle
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
 *  清除数据
 */
-(void)clearList;
/**
 *  是否已经加载完毕
 */
@property (nonatomic, readonly, assign, getter=isNotAnyMoreData) BOOL notAnyMoreData;
/**
 *  模式 
 */
@property (nonatomic, assign) AYFictionViewType viewType;
/**
 *  轮播图的页数
 */
- (NSUInteger) numberOfPageInRotateScrollView;

/**
 *  轮播图某一页的数据
 */
- (id) objectForPage:(NSInteger)pageIndex;

/**
 *  获取section 标题
 */
- (NSString*) getSectionTitle:(NSInteger)section;
/**
 *  获取section icon
 */
- (NSString*) getSectionIcon:(NSInteger)section;

/**
 *  获取 section 标题 index
 */
- (NSInteger) getSectionIndex:(NSString*)title;
/**
 *  获取用户最爱小说页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFictionListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *  获取推荐小说页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getRecommendFictionListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *  获取小说页面数据
 *
 *  @param searchText     搜索文本
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFictionListDataBySearchText : (NSString*) searchText refresh:(BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;


/**
 *  获取限时免费小说页面数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFictionFreeListDataByAction : (BOOL) isRefresh success : (void(^)()) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取限时免费小说页面数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getTimeFictionFreeListDataByAction : (BOOL) isRefresh success : (void(^)(long endTime)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取热门畅销小说页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFictionUserBuyListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;


/**
 *  获取随机小说页面数据 用于用户猜一猜
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFictionGuessListDataBySuccess : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取精品漫画数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getRecommendCartoonDataByAction: (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取小说页面Banner数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFictionBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取漫画页面Banner数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *  获取免费页面Banner数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFreeBookBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *  获取漫画页面数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
@end

NS_ASSUME_NONNULL_END
