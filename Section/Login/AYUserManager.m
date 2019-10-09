//
//  AYUserManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYUserManager.h"
#import "LEFileManager.h"
#import "NSDictionary+LEAF.h"

static NSString * const kAYUserCacheFileName = @"K_WS_USER_CACHE_FILENAME";

@interface AYUserManager ()
@property (nonatomic, readonly, strong) AYMeModel * userItem;
@end

@implementation AYUserManager
+ (AYUserManager *) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    if ( self = [super init] ) {
        [self _setUp];
    }
    return self;
}

- (void) _setUp {
    [self loadUserItem];
}

- (BOOL) saveUserItem {
    return [self.userItem saveToDocumentWithFileName:kAYUserCacheFileName];
}

- (void) loadUserItem {
    if ( [LEFileManager isFileExistsInDocuments:kAYUserCacheFileName] ) {
        _userItem = [AYMeModel loadFromDocumentWithFileName:kAYUserCacheFileName];
    }
}

- (BOOL) updateToken : (NSString *) token {
    self.userItem.myToken = token;
    return [self saveUserItem];
}

- (BOOL) setUserItemByRecord : (NSDictionary *) record {
    if ( ![record hasKey:@"token"] && self.userItem ) {
        NSMutableDictionary * copyRecord = [NSMutableDictionary dictionaryWithDictionary:record];
        [copyRecord setObject:self.userItem.myToken forKey:@"token"];
        record = copyRecord;
    }
    _userItem = [AYMeModel itemWithDictionary:record];
    
    return [self saveUserItem];
}

- (BOOL) setUserItemByItem: (AYMeModel *) model {

    _userItem = model;
    
    return [self saveUserItem];
}
- (void) logout {
    //清除本地数据
    _userItem = nil;
    if ( [LEFileManager isFileExistsInDocuments:kAYUserCacheFileName] ) {
        [LEFileManager deleteFileInDocumentsWithFileName:kAYUserCacheFileName];
    }
    //发送注销通知
 //   [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginOut object:nil];
}

#pragma mark - Public Functions
/**
 *  当前用户是否已经登陆
 */
+ (BOOL) isUserLogin {
    return [self sharedInstance].userItem != nil;
}

/**
 *  用户对象获取
 */
+ (AYMeModel *) userItem {
    return [self sharedInstance].userItem;
}

/**
 *  当前用户ID｜如果未登录将返回nil
 */
+ (NSString *) userId {
    return [self isUserLogin] ? [[[self userItem] myId] stringValue] : nil;
}

+ (BOOL) compareWithId : (NSString *) userId {
    return [self isUserLogin] ? [[[[self userItem] myId] stringValue] isEqualToString:userId] : NO;
}

/**
 *  当前用户id或者空字符串
 */
+ (NSString *) userIdOrEmptyCode {
    return [self isUserLogin] ? [[[self userItem] myId] stringValue] : @"";
}

/**
 *  登录访问记号
 */
+ (NSString *) accessToken {
    return [self isUserLogin] ? [[self userItem] myToken] : nil;
}

/**
 *  更新用户token
 */
+ (BOOL) updateUserToken : (NSString *) token {
    return [[self sharedInstance] updateToken:token];
}

/**
 *  设置用户对象
 */
+ (BOOL) setUserItemByRecord : (NSDictionary *) record {
    return [[self sharedInstance] setUserItemByRecord:record];
}

+ (BOOL) setUserItemByItem : (AYMeModel *) model
{
    return [[self sharedInstance] setUserItemByItem:model];

}
/**
 *  保存用户数据对象到磁盘
 */
+ (BOOL) save {
    return [[self sharedInstance] saveUserItem];
}

/**
 *  用户登出操作请调用此方法
 */
+ (void) logout {
    [[self sharedInstance] logout];
}

@end
