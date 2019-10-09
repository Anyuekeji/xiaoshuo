//
//  AYCartoonModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonModel.h"

@implementation AYCartoonModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"cartoonID"           : @"cartoon_id",
             @"cartoonImageUrl"           : @"bpic",
             @"cartoonTitle"           : @"other_name",
             @"cartoonIntroduce"           : @"desc",
             @"cartoonAuthor"           : @"writer_name",
             @"cartoonCoinNum"           : @"reward_icon",
             @"cartoon_update_status"           : @"update_status",
             };
}
+ (NSString *) primaryKey {
    return @"cartoonID";
}
+ (NSArray *)ignoredProperties {
    return @[@"isfree",];
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),[self.cartoonID stringValue]];
}
@end
