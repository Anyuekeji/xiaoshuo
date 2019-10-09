//
//  ZWCacheHelper.m
//  BingoDu
//
//  Created by huangpan on 16/12/5.
//  Copyright © 2016年 2.1.6. All rights reserved.
//

#import "ZWCacheHelper.h"
#import "ClassProperty.h"
#import "YYThreadSafeDictionary.h"
#import "YYThreadSafeArray.h"
#import "NSString+PJR.h"

/**
 *  事务块，用于更新数据库內的内容的事务包裹方法，所有数据库对象的属性变更都要在此方法內执行
 *  注意：不会影响数据库存储的数据，仅做赋值用
 *  @param ^ 更新数据库对象执行block，事务不会有回滚
 */
UIKIT_EXTERN void _reset_db_item_(void(^updateActions)(void)) {
    if (updateActions) {
        [[RLMRealm defaultRealm] transactionWithBlock:updateActions];
    }
}
UIKIT_EXTERN NSArray<ZWDBBaseModel *> *_ZWConvertRLMResultsToArray(RLMResults *results) {
    if ( results.count != 0 ) {
        NSMutableArray *tmp = [NSMutableArray array];
        for (NSUInteger i = 0; i < results.count; i++) {
            @autoreleasepool {
                ZWDBBaseModel *item = [results objectAtIndex:i];
                id copyItem = [item copy];
                if (copyItem) [tmp addObject:copyItem];
            }
        }
        return [tmp copy];
    }
    return nil;
}
UIKIT_EXTERN NSArray<ZWDBBaseModel *> *_ZWConvertRLMArryToArray(RLMArray *results) {
    if ( results.count != 0 ) {
        NSMutableArray *tmp = [NSMutableArray array];
        for (NSUInteger i = 0; i < results.count; i++) {
            @autoreleasepool {
                ZWDBBaseModel *item = [results objectAtIndex:i];
//                id copyItem = [item copy];
//                if (copyItem) {
//                    [tmp addObject:copyItem];
//                }
                [tmp addObject:item];

            }
        }
        return [tmp copy];
    }
    return nil;
}

/**
 是否是有效的实例对象
 */
static inline BOOL _ZWCanCacheInRealmObject(id aItem) {
    return (aItem && [aItem isKindOfClass:ZWDBBaseModel.class] && [aItem conformsToProtocol:@protocol(ZWCacheProtocol)]);
}

/**
 是否是无效的数据库实例【Defaults YES:是无效实例，NO：有效实例】
 */
static inline BOOL _ZWIsInvalidRealmObject(id item) {
    if (_ZWCanCacheInRealmObject(item)) {
        return [@"[invalid object]" isEqualToString:[NSString stringWithFormat:@"%@",item]];
    }
    return YES;
}

/**
 是否是有效的类
 */
static inline BOOL _ZWCanCacheInRealmObjectClass(Class aClass) {
    return aClass && [aClass isSubclassOfClass:ZWDBBaseModel.class] && [aClass conformsToProtocol:@protocol(ZWCacheProtocol)];
}

/**
 得到当前真实有效的类名（去掉 RLMUnmanaged | RLMAccessor 前缀）
 */
NSString *_ZWGetNativeClassName(ZWDBBaseModel *item) {
    if (item) {
        NSString *clsName = NSStringFromClass(item.class);
        while ([clsName containsString:@"RLMAccessor"] || [clsName containsString:@"RLMUnmanaged"]) {
            clsName = NSStringFromClass(item.superclass);
        }
        return clsName;
    }
    return nil;
}


/**
 是否是同一个类
 */
BOOL _isSameClass(ZWDBBaseModel *copy, ZWDBBaseModel *original) {
    if (_ZWCanCacheInRealmObject(copy) && _ZWCanCacheInRealmObject(original)) {
        NSString *copyClsName = _ZWGetNativeClassName(copy);
        NSString *originalClsName = _ZWGetNativeClassName(original);
        return ([copyClsName isValid] && [copyClsName isEqualToString:originalClsName]);
    }
    return NO;
}

/**
 是否是数组（包括:RLMArray/RLMResults/NSArray）
 */
static inline BOOL _isArray(id keys) {
    return ([keys isKindOfClass:RLMArray.class] ||
            [keys isKindOfClass:NSArray.class]  ||
            [keys isKindOfClass:RLMResults.class]);
}



#pragma mark - RLMRealm (ZWCheckingLeftSpaceOnDevice)
/**
 新增设备剩余空间容量校验
 */
@interface RLMRealm (ZWCheckingLeftSpaceOnDevice)
- (void)commitAddTransactionIfEnoughSpaceOnDevice NS_SWIFT_UNAVAILABLE("");
@end

@implementation RLMRealm (ZWCheckingLeftSpaceOnDevice)
- (void)commitAddTransactionIfEnoughSpaceOnDevice {
    @try {
        [self commitWriteTransaction];
    } @catch (NSException *exception) {
        // 存在异常则放弃此次任务的提交
    }
}
@end



#pragma mark - ZWCacheHelper

@interface ZWCacheHelper () {
    dispatch_semaphore_t _lock;
}
@property (nonatomic, strong) YYThreadSafeDictionary *itemCaches; // 当前缓存
@property (nonatomic, strong) NSMutableDictionary *dbCaches;      // 旧有缓存
@property (nonatomic, strong) YYThreadSafeArray *repeatArray;     // 数据库重复数据
@end

@implementation ZWCacheHelper
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    __strong static id _sharedObject = nil;
    dispatch_once( &onceToken, ^{
        _sharedObject = [[ZWCacheHelper alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    if ( self = [super init] ) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    if ( !_lock ) _lock = dispatch_semaphore_create(1);
    //
    self.repeatArray = [YYThreadSafeArray array];
    self.itemCaches = [YYThreadSafeDictionary dictionary];
    self.dbCaches = [NSMutableDictionary dictionary];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark - Public
/**
 *  在数据库中添加或者更新本对象
 */
+ (void)saveOrUpdate:(ZWDBBaseModel<ZWCacheProtocol> *)item {
    BOOL isUpdate = !![[item class] primaryKey];
    ZWDBBaseModel *copyItem = [[self sharedInstance] _getOrCreateCopyItemByKey:item canUpdate:isUpdate];
    if (!_ZWIsInvalidRealmObject(copyItem)) {
        RLMRealm * realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        if ( isUpdate ) {
            [realm addOrUpdateObject:copyItem];
        } else {
            [realm addObject:copyItem];
        }
        [realm commitAddTransactionIfEnoughSpaceOnDevice];
    }
    // 删除数据库中的重复数据
    [[self sharedInstance] _deleteRepeatItemsFromRealm];
}

/**
 *  在数据库中更新或添加一组数据
 *  @param toSaveOrUpdateArray  An `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be deleted.
 */
+ (void)saveOrUpdate:(Class)itemClass items:(id)toSaveOrUpdateArray {
    if ( !toSaveOrUpdateArray ) return;
    if (_ZWCanCacheInRealmObjectClass(itemClass)) {
        NSArray *copyItems = [[self sharedInstance] _getOrCreateCopyItemsByKeys:toSaveOrUpdateArray canUpdate:[itemClass primaryKey] != nil];
        if ( copyItems.count > 0 ) {
            RLMRealm * realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            if ( [itemClass primaryKey] ) {
                [realm addOrUpdateObjects:copyItems];
            } else {
                [realm addObjects:copyItems];
            }
            [realm commitAddTransactionIfEnoughSpaceOnDevice];
        }
    }
    // 删除重复数据
    [[self sharedInstance] _deleteRepeatItemsFromRealm];
}

/**
 *  事务块，用于更新数据库內的内容的事务包裹方法，所有数据库对象的属性变更都要在此方法內执行
 *
 *  @param ^ 更新数据库对象执行block，事务不会有回滚
 */
+ (void)item:(ZWDBBaseModel<ZWCacheProtocol>*)item noRevertTransaction:(void(^)(void))block {
    if (block) {
        // 更新当前的数据
        block();
        // 更新数据库缓存数据
        ZWDBBaseModel *copyItem = [[self sharedInstance] _getCopyItemByKey:item canUpdate:YES];
        if (!_ZWIsInvalidRealmObject(copyItem)) {
            [[self sharedInstance] _updateCopyItem:copyItem withOriginal:item];
        }
    }
}

/**
 *  在数据库中删除本对象
 */
+ (void)deleteItem:(ZWDBBaseModel<ZWCacheProtocol> *)item {
    if (!_ZWCanCacheInRealmObject(item)) return;
    ZWDBBaseModel *copyItem = [[self sharedInstance] _getCopyItemByKey:item canUpdate:NO];
    if (!_ZWIsInvalidRealmObject(copyItem)) {
        RLMRealm * realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:copyItem];
        [realm commitWriteTransaction];
    }
    // 删除重复数据
    [[self sharedInstance] _deleteRepeatItemsFromRealm];
}

/**
 *  在数据库中删除一组数据
 *  @param toDeleteArray  An `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be deleted.
 */
+ (void)deleteItems:(id)toDeleteArray {
    if ( !toDeleteArray ) return;
    NSArray *copyItems = [[self sharedInstance] _getCopyItemsByKeys:toDeleteArray canUpdate:NO];
    if ( copyItems.count > 0 ) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObjects:copyItems];
        [realm commitWriteTransaction];
    }
    // 删除数据库重复数据
    [[self sharedInstance] _deleteRepeatItemsFromRealm];
}

/**
 *  删除所有本对象缓存
 */
+ (void)deleteAllItems:(Class)itemClass {
    if ( _ZWCanCacheInRealmObjectClass(itemClass) ) {
        [[self sharedInstance] _deleteAllItemsByClass:itemClass];
        RLMRealm * realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObjects:[itemClass allObjects]];
        [realm commitWriteTransaction];
    }
}

/**
 *  查询一组数据
 *
 *  @param queryString 查询字符串
 */
+ (nullable NSArray<ZWDBBaseModel *> *)queryItem:(Class)itemClass usingQueryKey:(NSString *)queryString {
    if (_ZWCanCacheInRealmObjectClass(itemClass)) {
        RLMResults *results = [itemClass objectsWhere:queryString];
        if (!results) {
            return nil;
        }
        NSArray *keys = _ZWConvertRLMResultsToArray(results);
        [[self sharedInstance] _cacheQueryResults:results byKeys:keys];
        return keys;
    }
    return nil;
}

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
                ascending:(BOOL)isAscending {
    if (_ZWCanCacheInRealmObjectClass(itemClass)) {
        RLMResults *results =  [[itemClass objectsWhere:queryString] sortedResultsUsingKeyPath:propertyName ascending:isAscending];
        NSArray *keys = _ZWConvertRLMResultsToArray(results);
        [[self sharedInstance] _cacheQueryResults:results byKeys:keys];
        return keys;
    }
    return nil;
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
+ (NSArray *)queryItem:(Class)itemClass
         usingQueryKey:(NSString *)queryString
          sortProperty:(NSString *)propertyName
             ascending:(BOOL)isAscending
                offset:(NSUInteger)offset
                 limit:(NSUInteger)countLimit {
    if ( !_ZWCanCacheInRealmObjectClass(itemClass) ) return nil;
    NSMutableArray * fetchedArray = [NSMutableArray arrayWithCapacity:countLimit];
    void (^fetchBlock)(RLMResults *) = ^(RLMResults * results) {
        if ( results && results.count > offset ) {
            for ( NSInteger index = offset ; index < offset + countLimit ; index ++ ) {
                if ( results.count > index ) {
                    @autoreleasepool {
                        ZWDBBaseModel *item = [results objectAtIndex:index];
                        ZWDBBaseModel<ZWCacheProtocol> *copyItem = [item copy];
                        [[self sharedInstance] _cacheQueryResultItem:item byKey:copyItem];
                        [fetchedArray addObject:copyItem];
                    }
                } else {
                    break ;
                }
            }
        }
    };
    //
    RLMResults * results = nil;
    if ( queryString == nil ) {
        results = [itemClass allObjects];
        if ( propertyName ) {
            results = [results sortedResultsUsingKeyPath:propertyName ascending:isAscending];
        }
    } else {
        results = [itemClass objectsWhere:queryString];
        if ( propertyName ) {
            results = [results sortedResultsUsingKeyPath:propertyName ascending:isAscending];
        }
    }
    fetchBlock(results);
    // 删除重复数据
   // [[self sharedInstance] _deleteRepeatItemsFromRealm];
    return fetchedArray;
}

/**
 *  查找一个精确的对象，通过primarykey
 */
+ (id)queryItem:(Class)itemClass usingPrimaryKey:(id)primaryKey {
    if ( _ZWCanCacheInRealmObjectClass(itemClass) ) {
        RLMObject *item = [itemClass objectForPrimaryKey:primaryKey];
        if ( !_ZWIsInvalidRealmObject(item) ) {
            ZWDBBaseModel<ZWCacheProtocol> *copyItem = [item copy];
            [[self sharedInstance] _cacheQueryResultItem:item byKey:copyItem];
            // 删除重复数据
         //   [[self sharedInstance] _deleteRepeatItemsFromRealm];
            return copyItem;
        } 
    }
    return nil;
}
/**
 *  查询所有缓存的数据对象
 */
+ (NSArray *)allObjects:(Class)itemClass {
    if ( _ZWCanCacheInRealmObjectClass(itemClass) ) {
        RLMResults *results = [itemClass allObjects];
        NSArray *keys = _ZWConvertRLMResultsToArray(results);
        [[self sharedInstance] _cacheQueryResults:results byKeys:keys];
        return keys;
    }
    return nil;
}


#pragma mark -

#pragma mark - Event Handle
- (void)didReceiveMemoryWarning:(id)sender {
    // 删除重复数据
    [self _deleteRepeatItemsFromRealm];
}

#pragma mark Helper
/**
 获取或者生成数据中对应对象的副本
 */
- (nullable NSArray<ZWDBBaseModel *> *)_getOrCreateCopyItemsByKeys:(nonnull id)originalArray canUpdate:(BOOL)update {
    NSMutableArray *tmpArray = [NSMutableArray array];
    if ( _isArray(originalArray) ) {
        NSUInteger count = [originalArray count];
        for (NSUInteger i = 0; i < count; i++) {
            id tmpItem = [self _getOrCreateCopyItemByKey:[originalArray objectAtIndex:i] canUpdate:update];
            if (tmpItem) [tmpArray addObject:tmpItem];
        }
    } else {
        ZWDBBaseModel *copyItem = [self _getOrCreateCopyItemByKey:originalArray canUpdate:update];
        if (copyItem) [tmpArray addObject:copyItem];
    }
    return [tmpArray copy];
}

/**
 只获取数据中对应缓存中存在的副本
 */
- (nullable NSArray<ZWDBBaseModel *> *)_getCopyItemsByKeys:(nonnull id)keys  canUpdate:(BOOL)update {
    NSMutableArray *tmpArray = [NSMutableArray array];
    if ( _isArray(keys) ) {
        NSUInteger count = [keys count];
        for (NSUInteger i = 0; i < count; i++) {
            id tmpItem = [self _getCopyItemByKey:[keys objectAtIndex:i] canUpdate:update];
            if (tmpItem) [tmpArray addObject:tmpItem];
        }
    } else {
        id tmpItem = [self _getCopyItemByKey:keys canUpdate:update];
        if (tmpItem) [tmpArray addObject:tmpItem];
    }
    return [tmpArray copy];
}

/**
 获得存在的副本或者生成一个新的副本
 */
- (nonnull ZWDBBaseModel *)_getOrCreateCopyItemByKey:(nonnull ZWDBBaseModel<ZWCacheProtocol> *)key canUpdate:(BOOL)update {
    if ( _ZWCanCacheInRealmObject(key) ) {
        ZWDBBaseModel *copyItem = [self _getCopyItemByKey:key canUpdate:update];
        if ( copyItem && update ) {
            return [self _updateCopyItem:copyItem withOriginal:key];
        }
        copyItem = [key copy];
        if ( copyItem ) {
            [self.itemCaches setObject:copyItem forKey:[key uniqueCode]];
            return copyItem;
        }
        return nil;
    }
    return nil;
}

/**
 只获取缓存中的副本
 
 @param update 是否能更新：YES：更新操作，NO：删除操作
 */
- (nullable ZWDBBaseModel *)_getCopyItemByKey:(nonnull ZWDBBaseModel<ZWCacheProtocol> *)key canUpdate:(BOOL)update {
    if ( !_ZWCanCacheInRealmObject(key) ) return nil;
    NSString *_key = [key uniqueCode];
    if ( [self _existedKeyInItemCaches:_key] ) {
        ZWDBBaseModel *copyItem = self.itemCaches[_key];
        if ( !update ) {
            [self.itemCaches removeObjectForKey:_key];
            if (copyItem) {
                //不是更新的话，那就有相同的两条数据在数据库，所有要删除
                [self.repeatArray addObject:copyItem];
            }
        }
        return copyItem;
    } else if ( [self _existedKeyInDBCaches:_key] ) {
        ZWDBBaseModel *dbItem = self.dbCaches[_key];
        [self.dbCaches removeObjectForKey:_key];
        if (!_ZWIsInvalidRealmObject(dbItem)) {
            if ( update ) {
                if (dbItem) {
                    [self.itemCaches setObject:dbItem forKey:_key];

                }
            } else {
                if (dbItem) {
                    [self.repeatArray addObject:dbItem];

                }
            }
            return dbItem;
        }
        return nil;
    }
    return nil;
}

- (BOOL)_existedKeyInDBCaches:(NSString *)key {
    return !!self.dbCaches[key];
}

- (BOOL)_existedKeyInItemCaches:(NSString *)key {
    return !!self.itemCaches[key];
}

/**
 更新缓存中的副本数据
 */
- (nonnull ZWDBBaseModel *)_updateCopyItem:(nonnull ZWDBBaseModel *)copyItem withOriginal:(nonnull ZWDBBaseModel *)original {
    if ( _isSameClass(copyItem, original) ) {
        void (^transitionBlock)(void) = ^(void) {
            NSDictionary *properties = [ClassProperty getPropertyDictionaryForClass:original.class];
            for ( NSString *key in properties ) {
                @autoreleasepool {
                    NSString *_key = key;
                    if ([_key hasPrefix:@"_"]) _key = [key substringFromIndex:1];
                    if ( [_key isValid] && [original valueForKey:_key] ) {
                        [copyItem setValue:[original valueForKey:_key] forKey:_key];
                    }
                }
            }
        };
        _reset_db_item_(transitionBlock);
    }
    return copyItem;
}

/**
 保存一组查询到的缓存
 */
- (void)_cacheQueryResults:(RLMResults *)results byKeys:(NSArray *)keys {
    if ( results.count != 0 && (results.count == keys.count) ) {
        [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self _cacheQueryResultItem:[results objectAtIndex:idx] byKey:obj];
        }];
    }
    // 删除重复数据
  //  [self _deleteRepeatItemsFromRealm];
}

/**
 保存一个查询到的缓存
 */
- (void)_cacheQueryResultItem:(RLMObject *)item byKey:(ZWDBBaseModel<ZWCacheProtocol> *)key {
    if ( _ZWCanCacheInRealmObject(item) && [key uniqueCode] ) {
        NSString *_uniqueKey = [key uniqueCode];
        if ( [self _existedKeyInDBCaches:_uniqueKey] ) {
            [self.dbCaches removeObjectForKey:_uniqueKey];
            // 数据重复，记录重复数据
        }
        if (item) {
            [self.dbCaches setObject:item forKey:_uniqueKey];

        }
    }
}

/**
 删除缓存中副本
 */
- (void)_deleteCopyItemByKey:(ZWDBBaseModel<ZWCacheProtocol> *)key {
    if ( _ZWCanCacheInRealmObject(key) && [self _existedKeyInItemCaches:[key uniqueCode]] ) {
        [self.itemCaches removeObjectForKey:[key uniqueCode]];
    }
}

/**
 删除缓存中对应Class的副本
 */
- (void)_deleteAllItemsByClass:(Class)itemClass {
    NSMutableArray *keys = [NSMutableArray array];
    [self.itemCaches enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:itemClass] || _ZWIsInvalidRealmObject(obj)) [keys addObject:key];
    }];
    [self.itemCaches removeObjectsForKeys:keys];
    [keys removeAllObjects];
    [self.dbCaches enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:itemClass] || _ZWIsInvalidRealmObject(obj)) [keys addObject:key];
    }];
    [self.dbCaches removeObjectsForKeys:keys];
}

/**
 从数据库中直接删除一组对象
 */
- (void)_deleteRepeatItemsFromRealm {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSMutableArray *aRepeats = [NSMutableArray array];
    [self.repeatArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!_ZWIsInvalidRealmObject(obj)) [aRepeats addObject:obj];
    }];
    [self.repeatArray removeAllObjects];
    if ( aRepeats.count > 0 ) {
        AYLog(@"将要删除的item:%@",aRepeats);

        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObjects:aRepeats];
        [realm commitWriteTransaction];
        dispatch_semaphore_signal(_lock);
    } else {
        dispatch_semaphore_signal(_lock);
    }
}
+(void)deleteAllCatche
{
    [[ZWCacheHelper sharedInstance].dbCaches removeAllObjects];
    [[ZWCacheHelper sharedInstance].itemCaches removeAllObjects];
    [[ZWCacheHelper sharedInstance].repeatArray removeAllObjects];

}
@end
