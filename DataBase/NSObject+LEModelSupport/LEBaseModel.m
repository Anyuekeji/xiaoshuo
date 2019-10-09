//
//  LEBaseModel.m
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "LEBaseModel.h"
#import <objc/runtime.h>
#import "NSDictionary+LEAF.h"
#import "NSArray+NHZW.h"
#import "ClassProperty.h"
#import "ZWCacheHelper.h"
#import "NSString+PJR.h"


static inline BOOL _ZWIsRealmObjectClsName(NSString *clsName) {
    return ([clsName containsString:@"RLMAccessor"] ||
            [clsName containsString:@"RLMUnmanaged"]);
}

static inline BOOL _ZWCanCacheInRealmClsName(NSString *clsName) {
    if ( [clsName isValid] ) {
        Class cls = NSClassFromString(clsName);
        return (cls && [cls isSubclassOfClass:ZWDBBaseModel.class] &&
                [cls conformsToProtocol:@protocol(ZWCacheProtocol)]);
    }
    return NO;
}

@interface ClassPropertyHelper : NSObject
/**  属性名称（不能为空) */
@property (nonatomic, copy, nonnull) NSString *propertyKey;
/**  属性值（不能为空) */
@property (nonatomic, copy, nonnull) NSArray *propertyValue;
+ (instancetype)propertyKey:(NSString *)key value:(NSArray *)value;
- (instancetype)initPropertyKey:(NSString *)key value:(NSArray *)value NS_DESIGNATED_INITIALIZER;
@end

@implementation ClassPropertyHelper
- (instancetype)init {
    return [self initPropertyKey:nil value:nil];
}

+ (instancetype)propertyKey:(NSString *)key value:(NSArray *)value {
    return [[self alloc] initPropertyKey:key value:value];
}

- (instancetype)initPropertyKey:(NSString *)key value:(NSArray *)value {
    self = [super init];
    if (self) {
        self.propertyKey = key;
        self.propertyValue = value;
    }
    return self;
}
@end

@implementation LEBaseModel

#pragma mark - NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super init] ) {
        [self autoDecode:aDecoder];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [self autoEncodeWithCoder:aCoder];
}

@end

@implementation LEDBBaseModel

#pragma mark - Private
+ (NSDictionary *) _dictionaryWithJSON : (id) json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

+ (NSArray *) _arrayWithJSON : (id) json {
    if (!json) return nil;
    NSArray *arr = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        arr = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![arr isKindOfClass:[NSArray class]]) arr = nil;
    }
    return arr;
}

+ (instancetype) _modelWithDictionary : (NSDictionary *) dictionary {
    //转换数据映射关系
    NSDictionary<NSString *, id> * _modelCustomPropertyMapper = [self modelCustomPropertyMapper];
    if ( _modelCustomPropertyMapper && _modelCustomPropertyMapper.count > 0 ) {
        NSMutableDictionary * _cDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        [_modelCustomPropertyMapper enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ( [dictionary hasKey:obj] ) {
                [_cDictionary setObject:dictionary[obj] forKey:key];
            }
        }];
        dictionary = _cDictionary;
    }
    // 取出内部数组
    NSDictionary<NSString *, id> * _modelContainerPropertyGenericClass = [self modelContainerPropertyGenericClass];
    NSMutableArray<ClassPropertyHelper *> *_genericClassArr = [NSMutableArray array];
    if ( _modelContainerPropertyGenericClass && _modelContainerPropertyGenericClass.count > 0 ) {
        NSMutableDictionary * _tempDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        [_modelContainerPropertyGenericClass enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ( [dictionary hasKey:key] ) {
                [_tempDict removeObjectForKey:key];
                // 需要将属性实例化成ClassName的对象
                Class curClass = nil;
                Class meta = object_getClass(obj);
                if (!meta) return;
                if (class_isMetaClass(meta)) {
                    curClass = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        curClass = cls;
                    }
                }
                // 递归实例化属性对象
                ClassPropertyHelper *helper = nil;
                if ( curClass && [curClass isSubclassOfClass:LEDBBaseModel.class] ) {
                    NSArray *propertyGenerics = [curClass itemsWithArray:dictionary[key]];
                    if ( propertyGenerics && propertyGenerics.count > 0 ) {
                        helper = [ClassPropertyHelper propertyKey:key value:propertyGenerics];
                    }
                }
                //
                if ( helper ) {
                    [_genericClassArr addObject:helper];
                }
            }
        }];
        dictionary = _tempDict;
    }
    
    id instance = [[self alloc] initWithValue:dictionary];
    // 赋值
    if ( _genericClassArr.count > 0 ) {
        [_genericClassArr enumerateObjectsUsingBlock:^(ClassPropertyHelper * _Nonnull helper, NSUInteger idx, BOOL * _Nonnull stop) {
            [instance setValue:helper.propertyValue forKeyPath:helper.propertyKey];
        }];
    }
    
    return instance;
}

#pragma mark - Override
//+ (instancetype) itemWithJSON:(id)json {
//    return [self _modelWithDictionary:[self _dictionaryWithJSON:json]];
//}
//
//+ (instancetype) itemWithDictionary:(NSDictionary *)dictionary {
//    return [self _modelWithDictionary:dictionary];
//}
//
//+ (NSArray *) itemsWithArray:(id)json {
//    if ( !json ) return nil;
//    NSArray * jsonArray = [self _arrayWithJSON:json];
//    if ( !jsonArray ) return nil;
//    NSMutableArray *result = [NSMutableArray new];
//    for ( NSDictionary * dic in jsonArray ) {
//        if (![dic isKindOfClass:[NSDictionary class]]) continue;
//        NSObject * obj = [self itemWithDictionary:dic];
//        if (obj) [result addObject:obj];
//    }
//    return result;
//}

#pragma mark - NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super init] ) {
        [self autoDecode:aDecoder];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [self autoEncodeWithCoder:aCoder];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    NSString *clsName = NSStringFromClass(self.class);
    
    while (_ZWIsRealmObjectClsName(clsName)) {
        clsName = NSStringFromClass(self.superclass);
    }

    if (!_ZWCanCacheInRealmClsName(clsName)) {
        return nil;
    }
    
    Class cls = NSClassFromString(clsName);
    id item = [[cls allocWithZone:zone] init];
    if ( item /**&& [item isKindOfClass:cls]*/ ) {
        for (NSString *_key in [ClassProperty getPropertyDictionaryForClass:cls]) {
            @autoreleasepool {
                NSString *key = _key;
                if ([key hasPrefix:@"_"]) {
                    key = [key substringFromIndex:1];
                }
                if ( key && [self valueForKey:key] ) {
                    [item setValue:[self valueForKey:key] forKey:key];
                }
            }
        }
    }
    return item;
}

#pragma mark - RLMObject
/**
 *  在数据库中添加或者更新本对象
 */
- (void) r_saveOrUpdate {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    [ZWCacheHelper saveOrUpdate:self];
#pragma clang diagnostic pop
}

/**
 *  在数据库中更新或添加一组数据
 */
+ (void) r_saveOrUpdates : (id) toSaveOrUpdateArray {
    [ZWCacheHelper saveOrUpdate:self items:toSaveOrUpdateArray];
}

/**
 *  事务块，用于更新数据库內的内容的事务包裹方法，所有数据库对象的属性变更都要在此方法內执行
 *
 *  @param ^ 更新数据库对象执行block，事务不会有回滚
 */
- (void) r_noRevertTransaction:(void(^)(void))block {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    [ZWCacheHelper item:self noRevertTransaction:block];
#pragma clang diagnostic pop
}
/**
 *  在数据库中删除本对象
 */
- (void) r_delete {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    [ZWCacheHelper deleteItem:self];
#pragma clang diagnostic pop
}

/**
 *  在数据库中删除一组数据
 */
+ (void) r_deletes : (id) toDeleteArray {
    [ZWCacheHelper deleteItems:toDeleteArray];
}

/**
 *  删除所有本对象缓存
 */
+ (void) r_deleteAll {
    [ZWCacheHelper deleteAllItems:self];
}

/**
 *  查询一组数据
 *
 *  @param queryString 查询字符串
 */
+ (NSArray *) r_query : (NSString *) queryString {
    return [ZWCacheHelper queryItem:self usingQueryKey:queryString];
}

/**
 *  按需查询一组数据
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 */
+ (NSArray *) r_query : (NSString *) queryString sortProperty : (NSString *) propertyName ascending : (BOOL) isAscending {
    return [ZWCacheHelper queryItem:self usingQueryKey:queryString sortProperty:propertyName ascending:isAscending];
}

/**
 *  按需查询一定数量的一组数据|从offset开始，长度小于等于countLimit
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 *  @param offset       偏移
 *  @param countLimit   返回数据组大小
 */
+ (NSArray *) r_query : (NSString *) queryString sortProperty : (NSString *) propertyName ascending : (BOOL) isAscending offset : (NSUInteger) offset limit : (NSUInteger) countLimit {
    return [ZWCacheHelper queryItem:self usingQueryKey:queryString sortProperty:propertyName ascending:isAscending offset:offset limit:countLimit];
}
/**
 *  获取所有数据，返回一定数量的一组数据｜从offset开始，长度小于等于countLimit
 *
 *  @param offset     偏移
 *  @param countLimit 返回数据组大小
 */
+ (NSArray *) r_queryOffset : (NSUInteger) offset limit : (NSUInteger) countLimit {
    return [self r_query:nil sortProperty:nil ascending:NO offset:offset limit:countLimit];
}
/**
 *  按需查询一定数据的一组数据｜第page页内容，长度小于等于pageSize
 *
 *  @param queryString  查询字符串
 *  @param propertyName 排序属性名
 *  @param isAscending  是否升序
 *  @param page         页号｜从0开始
 *  @param pageSize     页数据量
 */
+ (NSArray *) r_query : (NSString *) queryString sortProperty : (NSString *) propertyName ascending : (BOOL) isAscending page : (NSUInteger) page pageSize : (NSUInteger) pageSize {
    return [self r_query:queryString sortProperty:propertyName ascending:isAscending offset:page * pageSize limit:pageSize];
}
/**
 *  获取所有数据，返回某一页的数据量｜第page页内容，长度小于等于pageSize
 *
 *  @param page     页号｜从0开始
 *  @param pageSize 页数据量
 */
+ (NSArray *) r_queryPage : (NSUInteger) page pageSize : (NSUInteger) pageSize {
    return [self r_queryOffset:page * pageSize limit:pageSize];
}
/**
 *  查询所有缓存的数据对象
 */
+ (NSArray *) r_allObjects {
    return [ZWCacheHelper allObjects:self];
}
/**
 *  查找一个精确的对象，通过primarykey
 */
+ (id) r_queryPrimaryKey : (id) primaryKey {
    return [ZWCacheHelper queryItem:self usingPrimaryKey:primaryKey];
}

#pragma mark - LERMLUpgradeProtocol
/**
 *  属性值合并或者转移可以实现此方法
 *
 *  @param oldSchemaVersion 版本号变更
 */
+ (void(^)(RLMObject * oldObject, RLMObject * newObject)) upgradePropertyAssignedValueChangedForSchemaVersion : (uint64_t) oldSchemaVersion {
    return nil;
}

/**
 *  属性名称变更实现此方法，映射关系为旧属性名->新属性名
 *
 *  @param oldSchemaVersion 版本号变更
 *
 *  @return 旧－>新属性名映射关系
 */
+ (NSDictionary<NSString *, NSString *> *) upgradePropertyNameModyfiedForSchemaVersion : (uint64_t) oldSchemaVersion {
    return nil;
}

@end

/**
 *  事务块,用于更新数据库內的内容的事务包裹方法，所有数据库对象的属性变更都要在此方法內执行
 *
 *  @param ^ 更新数据库对象执行block,如果返回为NO，本次事务将回滚
 */
/*
UIKIT_EXTERN void _r_db_update(BOOL(^updateActions)()) {
    RLMRealm * realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    if ( updateActions() ) {
        [realm commitWriteTransaction];
    } else {
        [realm cancelWriteTransaction];
    }
}
 */

/**
 *  对象转NSData
 *
 *  @param object 对象需要履行NSCoding
 */
UIKIT_EXTERN NSData * _get_object_data_(id object) {
    if ( [object conformsToProtocol:@protocol(NSCoding)] ) {
        return [NSKeyedArchiver archivedDataWithRootObject:object];
    }
    return nil;
}
/**
 *  NSData转对象
 *
 *  @param data 数据对象
 */
UIKIT_EXTERN id _get_data_object_(NSData * data) {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

