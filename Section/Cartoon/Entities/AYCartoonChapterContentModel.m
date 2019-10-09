//
//  AYCartoonChapterContentModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/4.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonChapterContentModel.h"
#import <YYKit/YYKit.h>
#import "ZWCacheHelper.h"
#import "LERSAEncyManage.h"

@implementation AYCartoonChapterImageUrlModel
+ (NSArray *)ignoredProperties {
    return @[];
}
+ (NSDictionary<NSString *, id> *) propertyToKeyPair
{
    return @{@"cartoonImageUrl": @"url"};
}

+ (NSString *) primaryKey {
    return @"cartoonImageUrl";
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),self.cartoonImageUrl];
}
-(void)decodeImageUrl
{
     NSString *decodeImageUrl = [LERSAEncyManage decryptString:_cartoonImageUrl privateKey:RSA_PRIVATE_KEY];
    if (decodeImageUrl.length>3) {
        self.cartoonImageUrl = decodeImageUrl;
    }
    AYLog(@"the  cartoonImageUrl is %@ ",self.cartoonImageUrl);
}
@end

@implementation AYCartoonChapterContentModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{
              @"chapterAgreeNum"           : @"hits",
              @"cartoonImageUrlArray"           : @"cart_sec_content",
              @"cartoonChatperCommentModel"           : @"discuss",
             };
}

+ (NSDictionary<NSString *, id> *) propertyToClassPair {
    
    return @{@"cartoonImageUrlArray"  : AYCartoonChapterImageUrlModel.class,
             @"cartoonChatperCommentModel": AYCommentModel.class,
             };
}
+ (NSArray *)ignoredProperties {
    return @[@"cartoonChatperCommentModel"];
}
+(AYCartoonChapterContentModel*)itemWithRecord:(NSDictionary*)record
{
    if (record && [record isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] initWithDictionary:record];
        
//        if (record[@"cart_section_id"]) {
//            [itemDic setObject:record[@"cart_section_id"] forKey:@"cart_section_id"];
//        }
//        if (record[@"title"]) {
//            [itemDic setObject:record[@"title"] forKey:@"title"];
//        }
//        if (record[@"cartoon_id"]) {
//            [itemDic setObject:record[@"cartoon_id"] forKey:@"cartoon_id"];
//        }
//        if (record[@"hits"]) {
//            [itemDic setObject:record[@"hits"] forKey:@"hits"];
//        }
//        if (record[@"hit_status"]) {
//            [itemDic setObject:record[@"hit_status"] forKey:@"hit_status"];
//        }
//        if (record[@"update_time"]) {
//            [itemDic setObject:record[@"update_time"] forKey:@"update_time"];
//        }
//        NSDictionary *discussDic =[record objectForKey:@"discussd"];
//        if (discussDic && [discussDic isKindOfClass:[NSDictionary class]]) {
//            [itemDic addEntriesFromDictionary:discussDic];
//        }
        AYCartoonChapterContentModel *detailModel = [AYCartoonChapterContentModel itemWithDictionary:itemDic];
        
        NSDictionary *setContentDic =[record objectForKey:@"cart_sec_contents"];
        if (setContentDic  && [setContentDic isKindOfClass:[NSDictionary class]]) {
            
            NSArray *setContentArray = setContentDic[@"cart_sec_content"];
            if (setContentArray) {
          
                [setContentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    AYCartoonChapterImageUrlModel *urlModel = [AYCartoonChapterImageUrlModel itemWithDictionary:obj];
                    [urlModel decodeImageUrl];
                    [detailModel.cartoonImageUrlArray addObject:urlModel];
                }];
            }
        }
        
        return detailModel;
    }
    return  nil;
}

+ (NSString *) primaryKey {
    return @"cartoonChapterId";
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),[self.cartoonChapterId stringValue]];
}
@end
