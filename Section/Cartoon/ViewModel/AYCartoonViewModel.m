//
//  AYCartoonViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonViewModel.h"
#import "AYCartoonModel.h"
#import "AYBannerModel.h"
@interface AYCartoonViewModel ()
{
    
}
/**
 *  数据源
 */
@property (nonatomic, strong) NSMutableArray * cartoonArray;//漫画列表数据
@property (nonatomic, strong) NSMutableArray * cartoonGuessArray;//猜你喜欢漫画列表数据 （购买用户多）
@property (nonatomic, strong) NSMutableArray * cartoonBuyArray;//用户购买漫画列表数据 （购买用户多）
@property (nonatomic, strong) NSMutableArray * cartoonFreeArray;//免费数据
@property (nonatomic, strong) NSMutableArray * cartoonRecommendArray;//推荐数据
@property (nonatomic, strong) NSMutableArray * cartoonLanterSlideArray;//漫画轮播图数据
@property (nonatomic, assign) int page;//小说页数
@property (nonatomic, assign) int searchPage;//搜索小说页数

@end
@implementation AYCartoonViewModel
- (void) setUp {
    [super setUp];
    _cartoonArray = [NSMutableArray array];
    _cartoonFreeArray = [NSMutableArray array];
    _cartoonRecommendArray = [NSMutableArray array];
    _cartoonLanterSlideArray = [NSMutableArray array];
    _cartoonBuyArray = [NSMutableArray array];
    _cartoonGuessArray = [NSMutableArray array];
    _page =1;
    _searchPage =1;
}

- (void) getCartoonListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock {
    
    //先读缓存
    if(self.cartoonArray.count<=0)
    {
        NSArray<AYCartoonModel*> *fictionList = [AYCartoonModel r_allObjects];
        if (fictionList && fictionList.count>0)
        {
            [self.cartoonArray safe_addObjectsFromArray:fictionList];
            if (completeBlock) {
                completeBlock();
            }
        }
    }
    if (isRefresh) {
        self.page =1;
    }
    else
    {
        self.page+=1;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(self.page) forKey:@"page"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_Cartoon_List" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYCartoonModel itemsWithArray:record];
             if (isRefresh) {
                 [self.cartoonArray removeAllObjects];
                 [AYCartoonModel r_deleteAll];
                 [AYCartoonModel r_saveOrUpdates:itemArray];
             }
             if (itemArray.count<DEFAUT_PAGE_SIZE) {
                 self->_notAnyMoreData = YES;
             }
             else
             {
                 self->_notAnyMoreData = NO;
             }
             [self.cartoonArray safe_addObjectsFromArray:itemArray];
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

- (void) getRecommendCartoonListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Cartoon_Rec" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYCartoonModel itemsWithArray:record];
             if (isRefresh) {
                 [self.cartoonRecommendArray removeAllObjects];
             }
             
             [self.cartoonRecommendArray safe_addObjectsFromArray:itemArray];
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
- (void) getCartoonFreeListDataByAction : (BOOL) isRefresh success : (void(^)(long endTime)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if (isRefresh) {
        self.page =1;
    }
    else
    {
        self.page+=1;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(self.page) forKey:@"page"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_Cartoon_Free_List" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             if(record[@"data"])
             {
                 NSArray *itemArray = [AYCartoonModel itemsWithArray:record[@"data"]];
                 if (isRefresh) {
                     [self.cartoonFreeArray removeAllObjects];
                 }
                 if (self.viewType == AYFictionViewTypeFree) {
                     if (itemArray.count<DEFAUT_PAGE_SIZE) {
                         self->_notAnyMoreData = YES;
                     }
                     else
                     {
                         self->_notAnyMoreData = NO;
                     }
                 }
        
                 [self.cartoonFreeArray safe_addObjectsFromArray:itemArray];
             }
             if(![record[@"end_time"] isKindOfClass:NSNull.class])
             {
                 if (completeBlock) {
                     completeBlock([record[@"end_time"] longLongValue]);
                 }
             }
             else
             {
                 if (completeBlock) {
                     completeBlock(0);
                 }
             }
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];

}
- (void) getCartoonListBySearchText : (NSString*) searchText refresh:(BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if (isRefresh) {
        self.searchPage =1;
    }
    else
    {
        self.searchPage+=1;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
    [params addValue:@(self.searchPage) forKey:@"page"]; //页数
    [params addValue:searchText forKey:@"other_name"]; //小说名字
    
}];
    [ZWNetwork post:@"HTTP_Post_Cartoon_List" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYCartoonModel itemsWithArray:record];
             if (isRefresh) {
                 [self.cartoonArray removeAllObjects];
             }
             if (itemArray.count<DEFAUT_PAGE_SIZE) {
                 self->_notAnyMoreData = YES;
             }
             else
             {
                 self->_notAnyMoreData = NO;
             }
             [self.cartoonArray safe_addObjectsFromArray:itemArray];
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

- (void) getCartoonUserBuyListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if (isRefresh)
    {
        self.page =1;
    }
    else
    {
        self.page+=1;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(self.page) forKey:@"page"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_Cartoon_Hot" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYCartoonModel itemsWithArray:record];
             if (isRefresh)
             {
                 [self.cartoonBuyArray removeAllObjects];
             }
             if (self.viewType == AYFictionViewTypeChuangxiao) {
                 if (itemArray.count<DEFAUT_PAGE_SIZE) {
                     self->_notAnyMoreData = YES;
                 }
                 else
                 {
                     self->_notAnyMoreData = NO;
                 }
             }
             
             [self.cartoonBuyArray safe_addObjectsFromArray:itemArray];
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

- (void) getCartoonGuessListDataBySuccess : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Cartoon_Random" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYCartoonModel itemsWithArray:record];
             [self.cartoonGuessArray removeAllObjects];
             [self.cartoonGuessArray safe_addObjectsFromArray:itemArray];
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
- (void) getCartoonBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
{
    
    //先读缓存
    if(self.cartoonLanterSlideArray.count<=0)
    {
        NSArray<AYBannerModel*> *bannerList = [self localCartoonBanner];
        if (bannerList && bannerList.count>0)
        {
            [self.cartoonLanterSlideArray safe_addObjectsFromArray:bannerList];
            if (completeBlock) {
                completeBlock();
            }
        }
    }
    [ZWNetwork post:@"HTTP_Post_Cartoon_Banner" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             [self.cartoonLanterSlideArray removeAllObjects];
             NSArray *itemArray = [AYBannerModel itemsWithArray:record];
             if(itemArray && itemArray.count>0)
             {
                 [self deleteLocalCartoonBanner];
                 [AYBannerModel r_saveOrUpdates:itemArray];
                 [self.cartoonLanterSlideArray safe_addObjectsFromArray:itemArray];
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
#pragma mark - db -

-(void)deleteLocalCartoonBanner
{
        NSString *qureyStr = [NSString stringWithFormat:@"bannerShowType = %d ",2];
        NSArray<AYBannerModel*> *localBannerArray = [AYBannerModel r_query:qureyStr];
        if(localBannerArray)
        {
            [AYBannerModel r_deletes:localBannerArray];//先删除
        }
}

-(NSArray<AYBannerModel*> *)localCartoonBanner
{
    NSString *qureyStr = [NSString stringWithFormat:@"bannerShowType = %d ",2];
    NSArray<AYBannerModel*> *localBannerArray = [AYBannerModel r_query:qureyStr];
    return localBannerArray;
}
#pragma mark - Table Used
- (NSInteger)numberOfSections {
    if (_viewType == AYFictionViewTypeFree)
    {
        return 1;
    }
    else if (_viewType == AYFictionViewTypeRcommmend)
    {
        return 1;
    }
    else if (_viewType == AYFictionViewTypeHome)
    {
        
        return 5;
    }
    return 1;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section {
    if (_viewType == AYFictionViewTypeFree)
    {
        return _cartoonFreeArray.count;
    }
    else if (_viewType == AYFictionViewTypeRcommmend)
    {
        return _cartoonRecommendArray.count;
    }
    else if (_viewType == AYFictionViewTypeHome)
    {
        if (section == 0) {
            return 2;
        }
        else if (section == 1 || section == 3 || section == 4) {
            return 1;
        }
        if (section == 2) {
            return 3;
        }
    }
    else if (_viewType == AYFictionViewTypeChuangxiao)
    {
        return _cartoonBuyArray.count;
    }
    return self.cartoonArray.count;
}

- (id) objectForIndexPath : (NSIndexPath *) indexPath {
    
    if (_viewType == AYFictionViewTypeFree)
    {
        if ( indexPath.row < self.cartoonFreeArray.count )
        {
            id object = [self.cartoonFreeArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYCartoonModel.class] ) {
                
                return object;
            }
        }
    }
    else if (_viewType == AYFictionViewTypeRcommmend)
    {
        if ( indexPath.row < self.cartoonRecommendArray.count )
        {
            id object = [self.cartoonRecommendArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYCartoonModel.class] ) {
                
                return object;
            }
        }
    }
    else if (_viewType == AYFictionViewTypeChuangxiao)
    {
        if ( indexPath.row < self.cartoonBuyArray.count )
        {
            id object = [self.cartoonBuyArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYCartoonModel.class] )
            {
                return object;
            }
        }
    }
    else if (_viewType == AYFictionViewTypeHome)
    {
        if (indexPath.section == 0)
        {
            if(indexPath.row ==0)
            {
                if ( indexPath.row < self.cartoonRecommendArray.count )
                {
                    id object = [self.cartoonRecommendArray objectAtIndex:indexPath.row];
                    if ( [object isKindOfClass:AYCartoonModel.class] ) {
                        
                        return object;
                    }
                }
            }
            else
            {
                if (self.cartoonRecommendArray.count>1) {
                    NSArray *fictionRecArray = [_cartoonRecommendArray subarrayWithRange:NSMakeRange(1, (_cartoonRecommendArray.count>4)?3:(_cartoonRecommendArray.count-1))];
                    return fictionRecArray;
                }
                
            }
            
        }
        else if (indexPath.section == 1)
        {
            if (_cartoonFreeArray.count>0)
            {
                NSArray *fictionRecArray = [_cartoonFreeArray subarrayWithRange:NSMakeRange(0, (_cartoonFreeArray.count>3)?3:(_cartoonFreeArray.count))];
                return fictionRecArray;
            }
            return nil;        }
        else if (indexPath.section == 2) //用户最爱
        {
            if ( indexPath.row < self.cartoonArray.count )
            {
                id object = [self.cartoonArray objectAtIndex:indexPath.row];
                if ( [object isKindOfClass:AYCartoonModel.class] ) {
                    
                    return object;
                }
            }
            
        }
        else if (indexPath.section == 3) //热门畅销
        {
            if (_cartoonBuyArray.count>0)
            {
                NSArray *fictionRecArray = [_cartoonBuyArray subarrayWithRange:NSMakeRange(0, (_cartoonBuyArray.count>3)?3:(_cartoonBuyArray.count))];
                return fictionRecArray;
            }
            return nil;
            
        }
        else if (indexPath.section == 4) //猜你喜欢
        {
            if (_cartoonGuessArray.count>0)
            {
                NSArray *fictionRecArray = [_cartoonGuessArray subarrayWithRange:NSMakeRange(0, (_cartoonGuessArray.count>3)?3:(_cartoonGuessArray.count))];
                return fictionRecArray;
            }
            return nil;
        }
    }
    else
    {
        if ( indexPath.row < self.cartoonArray.count )
        {
            id object = [self.cartoonArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYCartoonModel.class] ) {
                
                return object;
            }
        }
    }
    return nil;
}

- (NSIndexPath *) indexPathForObject : (id) object {
    if ( object ) {
        if ( [self.cartoonArray containsObject:object] ) {
            NSUInteger index = [self.cartoonArray indexOfObject:object];
            return [NSIndexPath indexPathForRow:index inSection:3];
        }
    }
    return nil;
}
-(void)clearList
{
    [self.cartoonArray removeAllObjects];
}
#pragma mark - icaouse Used -

/**
 *  轮播图的页数
 */
- (NSUInteger) numberOfPageInRotateScrollView
{
    return [_cartoonLanterSlideArray count];
}
/**
 *  轮播图某一页的数据
 */
- (id) objectForPage:(NSInteger)pageIndex
{
    return [_cartoonLanterSlideArray safe_objectAtIndex:pageIndex];
}
@end
