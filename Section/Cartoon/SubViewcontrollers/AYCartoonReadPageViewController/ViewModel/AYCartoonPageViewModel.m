//
//  AYCartoonPageViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonPageViewModel.h"
#import "AYCartoonChapterModel.h"
#import "AYCartoonChapterContentModel.h" //章节内容model
#import "AYCartoonReadModel.h" //漫画的阅读状态
#import "CYFictionChapterModel.h"
#import "ZWCacheHelper.h"
#import "AYCartoonCatlogMananger.h" //漫画目录管理
#import "AYCartoonImageDownloadManager.h" //图片下载管理
#import "AYReadStatisticsManager.h" //统计
#import "AYAdmobManager.h"

@interface AYCartoonPageViewModel ()
//@property(nonatomic,strong) AYCartoonChapterModel *cartoonDetailModel; //小说总章节数
@property(nonatomic,assign) NSInteger totalChapters; //小说总章节数
//@property(nonatomic,strong) NSMutableArray<AYCartoonChapterModel*> *cartoonChapterArray; //小说所有章节

@property (nonatomic, strong) NSMutableDictionary<NSNumber*,AYCartoonChapterContentModel*> *cartoonChapterDic; //漫画章节信息字典
@end
@implementation AYCartoonPageViewModel
- (void) setUp
{
    [super setUp];
   // _cartoonChapterArray = [NSMutableArray new];
     _cartoonCatelogArray = [NSMutableArray new];
    _cartoonChapterDic =[NSMutableDictionary new];
    _currentChapterIndex =0;

}
-(void)startLoadCartoon:(NSInteger) startChapterIndex success:(void(^)(AYResultType failType)) completeBlock failure : (void(^)(NSString * errorString,AYResultType resultType)) failureBlock
{
    
    if (startChapterIndex<=-1)//读缓存取阅读状态
    {
        AYCartoonReadModel *readModle = [self localCartoonReadModel];
  
        if (readModle) {
            if(readModle.currrenReadSectionIndex)
            {
                //加载章节内容需要提前渲染  第一页时加载前两章节 其他加载前后当前三章
                NSInteger currentSectionIndex = [readModle.currrenReadSectionIndex integerValue];
                self.currentChapterIndex = currentSectionIndex;
            }
        }
       [[AYCartoonImageDownloadManager shared] setCurrentChapterIndex:self.currentChapterIndex];
    }
    else//用户指定某一章
    {
        self.currentChapterIndex = startChapterIndex;
        //看内存是否有 有就不指定当前章节 没有就指定
        if (![self.cartoonChapterDic objectForKey:@(self.currentChapterIndex)])
        {
                if (self.currentChapterIndex!=[AYCartoonImageDownloadManager shared].currentChapterIndex)
                {
                    [[AYCartoonImageDownloadManager shared] canleAllOperation];
                    [[AYCartoonImageDownloadManager shared] setCurrentChapterIndex:self.currentChapterIndex];
                }
        }
    
    }
    [self getCartoonCatalog:^{
        if (self.currentChapterIndex<=0) {
            [self getCartoonChapterDataByIndex:@[@(self.currentChapterIndex),@(self.currentChapterIndex+1)] success:completeBlock failure:failureBlock];
        }
        else
        {
            [self getCartoonChapterDataByIndex:@[@(self.currentChapterIndex),@(self.currentChapterIndex+1),@(self.currentChapterIndex-1)] success:completeBlock failure:failureBlock];
        }
    } failure:^(NSString *errorString) {
        
        if (failureBlock) {
            failureBlock(errorString,AYCurrent);
        }
    }];
}
- (void) getCartoonChapterDataByIndex:(NSArray*)chatperIndexArray success:(void(^)(AYResultType failType)) completeBlock failure : (void(^)(NSString * errorString,AYResultType resultType))failureBlock
{
    [chatperIndexArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self loadChatperWithIndex:[obj intValue] success:completeBlock failure:failureBlock];
    }];
}

-(void)downLoadChatperResult:(int)chatperIndex success:(void(^)(AYResultType failType)) completeBlock failure : (void(^)(NSString*errorString,AYResultType resultType)) failureBlock
{
    if (completeBlock) {
        if (chatperIndex == self.currentChapterIndex)
        {
            if (completeBlock) {
                completeBlock(AYCurrent);
            }
        }
        else if (chatperIndex == self.currentChapterIndex-1)
        {
            if (completeBlock) {
                completeBlock(AYPre);
            }
            
        }
        else if (chatperIndex == self.currentChapterIndex+1)
        {
            if (completeBlock) {
                completeBlock(AYNext);
            }
        }
    }
}

/**
 *  获取对象
 */
- (id) objectForIndexPath : (NSInteger ) index
{
    return [_cartoonChapterDic objectForKey:@(index)];
}
/**
 *  下一章
 */
-(void)nextChapter:(void(^)(AYResultType resultType)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    AYLog(@"into nextChapter");
    if (self.currentChapterIndex>=_totalChapters) {
        self.currentChapterIndex =_totalChapters;
        occasionalHint(AYLocalizedString(@"已是最后一章了"));
        return;
    }
    if([self isNeedShowAD])
    {
        [[AYReadStatisticsManager shared] userReadFinishOneChapter:[self getCurrentMenuChapterModel].cartoonId    chapterId:[[self getCurrentMenuChapterModel].cartoonChapterId stringValue]];
    }
    self.currentChapterIndex+=1;
    if (completeBlock)
    {
        completeBlock(AYCurrent);
    }
    if (self.currentChapterIndex+1>self.totalChapters){
        return;
    }
  //修改图片加载顺序，优先加载当前章节的图片
    [[AYCartoonImageDownloadManager shared] changeLoadSort:_currentChapterIndex];

    [self getCartoonChapterDataByIndex:@[@(self.currentChapterIndex+1)] success:^(AYResultType failType)
     {
             [self clearPageInfoDic];
     

    } failure:^(NSString * _Nonnull errorString, AYResultType failType) {
            if (failureBlock) {
                failureBlock(errorString);
            }
    }];
}
/**
 *  上一章
 */
-(void)preChapter:(void(^)(AYResultType resultType)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    AYLog(@"into preChapter");
    if (self.currentChapterIndex<=0) {
        self.currentChapterIndex =0;
        
        return;
    }
    self.currentChapterIndex-=1;
    if (completeBlock) {
        completeBlock(AYCurrent);
    }
    if (self.currentChapterIndex-1<0){
        return;
    }
    if([self isNeedShowAD])
    {
        [[AYReadStatisticsManager shared] userReadFinishOneChapter:[self getCurrentMenuChapterModel].cartoonId    chapterId:[[self getCurrentMenuChapterModel].cartoonChapterId stringValue]];
    }
    self.currentChapterIndex-=1;
    if (completeBlock) {
        completeBlock(AYCurrent);
    }
    if (self.currentChapterIndex-1<0){
        return;
    }
    //修改图片加载顺序，优先加载当前章节的图片
    [[AYCartoonImageDownloadManager shared] changeLoadSort:_currentChapterIndex];
    [self getCartoonChapterDataByIndex:@[@(self.currentChapterIndex-1)] success:^(AYResultType failType) {
        [self clearPageInfoDic];
    } failure:^(NSString * _Nonnull errorString, AYResultType failType) {
        if (failureBlock) {
            failureBlock(errorString);
        }
    }];
}
-(void)clearPageInfoDic
{
    if (self.cartoonChapterDic.count<=3) {
        return;
    }
    NSMutableArray<NSNumber*> *willDeleteKeys = [NSMutableArray new];
    [self.cartoonChapterDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, AYCartoonChapterContentModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key integerValue]<self.currentChapterIndex-1 || [key integerValue]>self.currentChapterIndex+1) {
            [willDeleteKeys safe_addObject:key];
        }
    }];

    if (willDeleteKeys.count>0) {
        [self.cartoonChapterDic removeObjectsForKeys:willDeleteKeys];
    }
}
#pragma mark - public  -

-(AYCartoonChapterModel*)getCurrentMenuChapterModel
{
    AYCartoonChapterModel *chapterModle = [self.cartoonCatelogArray safe_objectAtIndex:self.currentChapterIndex];
    return chapterModle;
}
//解锁章节返回结果
-(void)chapterChargeResult:(CYFictionChapterModel*)chargeChapterModel success:(BOOL)success
{
    [self.cartoonCatelogArray enumerateObjectsUsingBlock:^(AYCartoonChapterModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.cartoonChapterId integerValue] ==[chargeChapterModel.fictionSectionID integerValue]) {
            _reset_db_item_(^{
                obj.unlock = @(YES);
            });
            return;
        }
    }];
}
- (BOOL)isAdvertiseSection
{
    AYCartoonChapterModel *chapterModel = [self getCurrentMenuChapterModel];
    if([chapterModel.needMoney integerValue] ==4 && ![chapterModel.unlock boolValue])
    {
        return YES;
    }
    return NO;
}
//判断是否需要显示广告
- (BOOL)isNeedShowAD
{
    if([self isAdvertiseSection])
    {
        BOOL isAdvertiseCoinUnlock = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFreeBookCoinUnlock];//是否设置成广告解锁
        if (!isAdvertiseCoinUnlock && ![[AYReadStatisticsManager shared] advertiseReadDayCountFinished])
        {
            [[AYAdmobManager shared] createGADRewardBasedVideoAd];

            return YES;
        }
    }
    return NO;
}
#pragma mark - network  -

-(void)loadImageInfoWith:(AYCartoonChapterContentModel*)contentModel chapterIndex:(NSInteger)chatperIndex
{
    NSInteger imageIndex =0;
    RLMArray *cartoonImageArray =contentModel.cartoonImageUrlArray;
    //把AYCartoonChapterImageUrlModel 由realm 管理变成 unmanager 不由realm管理 要不会出现线程访问错误
    for (AYCartoonChapterImageUrlModel *urlModel in cartoonImageArray)
    {
        [cartoonImageArray replaceObjectAtIndex:imageIndex withObject:[urlModel copy]];
        imageIndex ++;
    }
    
    LEWeakSelf(self)
    if (chatperIndex == self.currentChapterIndex)
    {
        [AYCartoonImageDownloadManager shared].cartoonImageLondingProgress = ^(CGFloat progress) {
            LEStrongSelf(self)
            if (self.cartoonImageLodingProgress)
            {
                self.cartoonImageLodingProgress(progress);
            }
        };
    }
        //提前加载
    [[AYCartoonImageDownloadManager shared] downLoadImageWith:(NSArray<AYCartoonChapterImageUrlModel*>*)_ZWConvertRLMArryToArray(contentModel.cartoonImageUrlArray) index:chatperIndex];
 

}
//获取本地小说目录
-(void)getCartoonCatalog: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if (self.cartoonCatelogArray.count>0) {
        if (completeBlock) {
            completeBlock();
        }
        return;
    }
    [[AYCartoonCatlogMananger shared] fetchCartoonCatlogWithCartoonId:self.currentChapterModel.cartoonId refresh:NO success:^(NSArray<AYCartoonChapterModel *> * _Nonnull cartoonCatlogArray ,int count_all,NSString * update_day) {
        if (cartoonCatlogArray && cartoonCatlogArray.count>0) {
            [self.cartoonCatelogArray removeAllObjects];
            [self.cartoonCatelogArray safe_addObjectsFromArray:cartoonCatlogArray];
            self.totalChapters = self.cartoonCatelogArray.count-1;
     
        }
        if (completeBlock) {
            completeBlock();
        }
    } failure:^(NSString * _Nonnull errorString) {
        if (failureBlock) {
            failureBlock(errorString);
        }
    }];
}
-(void)loadChatperWithIndex:(int)chatperIndex success:(void(^)(AYResultType failType)) completeBlock failure : (void(^)(NSString * errorString,AYResultType failType)) failureBlock
{
    
    if (chatperIndex < 0 || chatperIndex>self.cartoonCatelogArray.count-1) {
        return;
    }
    //看内存是否有
    if ([self.cartoonChapterDic objectForKey:@(chatperIndex)]) {
   
        [self downLoadChatperResult:chatperIndex success:completeBlock failure:nil];
        return;
    }
    //看本地是否有没有
    if (self.cartoonCatelogArray.count>0)
    {
        AYCartoonChapterModel *chapterModel  = [self.cartoonCatelogArray safe_objectAtIndex:chatperIndex];
        if (chapterModel)
        {
            AYCartoonChapterContentModel *contentModel = [self cartoonChapterModel:[chapterModel.cartoonChapterId stringValue]];
            if (contentModel)
            {
                BOOL isUpdate = ([chapterModel.cartoonUpdateTime longLongValue]>[contentModel.cartoonUpdateTime longLongValue])?YES:NO;
                if (!isUpdate)
                {
                    if (contentModel.cartoonImageUrlArray && contentModel.cartoonImageUrlArray.count>0)
                    {
                        [self loadImageInfoWith:contentModel chapterIndex:chatperIndex];
                        
                        [self.cartoonChapterDic setObject:contentModel forKey:@(chatperIndex)];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self downLoadChatperResult:chatperIndex success:completeBlock failure:nil];
                        });
                        return;
                    }
        
                }
            }
        }
    }
    
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        AYCartoonChapterModel *chapterModel  = [self.cartoonCatelogArray safe_objectAtIndex:chatperIndex];
        [params addValue:chapterModel.cartoonId forKey:@"cartoon_id"];
        [params addValue:chapterModel.cartoonChapterId forKey:@"cart_section_id"];
    }];
    //  从网络下载
    [ZWNetwork post:@"HTTP_Post_Cartoon_Chapter_Content" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
                 AYCartoonChapterContentModel *item= [AYCartoonChapterContentModel itemWithRecord:record];
                 if (item )
                 {
                     //把章节内容存到数据库
                     if (item.cartoonChapterId>0 && [item.cartoonId isValid])
                     {
                         [self saveCartoonContentToLocalWith:item];
                         
                         [self loadImageInfoWith:item chapterIndex:chatperIndex];
                         //存到内存
                         [self.cartoonChapterDic setObject:item forKey:@(chatperIndex)];
                     }
                 }
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [self downLoadChatperResult:chatperIndex success:completeBlock failure:nil];
         });
     }
     failure:^(LEServiceError type, NSError *error)
     {
         if (chatperIndex == self.currentChapterIndex)
         {
             occasionalHint([error localizedDescription]);
             
         }
         if (failureBlock)
         {
             if (chatperIndex == self.currentChapterIndex)
             {
                 if (failureBlock) {
                     failureBlock([error localizedDescription],AYCurrent);
                 }
             }
             else if (chatperIndex == self.currentChapterIndex-1)
             {
                 if (failureBlock) {
                     failureBlock([error localizedDescription],AYPre);
                 }
             }
             else if (chatperIndex == self.currentChapterIndex+1)
             {
                 if (completeBlock) {
                     failureBlock([error localizedDescription],AYNext);
                 }
             }
         }
     }];
}
#pragma mark - db -
-(void)saveCartoonReadModel
{
    self.currentChapterModel = [self objectForIndexPath:_currentChapterIndex];
    NSString *qureyStr = [NSString stringWithFormat:@"cartoonID = '%@'",self.currentChapterModel.cartoonId];
    NSArray<AYCartoonReadModel*> *readModelArray = [AYCartoonReadModel r_query:qureyStr];
    [AYCartoonReadModel r_deletes:readModelArray];//先删除
    AYCartoonChapterModel *chapterModle = [self.cartoonChapterDic objectForKey:@(self.currentChapterIndex)];
    AYCartoonReadModel *readModel = [AYCartoonReadModel new];

    readModel.currrenReadSectionId =[chapterModle.cartoonChapterId  stringValue];
    readModel.cartoonID =self.currentChapterModel.cartoonId;
    readModel.currrenReadSectionIndex =[NSString stringWithFormat:@"%ld",(long)self.currentChapterIndex];
    [readModel r_saveOrUpdate];
}
//获取本地小说的阅读状态
-(AYCartoonReadModel*)localCartoonReadModel
{
    NSString *qureyStr = [NSString stringWithFormat:@"cartoonID = '%@'",self.currentChapterModel.cartoonId];
    NSArray<AYCartoonReadModel*> *readModelArray = [AYCartoonReadModel r_query:qureyStr];
    if (readModelArray && readModelArray.count>0) //已阅读过
    {
        AYCartoonReadModel *readModel = [readModelArray objectAtIndex:0];
        if (readModel) {
            return readModel;
        }
    }
    return nil;
}
//获取本地漫画某一章节
-(AYCartoonChapterContentModel*)cartoonChapterModel:(NSString*)chapterId
{
    
    NSString * qureyStr = [NSString stringWithFormat:@"cartoonChapterId = %@",chapterId];
    NSArray<AYCartoonChapterContentModel*> *chapterModelArray = [AYCartoonChapterContentModel r_query:qureyStr];
    if (chapterModelArray && chapterModelArray.count>0)
    {
        AYCartoonChapterContentModel *chapterModel = [chapterModelArray objectAtIndex:0];
        if (chapterModel) {
            return  chapterModel;
        }
    }
    return nil;
}
//存储某一章节
-(void)saveCartoonContentToLocalWith:(AYCartoonChapterContentModel*)chapterModle
{
    if (chapterModle) {
        [chapterModle r_saveOrUpdate];
    }
    
}
@end
