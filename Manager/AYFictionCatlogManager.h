//
//  AYFictionCatlogManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CYFictionChapterModel;

@interface AYFictionCatlogManager : NSObject

singleton_interface(AYFictionCatlogManager)

/**
 *获取小说目录
 *refresh : 是否强制刷新
 */
-(void)fetchFictionCatlogWithFictionId:(NSString*)fictionId refresh:(BOOL)refresh success : (void(^)(NSArray<CYFictionChapterModel*> * fictionCatlogArray)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *清空缓存
 */
-(void)clearData;
@end

NS_ASSUME_NONNULL_END
