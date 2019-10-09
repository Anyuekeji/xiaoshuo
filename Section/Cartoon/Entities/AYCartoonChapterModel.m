//
//  AYCartoonChapterModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonChapterModel.h"
#import "CYFictionChapterModel.h"

@implementation AYCartoonChapterModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"cartoonChapterId"           : @"cart_section_id",
            @"cartoonChapterTitle"           : @"title",
            @"cartoonId"           : @"cartoon_id",
             @"needMoney"           : @"isfree",
             @"unlock"           : @"ispay",
             @"coinNum"           : @"charge_coin",
             @"cartoonUpdateTime" : @"update_time",
             @"cartoon_update_status"           : @"update_status",
             @"cartoon_update_section"           : @"update_section",
             };
}
+ (NSArray *)ignoredProperties {
    return @[@"startChapterIndex",@"cartoon_update_section",@"cartoon_update_status",];
}
+ (NSString *) primaryKey {
    return @"cartoonChapterId";
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),[self.cartoonChapterId stringValue]];
}
-(CYFictionChapterModel*)modelToFictionModel
{
    CYFictionChapterModel *fictionChapter = [CYFictionChapterModel new];
    fictionChapter.fictionID = self.cartoonId;
    fictionChapter.fictionSectionID= self.cartoonChapterId;
    fictionChapter.fictionSectionTitle= self.cartoonChapterTitle;
    fictionChapter.needMoney = self.needMoney;
    fictionChapter.unlock = self.unlock;
    fictionChapter.coinNum = self.coinNum;
    
    return fictionChapter;
}

@end

