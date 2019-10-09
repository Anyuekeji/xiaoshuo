//
//  AYCartoonCatlogMananger.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AYCartoonChapterModel;

@interface AYCartoonCatlogMananger : NSObject
singleton_interface(AYCartoonCatlogMananger)

/**
 *获取漫画目录
 *refresh : 是否强制刷新
 */
-(void)fetchCartoonCatlogWithCartoonId:(NSString*)cartoonId refresh:(BOOL)refresh success : (void(^)(NSArray<AYCartoonChapterModel*> * cartoonCatlogArray,int count_all,NSString *update_day)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *清空缓存
 */
-(void)clearData;
@end

NS_ASSUME_NONNULL_END
