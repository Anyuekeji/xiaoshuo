//
//  AYFictionModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/6.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionModel.h"

@implementation AYFictionModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"fictionID"           : @"book_id",
             @"fictionImageUrl"           : @"bpic",
             @"fictionTitle"           : @"other_name",
             @"fictionIntroduce"           : @"desc",
             @"fictionAuthor"           : @"writer_name",
             @"fictionCoinNum"           : @"reward_icon",
             @"fiction_update_status"           : @"update_status",
             };
}

+ (NSString *) primaryKey {
    return @"fictionID";
}
+ (NSArray *)ignoredProperties {
    return @[@"isfree",];
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),self.fictionID];
}
@end
