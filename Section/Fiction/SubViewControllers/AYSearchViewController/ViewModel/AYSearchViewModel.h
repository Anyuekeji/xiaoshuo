//
//  AYSearchViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/13.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYSearchViewModel : AYBaseViewModle
/**
 *  数据组
 */
- (NSInteger) numberOfSections;
/**
 *  数据行
 */
- (NSInteger) numberOfRowsInSection:(NSInteger)section;
/**
 *  获取对象
 */
- (id) objectForIndexPath : (NSIndexPath *) indexPath;

/**
 *  获取热门搜索数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getHotSearchListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取人气书籍数据
 *
 *  @param isRefresh     是否刷新动作
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getHotBookListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
@end

NS_ASSUME_NONNULL_END
