//
//  AYConsumeModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/17.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYConsumeModel.h"

@implementation AYConsumeModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"consumeTime"           : @"expend_time",
             @"consumeCoinNum"           : @"expend_red",
             @"consumeProjectType"           : @"other_name",
             @"consumeSection"           : @"section_title",
            @"local_time"           : @"expend_times",

             };
}
@end
