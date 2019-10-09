//
//  AYFictionDetailModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionDetailModel.h"

@implementation AYFictionDetailModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{
             @"fictionSumSection"           : @"section_count",
             @"fictionSumComment"           : @"count",
             @"fictionGrade"           : @"replynum",
             @"fictionRewardCoinNum"           : @"icon_count",
             @"fictionRewardUserArray"           : @"avater",
             @"fictionCommentModel"           : @"discuss",
            @"fiction_update_section"           : @"update_section",
             
             };
}

+ (NSDictionary<NSString *, id> *) propertyToClassPair {
    
    return @{@"fictionRewardUserArray"  : AYMeModel.class,
             @"fictionCommentModel": AYCommentModel.class,
             };
}
+ (NSArray *)ignoredProperties {
    return @[@"recommentFictionList",
             @"fictionCommentModel",@"fictionRewardUserArray",@"fiction_update_section",@"fiction_update_status",
             ];
}
+(AYFictionDetailModel*)itemWithRecord:(NSDictionary*)record
{
    if (record && [record isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *itemDic = [NSMutableDictionary new];
        NSDictionary *userInfoDic =[record objectForKey:@"data"];
        if (userInfoDic && [userInfoDic isKindOfClass:NSDictionary.class]) {
            [itemDic addEntriesFromDictionary:userInfoDic];
        }
        
        NSDictionary *userRewardDic =[record objectForKey:@"avaters"];
        if (userRewardDic && [userRewardDic isKindOfClass:NSDictionary.class]) {
            [itemDic addEntriesFromDictionary:userRewardDic];
        }
        
        NSDictionary *discussDic =[record objectForKey:@"discussd"];
        if (discussDic && [discussDic isKindOfClass:NSDictionary.class]) {
            [itemDic addEntriesFromDictionary:discussDic];
        }
        AYFictionDetailModel *detailModel = [AYFictionDetailModel itemWithDictionary:itemDic];
        return detailModel;
    }
    return nil;
}

@end
