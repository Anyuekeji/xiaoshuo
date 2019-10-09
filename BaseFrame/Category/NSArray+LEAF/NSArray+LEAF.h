//
//  NSArray+LEAF.h
//  LE
//
//  Created by 刘云鹏 on 15/10/14.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (LEAF)

/**
 *  第一个对象
 *
 *  @return 数组中第一个对象
 */
- (id) first;

/**
 *  最后一个对象
 *
 *  @return 数组中最后一个对象
 */
- (id) last;

/**
 *  随机对象
 *
 *  @return 返回数组中随机一个对象
 */
- (id) sample;

/**
 *  取指定下标范围的子数组
 *
 *  @param key @"1..2"｜NSRange的NSValue封装
 *
 *  @return 子数组
 */
- (id)objectForKeyedSubscript:(id <NSCopying>)key;

/**
 *  遍历过程
 *
 *  @param block 遍历block
 */
- (void)each:(void (^)(id object))block;

/**
 *  遍历过程
 *
 *  @param block 遍历block
 */
- (void)eachWithIndex:(void (^)(id object, NSUInteger index))block;

/**
 *  是否包含
 *
 *  @param object 对象
 *
 *  @return 是否包含
 */
- (BOOL)includes:(id)object;

/**
 *  截取子数组，numberOfElements是上值，如果超出数组界限不会影响截取
 *
 *  @param numberOfElements 截取上限定
 *
 *  @return 子数组｜全数组
 */
- (NSArray *)take:(NSUInteger)numberOfElements;

/**
 *  截取子数组，通过block判定返回为true才纳入
 *
 *  @param block 执行过滤的block
 *
 *  @return 子数组
 */
- (NSArray *)takeWhile:(BOOL (^)(id object))block;

/**
 *  映射数组，通过block执行映射关系，返回对象为新数组对象
 *
 *  @param block 映射关系block
 *
 *  @return 映射后数组
 */
- (NSArray *)map:(id (^)(id object))block;

/**
 *  过滤数组，只有通过block过滤结果为YES的才添加到新数组
 *
 *  @param block 过滤执行block
 *
 *  @return 过滤后的结果数组
 */
- (NSArray *)select:(BOOL (^)(id object))block;

/**
 *  过滤数组，返回符合过滤标准的第一个对象
 *
 *  @param block 过滤执行block
 *
 *  @return 符合过滤结果的第一个对象
 */
- (id)detect:(BOOL (^)(id object))block;

/**
 *  过滤数组，返回符合过滤标准的第一个对象
 *
 *  @param block 过滤执行block
 *
 *  @return 符合过滤结果的第一个对象
 */
- (id)find:(BOOL (^)(id object))block;

/**
 *  过滤（过滤）数组，如果block过滤条件放回为NO将添加到新数组，与select反
 *
 *  @param block 过滤条件
 *
 *  @return 被过滤的数组
 */
- (NSArray *)reject:(BOOL (^)(id object))block;

/**
 *  扁平化数组，如果数组对象有数组，将被提取出来
 *
 *  @return 扁平后的数组
 */
- (NSArray *)flatten;

/**
 *  字符串表示
 *
 *  @return 字符串表示
 */
- (NSString *)join;

/**
 *  字符串表示，通过分割符
 *
 *  @param separator 分隔符
 *
 *  @return 字符串表示
 */
- (NSString *)join:(NSString *)separator;

/**
 *  排序，自动排序过程
 *
 *  @return 通过compare方法比较每个对象
 */
- (NSArray *)sort;

/**
 *  排序
 *
 *  @param key 关键字排序
 *
 *  @return 排序后的数组
 */
- (NSArray *)sortBy:(NSString*)key;

/**
 *  逆向数组
 *
 *  @return 逆向数组
 */
- (NSArray *)reverse;

/**
 *  交集运算
 *
 *  @param array 被交数组
 *
 *  @return 交集结果
 */
- (NSArray *)intersectionWithArray:(NSArray *)array;

/**
 *  并集运算
 *
 *  @param array 被并数组
 *
 *  @return 并集结果
 */
- (NSArray *)unionWithArray:(NSArray *)array;

/**
 *  非交集，在本身数组中但不在目标数组中的对象集合
 *
 *  @param array 目标数组
 *
 *  @return 非交集
 */
- (NSArray *)relativeComplement:(NSArray *)array;

/**
 *  与非集合，不在两者交集内的所有对象的数组集合
 *
 *  @param array 被与非数组
 *
 *  @return 与非集合
 */
- (NSArray *)symmetricDifference:(NSArray *)array;

@end
