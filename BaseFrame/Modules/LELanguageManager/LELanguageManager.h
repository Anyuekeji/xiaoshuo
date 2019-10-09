//
//  LELanguageManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/31.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ChangeLanguageNotificationName @"changeLanguage"
#define AYLocalizedString(key) [kLanguageManager localizedStringForKey:key]
#define kLocalizedTableString(key,tableN) [kLanguageManager localizedStringForKey:key tableName:tableN]

NS_ASSUME_NONNULL_BEGIN

@interface LELanguageManager : NSObject
@property (nonatomic,copy) void (^completion)(NSString *currentLanguage);

- (NSString *)currentLanguage; //当前语言
- (NSString *)languageFormat:(NSString*)language;
- (void)setUserlanguage:(NSString *)language;//设置当前语言

- (NSString *)localizedStringForKey:(NSString *)key;

- (NSString *)localizedStringForKey:(NSString *)key tableName:(NSString *)tableName;

- (UIImage *)ittemInternationalImageWithName:(NSString *)name;
- (BOOL)isTilandLanguage; //是否是泰国y语言

+ (instancetype)shareInstance;

#define kLanguageManager [LELanguageManager shareInstance]
@end

NS_ASSUME_NONNULL_END
