//
//  AYNewCartoonDetailViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/4/7.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYNewCartoonDetailViewModel.h"
#import "AYCartoonDetailModel.h"
@interface AYNewCartoonDetailViewModel ()
@property(nonatomic,strong) NSArray *recommentArray; //推荐数据

@property(nonatomic,strong) NSArray *itemArray; //小说总章节数
@end

@implementation AYNewCartoonDetailViewModel
- (void) setUp
{
    [super setUp];
    _cartoonDetailModel = [AYCartoonDetailModel new];
    _itemArray = [NSArray arrayWithObjects:@"reward",@"head",@"empty",@"menu",@"invate",@"charge",@"empty",nil];
    _recommentArray =[NSArray arrayWithObjects:@"empty",@"recomment",nil];
    
}
- (void) getCartoonDetailDataByCartoonModel:(AYCartoonModel*) cartoonModel complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@([cartoonModel.cartoonID intValue]) forKey:@"cartoon_id"];
    }];
    [ZWNetwork post:@"HTTP_Post_Cartoon_Detail" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class]){
             self.cartoonDetailModel = [AYCartoonDetailModel itemWithRecord:record];
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
-(void)getCartoonRecommend:(AYCartoonModel*) cartoonModel complete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@([cartoonModel.cartoonID intValue]) forKey:@"cartoon_id"];
    }];
    [ZWNetwork post:@"HTTP_Post_Cartoon_Recommend" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class]){
             NSArray *itemArray = [AYCartoonModel itemsWithArray:record];
             if(self.cartoonDetailModel)
             {
                 if (!self.cartoonDetailModel.cartoonRecommendList) {
                     self.cartoonDetailModel.cartoonRecommendList = [NSMutableArray new];
                 }
                 [self.cartoonDetailModel.cartoonRecommendList safe_addObjectsFromArray:itemArray];
                 //删除跟同一本书
                 [self.cartoonDetailModel.cartoonRecommendList enumerateObjectsUsingBlock:^(AYCartoonModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if ([obj.cartoonID isEqualToString:cartoonModel.cartoonID]) {
                         [self.cartoonDetailModel.cartoonRecommendList removeObject:obj];
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
        if(_cartoonDetailModel.cartoonCommentModel.count>0)
        {
            return _cartoonDetailModel.cartoonCommentModel.count+2;
        }
        else
        {
            return _cartoonDetailModel.cartoonCommentModel.count+1;
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
        [objArray safe_addObject:_cartoonDetailModel];
    }
    else if (indexPath.section == 1)
    {
        if(indexPath.row ==0)
        {
            [objArray safe_addObject:@"commenthead"];
            [objArray safe_addObject:_cartoonDetailModel];
        }
        else if(indexPath.row ==_cartoonDetailModel.cartoonCommentModel.count+1)
        {
            [objArray safe_addObject:@"commentfoot"];
            [objArray safe_addObject:_cartoonDetailModel];
        }
        else
        {
            [objArray safe_addObject:@"comment"];
            [objArray safe_addObject:[_cartoonDetailModel.cartoonCommentModel objectAtIndex:indexPath.row-1]];
        }
    }
    else if (indexPath.section == 2)
    {
        NSString *value =[_recommentArray objectAtIndex:indexPath.row];
        [objArray safe_addObject:value];
        [objArray safe_addObject:_cartoonDetailModel];
    }
    return objArray;
}
@end
