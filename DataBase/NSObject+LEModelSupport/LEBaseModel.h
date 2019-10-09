//
//  LEBaseModel.h
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "NSObject+LEModelSupport.h"
#import <Realm/Realm.h>
#import "LERMLUpgradeProtocol.h"

/**
 *  @author liuyunpeng
 *  @ingroup model
 *  @brief 所有数据模型基本父类
 *  1.本对象子类不包含数据库存储，包涵JSON转换和归档方法
 *  2.支持所有数据对象类型
 */
@interface LEBaseModel : NSObject

@end

/**
 *  @author liuyunpeng
 *  @ingroup model
 *  @brief 所有数据模型基本父类|包含数据库存储
 *  1.注意仅支持如下属性类型：BOOL, bool, int, NSInteger, long, long long, float, double, NSString, NSDate, NSData, and NSNumber
 *  2.其他属性请过滤｜或者转换成可存储类型
 *  3.NSNumber必须指定协议RLMBool，RLMInt，RLMFloat，RLMDouble
 */
@interface LEDBBaseModel : RLMObject <LERMLUpgradeProtocol, NSCoding, NSCopying>

#pragma mark - RLMObject
/**
 *  在数据库中添加或者更新本对象
 */
- (void) r_saveOrUpdate;
/**
 *  在数据库中更新或添加一组数据
 *  @param toSaveOrUpdateArray  An `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be deleted.
 */
+ (void) r_saveOrUpdates : (id) toSaveOrUpdateArray;
/**
 *  事务块，用于更新数据库內的内容的事务包裹方法，所有数据库对象的属性变更都要在此方法內执行
 *
 *  @param ^ 更新数据库对象执行block，事务不会有回滚
 */
- (void) r_noRevertTransaction:(void(^)(void))block;
/**
 *  在数据库中删除本对象
 */
- (void) r_delete;
/**
 *  在数据库中删除一组数据
 *  @param toDeleteArray  An `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be deleted.
 */
+ (void) r_deletes : (id) toDeleteArray;
/**
 *  删除所有本对象缓存
 */
+ (void) r_deleteAll;
/**
 *  查询一组数据
 *
 *  @param queryString 查询字符串
 */
+ (NSArray *) r_query : (NSString *) queryString;
/**
 *  按需查询一组数据
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 */
+ (NSArray *) r_query : (NSString *) queryString
            sortProperty : (NSString *) propertyName
               ascending : (BOOL) isAscending;
/**
 *  按需查询一定数量的一组数据|从offset开始，长度小于等于countLimit
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 *  @param offset       偏移
 *  @param countLimit   返回数据组大小
 */
+ (NSArray *) r_query : (NSString *) queryString
         sortProperty : (NSString *) propertyName
            ascending : (BOOL) isAscending
               offset : (NSUInteger) offset
                limit : (NSUInteger) countLimit;
/**
 *  获取所有数据，返回一定数量的一组数据｜从offset开始，长度小于等于countLimit
 *
 *  @param offset     偏移
 *  @param countLimit 返回数据组大小
 */
+ (NSArray *) r_queryOffset : (NSUInteger) offset
                      limit : (NSUInteger) countLimit;
/**
 *  按需查询一定数据的一组数据｜第page页内容，长度小于等于pageSize
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 *  @param page         页号｜从0开始
 *  @param pageSize     页数据量
 */
+ (NSArray *) r_query : (NSString *) queryString
         sortProperty : (NSString *) propertyName
            ascending : (BOOL) isAscending
                 page : (NSUInteger) page
             pageSize : (NSUInteger) pageSize;
/**
 *  获取所有数据，返回某一页的数据量｜第page页内容，长度小于等于pageSize
 *
 *  @param page     页号｜从0开始
 *  @param pageSize 页数据量
 */
+ (NSArray *) r_queryPage : (NSUInteger) page
                 pageSize : (NSUInteger) pageSize;
/**
 *  查找一个精确的对象，通过primarykey
 */
+ (id) r_queryPrimaryKey : (id) primaryKey;
/**
 *  查询所有缓存的数据对象
 */
+ (NSArray *) r_allObjects;

@end

#import <UIKit/UIKit.h>

/**
 * >>>>>>> 请暂时不要用 <<<<<<<<
 *
 *  事务块,用于更新数据库內的内容的事务包裹方法。
 *  无需真实存储于数据库中的所有无需数据库对象的属性变更都要在此方法內执行
 *
 *  @param ^ 更新数据库对象执行block,如果返回为NO，本次事务将回滚
 */
//UIKIT_EXTERN void _r_db_update(BOOL(^)());
/**
 *  对象转NSData
 *
 *  @param object 对象需要履行NSCoding
 */
UIKIT_EXTERN NSData * _get_object_data_(id object);
/**
 *  NSData转对象
 *
 *  @param data 数据对象
 */
UIKIT_EXTERN id _get_data_object_(NSData * data);
