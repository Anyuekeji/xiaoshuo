//
//  AYFictionVIewModle.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionViewModle.h"
#import "AYFictionModel.h"
#import "AYBannerModel.h"
#import "AYCartoonModel.h"
#import "AYBookModel.h"

@interface AYFictionViewModle ()
{
}
/**
 *  数据源
 */
@property (nonatomic, strong) NSMutableArray * fictionArray;//用户最爱小说列表数据 （打赏用户多）
//@property (nonatomic, strong) NSMutableArray * fictionGuessArray;//猜你喜欢小说列表数据 （购买用户多）
//@property (nonatomic, strong) NSMutableArray * fictionBuyArray;//用户购买小说列表数据 （购买用户多）
@property (nonatomic, strong) NSMutableArray * fictionLanterSlideArray;//小说轮播图数据
@property (nonatomic, strong) NSMutableArray * fictionFreeArray;//免费数据
@property (nonatomic, strong) NSMutableArray * fictiontimeFreeArray;//限时免费
@property (nonatomic, strong) NSMutableArray * fictionRecommendArray;//小说推荐
@property (nonatomic, strong) NSMutableArray * cartoonRecommendArray;//精品漫画推荐

@property (nonatomic, strong) NSMutableArray * fictionSectionTitle;//精品漫画推荐

@property (nonatomic, strong) NSMutableArray * fictionSectionObjArray;//section 对应的内容对象
@property (nonatomic, strong) NSMutableArray * fictionSectionIconArray;//section 对应的icon
@property (nonatomic, strong) NSMutableArray * cartoonArray;//漫画列表数据

@property (nonatomic, assign) int page;//小说页数
@property (nonatomic, assign) int searchPage;//搜索小说页数

@end
@implementation AYFictionViewModle
- (void) setUp {
    [super setUp];
    _fictionArray = [NSMutableArray array];
    _fictionFreeArray = [NSMutableArray array];
    _fictiontimeFreeArray = [NSMutableArray array];
    _fictionRecommendArray = [NSMutableArray array];
    _fictionLanterSlideArray = [NSMutableArray array];
    _cartoonRecommendArray = [NSMutableArray array];
    _cartoonArray = [NSMutableArray array];

    _fictionSectionTitle = [NSMutableArray arrayWithObjects:@"最新推荐",@"限时免费",@"免费专区",@"精品漫画",@"热门畅销", nil];
    _fictionSectionObjArray = [NSMutableArray arrayWithObjects:_fictionRecommendArray,_fictiontimeFreeArray,_fictionFreeArray,_cartoonRecommendArray,_fictionArray, nil];
    _fictionSectionIconArray = [NSMutableArray arrayWithObjects:@"Fiction_Recommend",@"Fiction_Free",@"Fiction_Free",@"Fiction_Cartoon",@"Fiction_Hot", nil];

    _page =1;
    _searchPage =1;
}
- (void) getFictionListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock {
    //先读缓存
    if(self.fictionArray.count<=0)
    {
        NSArray<AYFictionModel*> *fictionList = [AYFictionModel r_allObjects];
        if (fictionList && fictionList.count>0)
        {
            [self.fictionArray safe_addObjectsFromArray:fictionList];
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
    [ZWNetwork post:@"HTTP_Post_Fiction_List" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYFictionModel itemsWithArray:record];
             if (isRefresh) {
                 [self.fictionArray removeAllObjects];
                 [AYFictionModel r_deleteAll];
                 [AYFictionModel r_saveOrUpdates:itemArray];
             }
             if(self.viewType == AYFictionViewTypeLove)
             {
                 if (itemArray.count<DEFAUT_PAGE_SIZE) {
                     self->_notAnyMoreData = YES;
                 }
                 else
                 {
                     self->_notAnyMoreData = NO;
                 }
             }
             [self.fictionArray safe_addObjectsFromArray:itemArray];
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
- (void) getRecommendFictionListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Fiction_Rec" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYFictionModel itemsWithArray:record];
             if (isRefresh) {
                 [self.fictionRecommendArray removeAllObjects];
             }
             if (self.viewType == AYFictionViewTypeHome) {
                              [self.fictionRecommendArray addObject:[AYFictionModel new]];//用于collectionview不能滑动顶部和底部的问题
             }

             [self.fictionRecommendArray safe_addObjectsFromArray:itemArray];
             if (self.viewType == AYFictionViewTypeHome) {
                 [self.fictionRecommendArray addObject:[AYFictionModel new]];//用于collectionview不能滑动顶部和底部的问题
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
- (void) getFictionFreeListDataByAction : (BOOL) isRefresh success : (void(^)()) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if (isRefresh) {
        self.page =1;
    }
    else
    {
        self.page+=1;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(self.page) forKey:@"page"];  //页数
    }];
    [ZWNetwork post:@"HTTP_Post_Free_Area" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             
             NSArray *itemArray = [AYBookModel itemsWithArray:record];
             if (isRefresh) {
                 [self.fictionFreeArray removeAllObjects];
             }
             if(self.viewType == AYFictionViewTypeFree)
             {
                 if (itemArray.count<DEFAUT_PAGE_SIZE) {
                     self->_notAnyMoreData = YES;
                 }
                 else
                 {
                     self->_notAnyMoreData = NO;
                 }
             }
             [self.fictionFreeArray safe_addObjectsFromArray:itemArray];
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
- (void) getFictionListDataBySearchText : (NSString*) searchText refresh:(BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:searchText forKey:@"other_name"]; //小说名字
    }];
    [ZWNetwork post:@"HTTP_Post_Search" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYBookModel itemsWithArray:record];
             if (isRefresh) {
                 [self.fictionFreeArray removeAllObjects];
             }
             if (itemArray.count<DEFAUT_PAGE_SIZE) {
                 self->_notAnyMoreData = YES;
             }
             else
             {
                 self->_notAnyMoreData = NO;
             }
             [self.fictionFreeArray safe_addObjectsFromArray:itemArray];
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

- (void) getFictionBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
{
    //先读缓存
    if(self.fictionLanterSlideArray.count<=0)
    {
        NSArray<AYBannerModel*> *bannerList = [self localFictionBanner];
        if (bannerList && bannerList.count>0)
        {
            [self.fictionLanterSlideArray safe_addObjectsFromArray:bannerList];
            if (completeBlock) {
                completeBlock();
            }
        }
    }
    [ZWNetwork post:@"HTTP_Post_Fiction_Banner" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             [self.fictionLanterSlideArray removeAllObjects];
             NSArray *itemArray = [AYBannerModel itemsWithArray:record];
             [self deleteLocalFictionBanner];
             [AYBannerModel r_saveOrUpdates:itemArray];
             [self.fictionLanterSlideArray safe_addObjectsFromArray:itemArray];
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
- (void) getFreeBookBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Free_Banner" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             [self.fictionLanterSlideArray removeAllObjects];
             NSArray *itemArray = [AYBannerModel itemsWithArray:record];
             [self.fictionLanterSlideArray safe_addObjectsFromArray:itemArray];
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
- (void) getTimeFictionFreeListDataByAction : (BOOL) isRefresh success : (void(^)(long endTime)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
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
    [ZWNetwork post:@"HTTP_Post_Fiction_Free_List" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             if(record[@"data"])
             {
                 NSArray *itemArray = [AYFictionModel itemsWithArray:record[@"data"]];
                 if (isRefresh) {
                     [self.fictiontimeFreeArray removeAllObjects];
                 }
                 if(self.viewType == AYFictionViewTypeFree)
                 {
                     if (itemArray.count<DEFAUT_PAGE_SIZE) {
                         self->_notAnyMoreData = YES;
                     }
                     else
                     {
                         self->_notAnyMoreData = NO;
                     }
                 }
                 [self.fictiontimeFreeArray safe_addObjectsFromArray:itemArray];
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
- (void) getRecommendCartoonDataByAction: (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{

    [ZWNetwork post:@"HTTP_Post_Cartoon_Rec" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
               NSArray *itemArray = [AYCartoonModel itemsWithArray:record];
                if (isRefresh) {
                     [self.cartoonRecommendArray removeAllObjects];
                 }
             if(self.viewType == AYFictionViewTypeCartoon)
             {
                 if (itemArray.count<DEFAUT_PAGE_SIZE) {
                     self->_notAnyMoreData = YES;
                 }
                 else
                 {
                     self->_notAnyMoreData = NO;
                 }
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
- (void) getCartoonBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
{
    //先读缓存
    if(self.fictionLanterSlideArray.count<=0)
    {
        NSArray<AYBannerModel*> *bannerList = [self localCartoonBanner];
        if (bannerList && bannerList.count>0)
        {
            [self.fictionLanterSlideArray safe_addObjectsFromArray:bannerList];
            if (completeBlock) {
                completeBlock();
            }
        }
    }
    [ZWNetwork post:@"HTTP_Post_Cartoon_Banner" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             [self.fictionLanterSlideArray removeAllObjects];
             NSArray *itemArray = [AYBannerModel itemsWithArray:record];
             if(itemArray && itemArray.count>0)
             {
                 [self deleteLocalCartoonBanner];
                 [AYBannerModel r_saveOrUpdates:itemArray];
                 [self.fictionLanterSlideArray safe_addObjectsFromArray:itemArray];
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
#pragma mark - db -

-(void)deleteLocalFictionBanner
{
    NSString *qureyStr = [NSString stringWithFormat:@"bannerShowType = %d ",1];
    NSArray<AYBannerModel*> *localBannerArray = [AYBannerModel r_query:qureyStr];
    if(localBannerArray)
    {
        [AYBannerModel r_deletes:localBannerArray];//先删除
    }
}

-(NSArray<AYBannerModel*> *)localFictionBanner
{
    NSString *qureyStr = [NSString stringWithFormat:@"bannerShowType = %d ",1];
    NSArray<AYBannerModel*> *localBannerArray = [AYBannerModel r_query:qureyStr];
    return localBannerArray;
}

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
- (NSInteger)numberOfSections
{
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
        return _fictionSectionTitle.count;
    }
    return 1;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    if (_viewType == AYFictionViewTypeTimeFree)
    {
        return _fictiontimeFreeArray.count;
    }
    else if (_viewType == AYFictionViewTypeFree)
    {
        return _fictionFreeArray.count;
    }
    else if (_viewType == AYFictionViewTypeRcommmend)
    {
        return _fictionRecommendArray.count;
    }
    else if (_viewType == AYFictionViewTypeCartoon)
    {
        return self.cartoonArray.count;
    }
    else if (_viewType == AYFictionViewTypeHome) //小说首页
    {
        if (section == 4) //热门小说
        {
            return self.fictionArray.count;
        }
        else
        {
            return 1;
        }
    }
    return self.fictionArray.count;
}
- (id) objectForIndexPath : (NSIndexPath *) indexPath
{
    if (_viewType == AYFictionViewTypeTimeFree)
    {
        if ( indexPath.row < self.fictiontimeFreeArray.count )
        {
            id object = [self.fictiontimeFreeArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYFictionModel.class] ) {
                
                return object;
            }
        }
    }
    else if (_viewType == AYFictionViewTypeRcommmend)
    {
        if ( indexPath.row < self.fictionRecommendArray.count )
        {
            id object = [self.fictionRecommendArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYFictionModel.class] )
            {
                return object;
            }
        }
    }
    else if (_viewType == AYFictionViewTypeCartoon)
    {
        if ( indexPath.row < self.cartoonArray.count )
        {
            id object = [self.cartoonArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYCartoonModel.class] )
            {
                return object;
            }
        }
    }
    else if (_viewType == AYFictionViewTypeFree)
    {
        if ( indexPath.row < self.fictionFreeArray.count )
        {
            id object = [self.fictionFreeArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYBookModel.class] )
            {
                return object;
            }
        }
    }
    else if (_viewType == AYFictionViewTypeHome)
    {
        NSString *sectionTitle = _fictionSectionTitle[indexPath.section];
        if ([sectionTitle isEqualToString:@"最新推荐"]) {
            return [_fictionSectionObjArray safe_objectAtIndex:indexPath.section];
        }
        else if ([sectionTitle isEqualToString:@"热门畅销"]) {
            if ( indexPath.row < self.fictionArray.count )
            {
                id object = [self.fictionArray objectAtIndex:indexPath.row];
                if ( [object isKindOfClass:AYFictionModel.class] ) {
                    return object;
                }
            }
        }
        else
        {
            NSMutableArray *tempArray = [_fictionSectionObjArray safe_objectAtIndex:indexPath.section];
            NSArray *fictionRecArray = [tempArray subarrayWithRange:NSMakeRange(0, (tempArray.count>3)?3:(tempArray.count))];
            return fictionRecArray;
        }
    }
    else
    {
        if ( indexPath.row < self.fictionArray.count )
        {
            id object = [self.fictionArray objectAtIndex:indexPath.row];
            if ( [object isKindOfClass:AYFictionModel.class] ) {
                return object;
            }
        }
    }
    return nil;
}

- (NSIndexPath *) indexPathForObject : (id) object {
    if ( object ) {
        if ( [self.fictionArray containsObject:object] ) {
            NSUInteger index = [self.fictionArray indexOfObject:object];
            return [NSIndexPath indexPathForRow:index inSection:3];
        }
    }
    return nil;
}
- (NSString*) getSectionTitle:(NSInteger)section
{
    return _fictionSectionTitle[section];
}

- (NSString*) getSectionIcon:(NSInteger)section
{
    return _fictionSectionIconArray[section];
}
- (NSInteger) getSectionIndex:(NSString*)title
{
    if ([_fictionSectionTitle containsObject:title]) {
        return [_fictionSectionTitle indexOfObject:title];

    }
    return 0;
}

-(void)clearList
{
    [self.fictionArray removeAllObjects];
}
#pragma mark - icaouse Used -
/**
 *  轮播图的页数
 */
- (NSUInteger) numberOfPageInRotateScrollView
{
    return [_fictionLanterSlideArray count];
}
/**
 *  轮播图某一页的数据
 */
- (id) objectForPage:(NSInteger)pageIndex
{
    return [_fictionLanterSlideArray safe_objectAtIndex:pageIndex];
}
@end
