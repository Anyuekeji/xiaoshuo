//
//  NSObject+LEModelSupport.h
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "NSObject+YYModel.h"
#import "NSObject+NSCoding.h"

/**
 *  @author刘云鹏
 *  @ingroup model
 *  @brief 所有数据模型基本支撑方法|注意所有字段都将非必填
 *  1.提供了JSON到对象的快捷转化
 *  2.提供了简单的归档操作
 *  3.子类需要重写initWithCoder(且调用autoDecode)和encodeWithCoder(且调用autoEncodeWithCoder)方法
 */
@interface NSObject (LEModelSupport) <YYModel>


/**
 *  初始化一个实例
 */
+ (id) item;

/**
 *  依据字典初始化一个实例
 */
+ (id) itemWithDictionary : (NSDictionary *) dictionary;

/**
 *  依据JSON对象初始化一个实例
 *
 *  @param json `NSDictionary`, `NSString` or `NSData`.
 */
+ (id) itemWithJSON : (id) json;

/**
 *  依据数组初始化一个实例数组
 *
 *  @param json `NSDictionary`, `NSString` or `NSData`.
 */
+ (NSArray *) itemsWithArray : (id) json;

#pragma mark - JSONModel Solutions
/**
 *  后台数据字段到Entity属性映射表，如果需要数据转换，请重写本方法｜key:对象属性名,value:json属性名
 *
 *  @return Map
 */
+ (NSDictionary<NSString *, id> *) propertyToKeyPair;

/**
 *  如果属性是一个子对象的集合(只有集合需要)，请用此方法映射|key:对象属性名，value:子类名或者类对象
 *
 *  @return Map
 */
+ (NSDictionary<NSString *, id> *) propertyToClassPair;

#pragma mark - Archive
/**
 *  绝对地址归档|将覆盖之前的文件
 *
 *  @param filePath 绝对文件路径
 *
 *  @return 是否执行成功
 */
- (BOOL) saveToFile : (NSString *) filePath;
/**
 *  Document路径下相对地址路径归档
 *
 *  @param fileName 文件名｜可以带文件路径
 *
 *  @return 是否执行成功
 */
- (BOOL) saveToDocumentWithFileName : (NSString *) fileName;
/**
 *  Caches路径下相对地址路径归档
 *
 *  @param fileName 文件名｜可以带文件路径
 *
 *  @return 是否执行成功
 */
- (BOOL) saveToCachesWithFileName : (NSString *) fileName;
/**
 *  Tmp路径下相对地址路径归档
 *
 *  @param fileName 文件名｜可以带文件路径
 *
 *  @return 是否执行成功
 */
- (BOOL) saveToTmpWithFileName : (NSString *) fileName;

/**
 *  绝对地址解码
 *
 *  @param filePath 绝对文件路径
 *
 *  @return 对象｜nil
 */
+ (id) loadFromFile : (NSString *) filePath;
/**
 *  Documents路径下相对地址解码
 *
 *  @param filePath 绝对文件路径
 *
 *  @return 对象｜nil
 */
+ (id) loadFromDocumentWithFileName : (NSString *) fileName;
/**
 *  Caches路径下相对地址解码
 *
 *  @param filePath 绝对文件路径
 *
 *  @return 对象｜nil
 */
+ (id) loadFromCachesWithFileName : (NSString *) fileName;
/**
 *  Tmp路径下相对地址解码
 *
 *  @param filePath 绝对文件路径
 *
 *  @return 对象｜nil
 */
+ (id) loadFromTmpWithFileName : (NSString *) fileName;

@end
