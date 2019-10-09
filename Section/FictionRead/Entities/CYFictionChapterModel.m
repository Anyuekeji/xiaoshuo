//
//  CYFictionChapterModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "CYFictionChapterModel.h"

@implementation CYFictionChapterModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"fictionSectionID"           : @"section_id",
             @"fictionSectionTitle"           : @"title",
             @"fictionID"           : @"book_id",
             @"needMoney"           : @"isfree",
             @"unlock"           : @"ispay",
             @"coinNum"           : @"coin",
             @"fictionUpdateTime" : @"update_time",
             };
}
//+ (NSArray *)ignoredProperties {
//    return @[];
//}

+ (NSString *) primaryKey {
    return @"fictionSectionID";
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),[self.fictionSectionID stringValue]];
}
@end
