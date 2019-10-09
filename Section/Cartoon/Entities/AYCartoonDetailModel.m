//
//  AYCartoonDetailModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonDetailModel.h"

@implementation AYCartoonDetailModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"fictionSumSection"           : @"book_id",
             @"cartoonSumComment"           : @"count",
             @"cartoonGrade"           : @"replynum",
             @"cartoonRewardCoinNum"           : @"icon_count",
             @"cartoonRewardUserArray"           : @"avater",
             @"cartoonCommentModel"           : @"discuss",
             @"cartoonUpdateTime"           : @"update_time",
             @"cartoonHotNum"           : @"hits",
             @"cartoonAgreeNum"           : @"like",
             @"cartoonColletNum"           : @"collect",
             @"cartoonSurfaceplot"           : @"bpic_detail",
             };
}

+ (NSDictionary<NSString *, id> *) propertyToClassPair {
    
    return @{@"cartoonRewardUserArray"  : AYMeModel.class,
             @"cartoonCommentModel": AYCommentModel.class,
             };
}
+ (NSArray *)ignoredProperties {
    return @[@"cartoonRewardUserArray",
             @"cartoonCommentModel",@"cartoonRecommendList"
             ];
}
+(AYCartoonDetailModel*)itemWithRecord:(NSDictionary*)record
{
    if (record && [record isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *itemDic = [NSMutableDictionary new];
        NSDictionary *userInfoDic =[record objectForKey:@"data"];
        if (userInfoDic) {
            [itemDic addEntriesFromDictionary:userInfoDic];
        }
        
        NSDictionary *userRewardDic =[record objectForKey:@"avaters"];
        if (userRewardDic) {
            [itemDic addEntriesFromDictionary:userRewardDic];
        }
        
        NSDictionary *discussDic =[record objectForKey:@"discussd"];
        if (discussDic) {
            [itemDic addEntriesFromDictionary:discussDic];
        }
        
        AYCartoonDetailModel *detailModel = [AYCartoonDetailModel itemWithDictionary:itemDic];
        return detailModel;
    }
    return nil;
}

@end
