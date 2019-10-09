//
//  LERMLRealm.m
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "LERMLRealm.h"
#import <Realm/Realm.h>
#import <objc/runtime.h>
#import "NSDictionary+LEAF.h"
#import "LERMLUpgradeProtocol.h"
#import "ZWCacheHelper.h"

/**
 *  配置文件名称
 */
static NSString * const LERMLConfiguratePlistFileName       =   @"LERMLConfigurate";
/**
 *  待升级类列表Key
 */
static NSString * const LERMLUpgradeClassListKey            =   @"LERMLUpgradeClassList";
static  RLMRealmConfiguration *realConfigure;

static  NSURL *initRealmRootPath;

@implementation LERMLRealm

/**
 *  应用启动需要执行的操作
 */
+ (void) launchProgress {

    NSArray<Class<LERMLUpgradeProtocol>> * classList = [self _upgradeClassList];
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    initRealmRootPath = config.fileURL;
    if ([AYUserManager isUserLogin]) {
        config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]  URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",[AYUserManager userId]]] URLByAppendingPathExtension:@"realm"];
    }
    else
    {
        config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]  URLByAppendingPathComponent:@"unlogin"] URLByAppendingPathExtension:@"realm"];
    }

    AYLog(@"realm fileurl is %@",config.fileURL);
    config.schemaVersion = RMLRealmCurrentVersion;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        [classList enumerateObjectsUsingBlock:^(Class<LERMLUpgradeProtocol>  _Nonnull clazz, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString * className = NSStringFromClass(clazz);
            RLMObjectMigrationBlock upgradePropertyAssignedValueChangeBlock = [clazz upgradePropertyAssignedValueChangedForSchemaVersion:oldSchemaVersion];
            if ( upgradePropertyAssignedValueChangeBlock ) {
                [migration enumerateObjects:className block:upgradePropertyAssignedValueChangeBlock];
            }
            NSDictionary<NSString *, NSString *> * upgradePropertyNameModyfiedDictionary = [clazz upgradePropertyNameModyfiedForSchemaVersion:oldSchemaVersion];
            if ( upgradePropertyNameModyfiedDictionary ) {
                [upgradePropertyNameModyfiedDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                     [migration renamePropertyForClass:className oldName:key newName:obj];
                }];
            }
        }];
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    realConfigure = config;
}

#pragma mark - Private
+ (NSArray<Class<LERMLUpgradeProtocol>> *) _upgradeClassList {
    NSDictionary * _configurateDictionary = nil;
    NSString * filePath = [[NSBundle mainBundle] pathForResource:LERMLConfiguratePlistFileName ofType:@"plist"];
    if ( filePath ) {
        _configurateDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    } else {
        DPrintf(">>LERMLConfigurate: File Named %s not found!\n", LERMLConfiguratePlistFileName.UTF8String);
        return nil;
    }
    if ( [_configurateDictionary hasKey:LERMLUpgradeClassListKey] ) {
        NSArray<NSString *> * upgradeClassList = _configurateDictionary[LERMLUpgradeClassListKey];
        NSMutableArray<Class<LERMLUpgradeProtocol>> * classList = [NSMutableArray array];
        [upgradeClassList enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
            Class<LERMLUpgradeProtocol> clazz = NSClassFromString(className);
            while ( clazz != NSObject.class && !class_conformsToProtocol(clazz, @protocol(LERMLUpgradeProtocol))) {
                clazz = clazz.superclass;
            }
            if ( clazz != NSObject.class ) {
                [classList addObject:NSClassFromString(className)];
            }
        }];
        return classList;
    }
    return nil;
}
+ (void) cleanRealm
{
    // 切换数据库之前要清除以前数据库的缓存
    if (realConfigure)
    {
        @autoreleasepool {
            NSError *error;
            RLMRealm *realm = [RLMRealm realmWithConfiguration:realConfigure error:&error];
            if (!error) {
                [realm beginWriteTransaction];
                [realm deleteAllObjects];
                [realm commitWriteTransaction];
            }
            
        }
        
        //删除数据库
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray<NSURL *> *realmFileURLs = @[
                                            realConfigure.fileURL,
                                            [realConfigure.fileURL URLByAppendingPathExtension:@"lock"],
                                            [realConfigure.fileURL URLByAppendingPathExtension:@"note"],
                                            [realConfigure.fileURL URLByAppendingPathExtension:@"management"]
                                            ];
        for (NSURL *URL in realmFileURLs) {
            NSError *error = nil;
            [manager removeItemAtURL:URL error:&error];
            if (error) {
                // 错误处理
            }
        }
    }

    
}
+ (void) switchRealm
{
    if (realConfigure)
    {
        @autoreleasepool {
            NSError *error;
            RLMRealm *realm = [RLMRealm realmWithConfiguration:realConfigure error:&error];
//            if (!error) {
//                [realm beginWriteTransaction];
//                [realm deleteAllObjects];
//                [realm commitWriteTransaction];
//            }
            
        }
        [ZWCacheHelper deleteAllCatche];

        if ([AYUserManager isUserLogin]) {
            realConfigure.fileURL = [[[initRealmRootPath URLByDeletingLastPathComponent]  URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",[AYUserManager userId]]] URLByAppendingPathExtension:@"realm"];
        }
        else
        {
            realConfigure.fileURL = [[[initRealmRootPath URLByDeletingLastPathComponent]  URLByAppendingPathComponent:@"unlogin"] URLByAppendingPathExtension:@"realm"];
        }
        [RLMRealmConfiguration setDefaultConfiguration:realConfigure];

    }
}

@end
