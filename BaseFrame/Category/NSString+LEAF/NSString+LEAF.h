//
//  NSString+LEAF.h
//  LE
//
//  Created by liuyunpeng on 15/10/14.
//  Copyright © 2015年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  快速构造字符串对象方法
 *
 *  @param format 格式
 *  @param ...    拼接
 *
 *  @return 字符串对象
 */
NSString *NSStringWithFormat(NSString * format, ...) NS_FORMAT_FUNCTION(1,2);

@interface NSString (LEAF)

/**
 *  将字符串通过空号分割成数组
 *
 *  @return 分割数组
 */
- (NSArray *)split;

/**
 *  将字符串通过指定的分割符分割成数组
 *
 *  @param delimiter 指定分隔符
 *
 *  @return 分割数组
 */
- (NSArray *)split:(NSString *)delimiter;

/**
 *  蛇形表示－>驼峰表示
 *
 *  @return 驼峰串
 */
- (NSString *)camelCase;

/**
 *  是否包含子串
 *
 *  @param string 判定字符串
 *
 *  @return 是否包含
 */
- (BOOL)containsString:(NSString *)string;

/**
 *  过滤掉所有空格和换行符
 *
 *  @return 过滤字符串
 */
- (NSString *)strip;

/**
 *  返回MD5码
 *
 *  @return MD5码
 */
- (NSString *)md5;

/**
 *  是否为空
 *
 *  @return 是否为空或者全由空格换行符组成
 */
- (BOOL)isBlank;

/**
 *  匹配字符中的AppId
 */
- (NSString *)matchExternalAppId;

/**
 *  正则匹配字符串
 *
 *  @param pattern 正则表达式
 *
 *  @return 匹配好的字符串
 */
- (NSString *)matchWithPattern:(NSString *)pattern;

/**
 *  是否是打开外部应用的链接
 */
- (BOOL)isOpenExternalAppRequire;

/**
 *  使用replacement替换target，不存在target则拼接在最后
 */
- (NSString *)replacingString:(NSString *)target with:(NSString *)replacment;

- (NSString *) stringValue;
-(NSString *) aes256_decrypt:(NSString *)key;
@end
