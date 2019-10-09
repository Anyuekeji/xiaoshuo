//
//  AYSearchViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/13.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYSearchViewModel.h"
#import "AYBookModel.h" //书本model
#import "AYFictionModel.h" //

@interface AYSearchViewModel ()
{
}
/**
 *  数据源
 */
@property (nonatomic, strong) NSMutableArray * hotSearchTextArray;//热门搜索字
@property (nonatomic, strong) NSMutableArray * hotBookArray;//人气小说
@end
@implementation AYSearchViewModel
- (void) setUp
{
    [super setUp];
    _hotSearchTextArray = [NSMutableArray array];
    _hotBookArray = [NSMutableArray array];
}

- (void) getHotSearchListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Hot_Search" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             
             NSArray *itemArray = [AYBookModel itemsWithArray:record];
             if (isRefresh) {
                 [self.hotSearchTextArray removeAllObjects];
             }
             [self.hotSearchTextArray safe_addObjectsFromArray:itemArray];
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
- (void) getHotBookListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(1) forKey:@"page"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_Fiction_List" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYFictionModel itemsWithArray:record];
             if (isRefresh) {
                 [self.hotBookArray removeAllObjects];
             }
             [self.hotBookArray safe_addObjectsFromArray:[itemArray subarrayWithRange:NSMakeRange(0, (itemArray.count>6?6:itemArray.count))]];
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
- (NSInteger)numberOfSections
{
    return 2;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    if (section ==0)
    {
        return _hotSearchTextArray.count;
    }
    else
    {
        return _hotBookArray.count;
    }
}

- (id) objectForIndexPath : (NSIndexPath *) indexPath
{
    if (indexPath.section ==0)
    {
        return [_hotSearchTextArray safe_objectAtIndex:indexPath.row];
    }
    else
    {
        return [_hotBookArray safe_objectAtIndex:indexPath.row];
    }}
@end
