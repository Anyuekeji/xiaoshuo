//
//  AYSignManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYSignManager : NSObject
singleton_interface(AYSignManager)
//预加载签到数据
-(void)loadSignList: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
//预加载连续签到天数
-(void)loadUserSignNumDay: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
//加载所有数据
-(void)loadAllData: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
@end

NS_ASSUME_NONNULL_END
