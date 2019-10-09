//
//  NSMutableArray+LEAF.h
//  LE
//
//  Created by 刘云鹏 on 15/10/14.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (LEAF)

/**
 *  在尾部添加一个对象
 *
 *  @param object 被添加对象
 */
- (void)push:(id)object;

/**
 *  弹出最后一个对象
 *
 *  @return 被弹出来的对象
 */
- (id)pop;

/**
 *  出栈过程，可以弹出目标数量的对象
 *
 *  @param numberOfElements 弹出个数
 *
 *  @return 弹出数组，弹出序堆
 */
- (NSArray *)pop:(NSUInteger)numberOfElements;

/**
 *  组合数组
 *
 *  @param array 被组合数组
 */
- (void)concat:(NSArray *)array;

/**
 *  左移一位，最左对象被推出
 *
 *  @return 最左对象
 */
- (id)shift;

/**
 *  左移多位，被移除对象被推出
 *
 *  @param numberOfElements 移位数据
 *
 *  @return 移除数组
 */
- (NSArray *)shift:(NSUInteger)numberOfElements;

/**
 *  过滤数组，通过过滤条件block的对象将被保留
 *
 *  @param block 过滤block
 *
 *  @return 过滤后的数组
 */
- (NSArray *)keepIf:(BOOL (^)(id object))block;

@end
