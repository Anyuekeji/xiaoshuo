//
//  NSString+LEAF.m
//  LE
//
//  Created by Leaf on 15/10/14.
//  Copyright © 2015年 Leaf. All rights reserved.
//

#import "NSString+LEAF.h"
#import "NSArray+LEAF.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+PJR.h"

static NSString *const UNDERSCORE = @"_";
static NSString *const SPACE = @" ";
static NSString *const EMPTY_STRING = @"";

NSString *NSStringWithFormat(NSString *formatString, ...) {
    va_list args;
    va_start(args, formatString);
    NSString *string = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
#if defined(__has_feature) && __has_feature(objc_arc)
    return string;
#else
    return [string autorelease];
#endif
}

@implementation NSString (LEAF)

- (NSArray *)split {
    NSArray *result = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [result select:^BOOL(NSString *string) {
        return string.length > 0;
    }];
}

- (NSArray *)split:(NSString *)delimiter {
    return [self componentsSeparatedByString:delimiter];
}

- (NSString *)camelCase {
    NSString *spaced = [self stringByReplacingOccurrencesOfString:UNDERSCORE withString:SPACE];
    NSString *capitalized = [spaced capitalizedString];
    return [capitalized stringByReplacingOccurrencesOfString:SPACE withString:EMPTY_STRING];
}

- (BOOL)containsString:(NSString *) string {
    NSRange range = [self rangeOfString:string options:NSCaseInsensitiveSearch];
    return range.location != NSNotFound;
}

- (NSString *)strip {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) md5 {
    CC_MD5_CTX md5;
    CC_MD5_Init (&md5);
    CC_MD5_Update (&md5, [self UTF8String], (CC_LONG)[self length]);
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final (digest, &md5);
    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0],  digest[1],
                   digest[2],  digest[3],
                   digest[4],  digest[5],
                   digest[6],  digest[7],
                   digest[8],  digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    
    return s;
}

- (BOOL) isBlank {
    if ( !self || self.length == 0 ) {
        return YES;
    }
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
}

- (nullable NSString *)matchExternalAppId {
    if ( [self isValid] ) {
        NSString *pattern = @"id\\d{5,}";
        NSString *resultString = [self matchWithPattern:pattern];
        if ( resultString &&  resultString.length > 2 ) {
            // 过滤字符串“id”
            return [resultString substringWithRange:NSMakeRange(2, resultString.length - 2)];
        }
    }
    return nil;
}

- (nullable NSString *)matchWithPattern:( NSString * _Nonnull)pattern {
    if ( [self isValid ] && [pattern isValid] ) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        if ( error ) { return nil; }
        NSRange resultRange = [regex rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
        BOOL _overRange = ((resultRange.location + resultRange.length) > self.length);
        if ( !NSEqualRanges(NSMakeRange(0, 0), resultRange) && !_overRange ) {
            return [self substringWithRange:resultRange];
        }
    }
    return nil;
}

- (BOOL)isOpenExternalAppRequire {
    return ( [self containsString:@"https://itunes.apple.com"] && [self matchExternalAppId] );
}

- (NSString *)replacingString:(NSString *)target with:(NSString *)replacment {
    if ( [self containsString:target] ) {
        return [self stringByReplacingOccurrencesOfString:target withString:replacment];
    } else {
        return [self stringByAppendingString:replacment];
    }
}

- (NSString *) stringValue {
    return self;
}
// 解密
-(NSString *) aes256_decrypt:(NSString *)key{
    
    //转换为2进制Data
    NSMutableData *data = [NSMutableData dataWithCapacity:self.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    //对数据进行解密
    NSData* result = [data aes256_decrypt:key];
    if (result && result.length > 0) {
        result = [result base64EncodedDataWithOptions:0];
        NSString *ret = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        return ret;
    }
    return nil;
}

@end
