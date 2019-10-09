//
//  ZWNetwork.h
//  BingoDu
//
//  Created by 刘云鹏 on 16/3/18.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import "LEService.h"

#pragma mark - Network For ZW

@interface ZWNetwork : LEService

+ (NSDictionary *) createParamsWithConstruct : (void(^)(NSMutableDictionary * params)) constructBlock;

@end

@interface NSMutableDictionary (ZWParams)

- (void) addValue : (id) value forKey : (id<NSCopying>) key;
- (void) addValue : (id) value forKey : (id<NSCopying>) key inCondition : (BOOL) condiction;
- (void) print;

@end

/*
 * 简易构造请求组
 */
UIKIT_EXTERN id ZWRequestPair(NSString * urlKey,
                              NSString * method,
                              NSDictionary * params,
                              void(^success)(id record),
                              void(^failure)(LEServiceError type, NSError * error));

/*
 * 简易队列请求
 */
UIKIT_EXTERN void ZWQueueRequest(NSArray * (^constructBlock)(),
                                 void (^completion)(NSError * error));
