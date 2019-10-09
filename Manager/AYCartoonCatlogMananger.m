//
//  AYCartoonCatlogMananger.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonCatlogMananger.h"
#import "AYCartoonChapterModel.h"


@interface AYCartoonCatlogMananger()
//存储数据
@property(nonatomic,strong) NSMutableArray<AYCartoonChapterModel*> *cartoonCatlogArray;
@property(nonatomic,assign) int count_all;
@property(nonatomic,copy) NSString *update_day;
//当前的bookid
@property(nonatomic,strong) NSString *currentBookId;
@property(nonatomic,strong) NSString *update_section;//更新到多少章
@property(nonatomic,strong) NSString *update_status;//2：连载中、1：已完结

@end

@implementation AYCartoonCatlogMananger
singleton_implementation(AYCartoonCatlogMananger)
/**
 *获取漫画目录
 */
-(void)fetchCartoonCatlogWithCartoonId:(NSString*)cartoonId refresh:(BOOL)refresh success : (void(^)(NSArray<AYCartoonChapterModel*> * cartoonCatlogArray,int count_all,NSString *update_day)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if(!self.cartoonCatlogArray)
    {
        self.cartoonCatlogArray = [NSMutableArray new];
    }
    if(!refresh && [self.currentBookId isEqualToString:cartoonId])
    {
        if (self.cartoonCatlogArray && self.cartoonCatlogArray.count>0) {
            if (completeBlock) {
                completeBlock(self.cartoonCatlogArray,self.count_all,self.update_day);
                return;
            }
        }
    }
    if (![AYUtitle networkAvailable])
    {
        //没网直接读本地
        AYLog(@"没网直接读本地");
        NSArray<AYCartoonChapterModel*> *chaperArray = [self getLocalCartoonCatlogWithId:cartoonId];
        if (chaperArray && chaperArray.count>0) {
            self.currentBookId = cartoonId;
            [self.cartoonCatlogArray removeAllObjects];
            [self.cartoonCatlogArray safe_addObjectsFromArray:chaperArray];
            if (completeBlock) {
                completeBlock(self.cartoonCatlogArray,self.count_all,self.update_day);
            }
        }
    }
    //[self showHUD];
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:cartoonId forKey:@"cartoon_id"];
    }];
    [ZWNetwork post:@"HTTP_Post_Cartoon_Chapters" parameters:para success:^(id record)
     {
         if ([record isKindOfClass:NSDictionary.class]) {
             if (record) {
                 [self.cartoonCatlogArray removeAllObjects];
                NSArray *itemArray = record[@"list"];
                 if (itemArray) {
                     self.currentBookId = cartoonId;

                     NSArray<AYCartoonChapterModel*> *chatperArray = [AYCartoonChapterModel itemsWithArray:itemArray];
                     
                     if (chatperArray && chatperArray.count>0) {
                           [self.cartoonCatlogArray safe_addObjectsFromArray:chatperArray];
                         [self saveCartoonCatalog:self.cartoonCatlogArray cartoonId:cartoonId];
             
                 }
                 
                     NSNumber *tem_num = record[@"count_all"];
                     if (tem_num) {
                         self.count_all = [tem_num intValue];
                     }
                     tem_num = record[@"update_day"];
                     if (tem_num) {
                         self.update_day = [tem_num stringValue];
                     }
                     tem_num = record[@"update_section"];
                     if (tem_num) {
                         self.update_section = [tem_num stringValue];
                     }
                     tem_num = record[@"update_status"];
                     if (tem_num) {
                         self.update_status = [tem_num stringValue];
                     }
                     if (completeBlock) {
                         completeBlock(self.cartoonCatlogArray,[self.update_status intValue],self.update_section);
                     }
                 }
                 
                 
             }
         }
     } failure:^(LEServiceError type, NSError *error) {
         //有错误看本地有没有
         NSArray<AYCartoonChapterModel*> *chaperArray = [self getLocalCartoonCatlogWithId:cartoonId];
         if (chaperArray && chaperArray.count>0) {
             self.currentBookId = cartoonId;

             [self.cartoonCatlogArray removeAllObjects];
             [self.cartoonCatlogArray safe_addObjectsFromArray:chaperArray];
             
             if (completeBlock) {
                 completeBlock(self.cartoonCatlogArray,self.count_all,self.update_day);
             }
         }
         else
         {
             if (failureBlock) {
                 failureBlock([error localizedDescription]);
             }
         }
         
         // occasionalHint([error localizedDescription]);
     }];
}
#pragma mark - db -
-(void)saveCartoonCatalog:(NSArray<AYCartoonChapterModel*>*)chaperArray cartoonId:(NSString*)cartoonId
{
//    NSString *qureyStr = [NSString stringWithFormat:@"cartoonId = '%@'",cartoonId];
//    NSArray<CYFictionChapterModel*> *localChapterArray = [AYCartoonChapterModel r_query:qureyStr];
//    if(localChapterArray)
//    {
//        [AYCartoonChapterModel r_deletes:localChapterArray];//先删除
//    }
    [AYCartoonChapterModel r_saveOrUpdates:chaperArray];
}

-(NSArray<AYCartoonChapterModel*>*)getLocalCartoonCatlogWithId:(NSString*)fictionId
{
    NSString * qureyStr = [NSString stringWithFormat:@"cartoonId = '%@'",fictionId];
    NSArray<AYCartoonChapterModel*> *chapterModelArray = [AYCartoonChapterModel r_query:qureyStr sortProperty:@"cartoonChapterId" ascending:YES];
    if (chapterModelArray && chapterModelArray.count>0)
    {
        return chapterModelArray;
    }
    return nil;
}
/**
 *清空缓存
 */
-(void)clearData
{
    if (self.cartoonCatlogArray) {
        [self.cartoonCatlogArray removeAllObjects];
    }
}
@end
