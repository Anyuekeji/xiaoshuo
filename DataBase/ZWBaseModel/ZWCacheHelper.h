//
//  ZWCacheHelper.h
//  BingoDu
//
//  Created by liuyunpeng on 16/12/5.
//  Copyright © 2016年 2.1.6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZWBaseModel.h"
#import "ZWCacheProtocol.h"

/**
 *  事务块，用于更新数据库內的内容的事务包裹方法，所有数据库对象的属性变更都要在此方法內执行
 *  注意：不会影响数据库存储的数据，仅做赋值用
 *  @param ^ 更新数据库对象执行block，事务不会有回滚
 */
UIKIT_EXTERN void _reset_db_item_(void(^updateActions)());
UIKIT_EXTERN NSArray<ZWDBBaseModel *> *_ZWConvertRLMArryToArray(RLMArray *results);
@interface ZWCacheHelper : NSObject
+ (instancetype)sharedInstance;

/**
 *  在数据库中添加或者更新本对象
 */
+ (void)saveOrUpdate:(ZWDBBaseModel<ZWCacheProtocol> *)item;

/**
 *  在数据库中更新或添加一组数据
 *  @param toSaveOrUpdateArray  An `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be deleted.
 */
+ (void)saveOrUpdate:(Class)itemClass items:(id)toSaveOrUpdateArray;

/**
 *  事务块，用于更新数据库內的内容的事务包裹方法，所有数据库对象的属性变更都要在此方法內执行
 *
 *  @param ^ 更新数据库对象执行block，事务不会有回滚
 */
+ (void)item:(ZWDBBaseModel<ZWCacheProtocol>*)item noRevertTransaction:(void(^)(void))block;

/**
 *  在数据库中删除本对象
 */
+ (void)deleteItem:(ZWDBBaseModel<ZWCacheProtocol> *)item;

/**
 *  在数据库中删除一组数据
 *  @param toDeleteArray  An `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be deleted.
 */
+ (void)deleteItems:(id)toDeleteArray;

/**
 *  删除所有本对象缓存
 */
+ (void)deleteAllItems:(Class)itemClass;

/**
 *  查询一组数据
 *
 *  @param queryString 查询字符串
 */
+ (NSArray<ZWDBBaseModel *> *)queryItem:(Class)itemClass usingQueryKey:(NSString *)queryString;

/**
 *  按需查询一组数据
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 */
+ (NSArray<ZWDBBaseModel *> *)queryItem:(Class)itemClass
            usingQueryKey:(NSString *)queryString
             sortProperty:(NSString *)propertyName
                ascending:(BOOL)isAscending;
/**
 *  按需查询一定数量的一组数据|从offset开始，长度小于等于countLimit
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 *  @param offset       偏移
 *  @param countLimit   返回数据组大小
 */
+ (NSArray *)queryItem:(Class)itemClass
         usingQueryKey:(NSString *)queryString
          sortProperty:(NSString *)propertyName
             ascending:(BOOL)isAscending
                offset:(NSUInteger)offset
                 limit:(NSUInteger)countLimit;

/**
 *  查找一个精确的对象，通过primarykey
 */
+ (id)queryItem:(Class)itemClass usingPrimaryKey:(id)primaryKey;
/**
 *  查询所有缓存的数据对象
 */
+ (NSArray *)allObjects:(Class)itemClass;

/**
 *  删除所有的缓存
 */
+ (void)deleteAllCatche;
@end
