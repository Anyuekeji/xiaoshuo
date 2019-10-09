//
//  NSObject+LEModelSupport.m
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "NSObject+LEModelSupport.h"
#import "LEFileManager.h"

@implementation NSObject (LEModelSupport)

+ (id) item {
    return [[self alloc] init];
}

/**
 *  依据字典初始化一个实例
 */
+ (id) itemWithDictionary : (NSDictionary *) dictionary {
    return [self modelWithDictionary:dictionary];
}

/**
 *  依据JSON对象初始化一个实例
 *
 *  @param json `NSDictionary`, `NSString` or `NSData`.
 */
+ (id) itemWithJSON : (id) json {
    return [self modelWithJSON:json];
}

/**
 *  依据数组初始化一个实例数组
 */
+ (NSArray *) itemsWithArray : (id) json {
    return [NSArray modelArrayWithClass:[self class] json:json];
}

#pragma mark - YYModel
+ (NSDictionary<NSString *, id> *) modelCustomPropertyMapper {
    NSMutableDictionary<NSString *, id> * mapDictionary = [NSMutableDictionary dictionary];
    Class clazz = self;
    while ( [clazz  isSubclassOfClass:NSObject.class] ) {
        [mapDictionary addEntriesFromDictionary:[clazz propertyToKeyPair]];
        clazz = [clazz superclass];
    }
    return mapDictionary;
}

+ (NSDictionary<NSString *, id> *) propertyToKeyPair {
    return nil;
}

+ (NSDictionary<NSString *, id> *) modelContainerPropertyGenericClass {
    NSMutableDictionary<NSString *, id> * mapDictionary = [NSMutableDictionary dictionary];
    Class clazz = self;
    while ( [clazz isSubclassOfClass:NSObject.class] ) {
        [mapDictionary addEntriesFromDictionary:[clazz propertyToClassPair]];
        clazz = [clazz superclass];
    }
    return mapDictionary;
}

+ (NSDictionary<NSString *, id> *) propertyToClassPair {
    return nil;
}

#pragma mark - Archive
- (BOOL) saveToFile : (NSString *) filePath {
    if ( filePath ) {
        if ( [LEFileManager isFileExistsAtPath:filePath] ) {
            [LEFileManager deleteFileAtPath:filePath];
        }
        return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
    }
    return NO;
}

- (BOOL) saveToDocumentWithFileName : (NSString *) fileName {
    NSString * filePath = [LEFileManager createFileInDocumentsWithFileName:fileName];
    return [self saveToFile:filePath];
}

- (BOOL) saveToCachesWithFileName : (NSString *) fileName {
    NSString * filePath = [LEFileManager createFileInCachesWithFileName:fileName];
    return [self saveToFile:filePath];
}

- (BOOL) saveToTmpWithFileName : (NSString *) fileName {
    NSString * filePath = [LEFileManager createFileInTmpWithFileName:fileName];
    return [self saveToFile:filePath];
}

+ (id) loadFromFile : (NSString *) filePath {
    if ( filePath ) {
        if ( [LEFileManager isFileExistsAtPath:filePath] ) {
            id object = nil;
            @try {
                object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            } @catch (NSException *exception) {
                Debug(@">> LEAF : EXCEPTION IN NSKeyedUnarchiver<loadFromFile:>!");
            } @finally {
                return object;
            }
        } else {
            Debug(@">> LEAF : Can not found file <loadFromFile:>!");
        }
    }
    return nil;
}

+ (id) loadFromDocumentWithFileName : (NSString *) fileName {
    NSString * filePath = [LEFileManager filePathInDocumentsWithFileName:fileName];
    return [self loadFromFile:filePath];
}

+ (id) loadFromCachesWithFileName : (NSString *) fileName {
    NSString * filePath = [LEFileManager filePathInCachesWithFileName:fileName];
    return [self loadFromFile:filePath];
}

+ (id) loadFromTmpWithFileName : (NSString *) fileName {
    NSString * filePath = [LEFileManager filePathInTmpWithFileName:fileName];
    return [self loadFromFile:filePath];
}

@end
