//
//  NSDictionary+LEAF.h
//  LE
//
//  Created by 刘云鹏 on 15/10/14.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LEAF)

/**
 *  遍历字典
 *
 *  @param block 遍历过程
 */
- (void)each:(void (^)(id key, id value))block;

/**
 *  遍历字典
 *
 *  @param block 遍历过程
 */
- (void)eachKey:(void (^)(id key))block;

/**
 *  遍历过程
 *
 *  @param block 遍历过程
 */
- (void)eachValue:(void (^)(id value))block;

/**
 *  映射过程，映射后的对象数组
 *
 *  @param block 映射过程
 *
 *  @return 映射结果数组
 */
- (NSArray *)map:(id (^)(id key, id value))block;

/**
 *  是否包含某个key对象
 *
 *  @param key 键
 *
 *  @return 是否包含
 */
- (BOOL)hasKey:(id)key;

@end
