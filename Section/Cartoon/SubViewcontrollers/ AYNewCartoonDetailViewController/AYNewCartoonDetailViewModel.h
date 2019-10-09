//
//  AYNewCartoonDetailViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/4/7.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

@class AYCartoonModel;
@class AYCartoonDetailModel;


NS_ASSUME_NONNULL_BEGIN

@interface AYNewCartoonDetailViewModel : AYBaseViewModle
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

@property(nonatomic,strong) AYCartoonDetailModel *cartoonDetailModel; //小说总章节数
/**
 *  获取小说详情数据
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
- (void) getCartoonDetailDataByCartoonModel:(AYCartoonModel*) cartoonModel complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;


/**
 *  获取漫画推荐
 *
 *  @param completeBlock 成功回调
 *  @param failureBlock  失败回调
 */
-(void)getCartoonRecommend:(AYCartoonModel*) cartoonModel complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

@end

NS_ASSUME_NONNULL_END
