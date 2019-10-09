//
//  AYTaskViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/8.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYTaskViewModel : AYBaseViewModle
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
 *  获取section 标题
 */
- (NSString*) getIndexPathTitle:(NSIndexPath*)indexPath;
/**
 *  轮播图的页数
 */
- (NSUInteger) numberOfPageInRotateScrollView;

/**
 *  轮播图某一页的数据
 */
- (id) objectForPage:(NSInteger)pageIndex;

//更新任务状态
-(void)updateTaskStatus;
/**
 *  获取任务Banner数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getTaskBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

@end

NS_ASSUME_NONNULL_END
