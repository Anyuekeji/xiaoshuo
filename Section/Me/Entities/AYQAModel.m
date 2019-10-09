//
//  AYQAModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/26.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYQAModel.h"

@implementation AYQAModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"qaId"           : @"faq_id",
             @"question"           : @"faq_question",
             @"answer"           : @"faq_answer",
             };
}

@end
