//
//  AYFictionCatlogManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionCatlogManager.h"
#import "CYFictionChapterModel.h"

@interface AYFictionCatlogManager()
//存储数据
@property(nonatomic,strong) NSMutableArray<CYFictionChapterModel*> *fitionCatlogArray;
//当前的bookid
@property(nonatomic,strong) NSString *currentBookId;
@end


@implementation AYFictionCatlogManager

singleton_implementation(AYFictionCatlogManager)
/**
 *获取小说目录
 */
-(void)fetchFictionCatlogWithFictionId:(NSString*)fictionId refresh:(BOOL)refresh success : (void(^)(NSArray<CYFictionChapterModel*> * fictionCatlogArray)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if(!self.fitionCatlogArray)
    {
        self.fitionCatlogArray = [NSMutableArray new];
    }
    if(!refresh && [self.currentBookId isEqualToString:fictionId])
    {
        if (self.fitionCatlogArray && self.fitionCatlogArray.count>0) {
            if (completeBlock) {
                completeBlock(self.fitionCatlogArray);
                return;
            }
        }
    }
    if (![AYUtitle networkAvailable])
    {
        //没网直接读本地
        AYLog(@"没网直接读本地");
        NSArray<CYFictionChapterModel*> *chaperArray = [self getLocalFictionCatlogWithId:fictionId];
        if (chaperArray && chaperArray.count>0) {
            self.currentBookId = fictionId;
            [self.fitionCatlogArray removeAllObjects];
            [self.fitionCatlogArray safe_addObjectsFromArray:chaperArray];
            if (completeBlock) {
                completeBlock(self.fitionCatlogArray);
            }
        }
    }
    //[self showHUD];
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:fictionId forKey:@"book_id"];
    }];
    [ZWNetwork post:@"HTTP_Post_Catalog" parameters:para success:^(id record)
     {
         if ([record isKindOfClass:NSArray.class]) {
             if (record) {
                 self.currentBookId = fictionId;
                 [self.fitionCatlogArray removeAllObjects];
                 NSArray *itemArray = [CYFictionChapterModel itemsWithArray:record];
                 if (itemArray && itemArray.count>0) {

                     [self.fitionCatlogArray safe_addObjectsFromArray:itemArray];
                  [self saveCartoonCatalog:self.fitionCatlogArray fictionId:fictionId];
                     if (completeBlock) {
                         completeBlock(self.fitionCatlogArray);
                     }
                 }
             }
         }
     } failure:^(LEServiceError type, NSError *error) {
         //有错误看本地有没有
         NSArray<CYFictionChapterModel*> *chaperArray = [self getLocalFictionCatlogWithId:fictionId];
         if (chaperArray && chaperArray.count>0) {
             self.currentBookId = fictionId;
             [self.fitionCatlogArray removeAllObjects];
             [self.fitionCatlogArray safe_addObjectsFromArray:chaperArray];

             if (completeBlock) {
                 completeBlock(self.fitionCatlogArray);
             }
         }
         else
         {
             if (failureBlock) {
                 failureBlock([error localizedDescription]);
             }
         }

          //occasionalHint([error localizedDescription]);
     }];
}
#pragma mark - db -
-(void)saveCartoonCatalog:(NSArray<CYFictionChapterModel*>*)chaperArray fictionId:(NSString*)fictionId
{
//    NSString *qureyStr = [NSString stringWithFormat:@"fictionID = '%@'",fictionId];
//    NSArray<CYFictionChapterModel*> *localChapterArray = [CYFictionChapterModel r_query:qureyStr];
//    if(localChapterArray)
//    {
//        [CYFictionChapterModel r_deletes:localChapterArray];//先删除
//    }
    [CYFictionChapterModel r_saveOrUpdates:chaperArray];
}
-(NSArray<CYFictionChapterModel*>*)getLocalFictionCatlogWithId:(NSString*)fictionId
{
    NSString * qureyStr = [NSString stringWithFormat:@"fictionID = '%@'",fictionId];
    NSArray<CYFictionChapterModel*> *chapterModelArray = [CYFictionChapterModel r_query:qureyStr sortProperty:@"fictionSectionID" ascending:YES];
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
    if (self.fitionCatlogArray) {
        [self.fitionCatlogArray removeAllObjects];
    }
}

#pragma mark - network -
@end
