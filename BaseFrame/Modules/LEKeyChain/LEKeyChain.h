//
//  LEKeyChain.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/15.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEKeyChain : NSObject
+ (void)saveObject:(id)object forKey:(NSString *)key;
+ (id)readObjectForKey:(NSString *)key;
+ (void)deleteObjectForKey:(NSString *)key;
+ (void)deleteAllObject;
@end



@interface LESaveKeyChain : NSObject

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKey:(NSString *)service;

@end
NS_ASSUME_NONNULL_END
