//
//  AYFictionDetailViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

NS_ASSUME_NONNULL_BEGIN

@class AYFictionModel;

@interface AYFictionDetailViewModel : AYBaseViewModle
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
 *  获取小说详情数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getFictionDetailDataByFictionModel:(AYFictionModel*)fictionModel  complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  获取小说推荐
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
-(void)getFictionRecommend:(AYFictionModel*)fictionModel  complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

@end

NS_ASSUME_NONNULL_END
