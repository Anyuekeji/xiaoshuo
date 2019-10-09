//
//  AYFictionDetailViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionDetailViewModel.h"
#import "AYFictionDetailModel.h"
#import "AYFictionModel.h"

@interface AYFictionDetailViewModel ()
@property(nonatomic,strong) AYFictionDetailModel *fictionDetailModel; //小说总章节数
@property(nonatomic,strong) NSArray *itemArray; //小说总章节数
@property(nonatomic,strong) NSArray *recommentArray; //推荐数据

@end

@implementation AYFictionDetailViewModel
- (void) setUp
{
    [super setUp];
    _fictionDetailModel = [AYFictionDetailModel new];
    _itemArray = [NSArray arrayWithObjects:@"head",@"reward",@"introduce",@"menu",@"empty",@"invate",@"charge",@"empty",nil];
   // _itemArray = [NSArray arrayWithObjects:@"head",@"reward",@"introduce",@"menu",@"empty",@"invate",@"empty",@"comment", @"empty",@"recomment",nil];
    _recommentArray =[NSArray arrayWithObjects:@"empty",@"recomment",nil];
}
- (void) getFictionDetailDataByFictionModel:(AYFictionModel*)fictionModel  complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@([fictionModel.fictionID intValue]) forKey:@"book_id"];
    }];
    [ZWNetwork post:@"HTTP_Post_Fiction_Detail" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class]){
             self.fictionDetailModel = [AYFictionDetailModel itemWithRecord:record];
             //banner 里有时候没title
             fictionModel.fictionTitle = self.fictionDetailModel.fictionTitle;
             self.fictionDetailModel.isfree = fictionModel.isfree;
             if (completeBlock) {
                 completeBlock();
             }
         }
     } failure:^(LEServiceError type, NSError *error) {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}
//HTTP_Post_Fiction_Recommend
-(void)getFictionRecommend:(AYFictionModel*)fictionModel  complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@([fictionModel.fictionID intValue]) forKey:@"book_id"];
    }];
    [ZWNetwork post:@"HTTP_Post_Fiction_Recommend" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class]){
             NSArray<AYFictionModel*> *itemArray = [AYFictionModel itemsWithArray:record];
     
             if(self.fictionDetailModel)
             {
                 if (!self.fictionDetailModel.recommentFictionList) {
                     self.fictionDetailModel.recommentFictionList = [NSMutableArray new];
                 }
                 [self.fictionDetailModel.recommentFictionList safe_addObjectsFromArray:itemArray];
                 
                 //删除跟同一本书
                 [self.fictionDetailModel.recommentFictionList enumerateObjectsUsingBlock:^(AYFictionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if ([obj.fictionID isEqualToString:fictionModel.fictionID]) {
                         [self.fictionDetailModel.recommentFictionList removeObject:obj];
                             *stop = YES;
                     }
                 }];
             }
             if (completeBlock) {
                 completeBlock();
             }
         }
     } failure:^(LEServiceError type, NSError *error) {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}
#pragma mark - Table Used
- (NSInteger)numberOfSections {
    return 3;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section {
    if (section ==0) {
         return self.itemArray.count;
    }
    else if (section == 1)
    {
        if(_fictionDetailModel.fictionCommentModel.count>0)
        {
            if(_fictionDetailModel.fictionCommentModel.count>0)
            {
                            return _fictionDetailModel.fictionCommentModel.count+2;
            }
            else
            {
                            return _fictionDetailModel.fictionCommentModel.count+1;
            }

        }
        else
        {
            return _fictionDetailModel.fictionCommentModel.count+1;
        }
    }
    else if (section == 2)
    {
        return _recommentArray.count;
    }
   
    return 0;
}

- (id) objectForIndexPath : (NSIndexPath *) indexPath {
    
    NSMutableArray *objArray = [NSMutableArray new];

    if (indexPath.section ==0)
    {
        NSString *value =[_itemArray objectAtIndex:indexPath.row];
        [objArray safe_addObject:value];
        [objArray safe_addObject:_fictionDetailModel];
    }
    else if (indexPath.section == 1)
    {
        if(indexPath.row ==0)
        {
            [objArray safe_addObject:@"commenthead"];
            [objArray safe_addObject:_fictionDetailModel];
        }
        else if(indexPath.row ==_fictionDetailModel.fictionCommentModel.count+1)
        {
            [objArray safe_addObject:@"commentfoot"];
            [objArray safe_addObject:_fictionDetailModel];
        }
        else
        {
            [objArray safe_addObject:@"comment"];
            [objArray safe_addObject:[_fictionDetailModel.fictionCommentModel objectAtIndex:indexPath.row-1]];
        }
    }
    else if (indexPath.section == 2)
    {
        NSString *value =[_recommentArray objectAtIndex:indexPath.row];
        [objArray safe_addObject:value];
        [objArray safe_addObject:_fictionDetailModel];
    }
    return objArray;
}

@end
