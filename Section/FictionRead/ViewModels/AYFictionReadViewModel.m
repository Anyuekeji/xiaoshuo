//
//  AYFictionReadViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/19.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionReadViewModel.h"
#import "CYFictionChapterModel.h"
#import "AYPageUtils.h"
#import "AYFictionReadModel.h" //存储当前小说阅读状态
#import "AYFictionReadChapterModel.h" //阅读小说model
#import "LESandBoxHelp.h"
#import "LEFileManager.h"
#import "ZWCacheHelper.h"
#import "AYFictionCatlogManager.h" //目录管理
#import "AYReadStatisticsManager.h" //统计

@interface AYFictionReadViewModel ()
{
   // AYPageUtils *paging;
   // AYPageUtils *_currentPaging;

}
@property (nonatomic, assign) NSInteger totalChapter;
@property (nonatomic, assign) BOOL isReloadUI;
@property (nonatomic, assign) BOOL preSwitchFinished; //防止短时间内切换多章
@property (nonatomic, assign) BOOL nextSwitchFinished;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*,AYPageUtils*> *fictionpPageInfoDic; //小说每章的分页信息
@property (nonatomic, strong) NSMutableDictionary<NSNumber*,AYFictionReadChapterModel*> *fictionChapterDic; //小说章节信息字典
@end

@implementation AYFictionReadViewModel
- (void) setUp
{
    [super setUp];
    _fictionCatelogArray = [NSMutableArray array];
    _fictionChapterDic =[NSMutableDictionary new];
    _fictionpPageInfoDic =[NSMutableDictionary new];

    _currentChapterIndex =0;
    _currentPageIndex =0;
    
    _preSwitchFinished = YES;
    _nextSwitchFinished = YES;
}
#pragma mark 分页
- (void)configPaging
{
    [self currentPageUtils].textRenderSize = [AYUtitle getReadContentSize];
    [ [self currentPageUtils] paging];
    [self changeOtherCurrentPageing];
}

- (AYPageUtils*)configChaperPaging:(NSInteger)chaperIndex
{
    AYFictionReadChapterModel *chapterModle = [self.fictionChapterDic objectForKey:@(chaperIndex)];
    NSString *contentText =[self LoadchapterContentWithModel:chapterModle];
    if (!contentText && contentText.length<1) {
        return nil;
    }
    AYPageUtils *tempChaperModel =[_fictionpPageInfoDic objectForKey:@(chaperIndex)];
    if (!tempChaperModel){
        AYPageUtils* chaperPaging = [[AYPageUtils alloc] init];
        chaperPaging.contentText =contentText;
        chaperPaging.textRenderSize =[AYUtitle getReadContentSize];
        [chaperPaging paging];
        [_fictionpPageInfoDic setObject:chaperPaging forKey:@(chaperIndex)];
    }
    AYLog(@"fictionpPageInfoDic is %@",_fictionpPageInfoDic);
    return tempChaperModel;
}
-(void)clearPageInfoDic
{
    if (_fictionChapterDic.count<=5) {
        return;
    }
    NSMutableArray<NSNumber*> *willDeleteKeys = [NSMutableArray new];
    [_fictionpPageInfoDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, AYPageUtils * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key integerValue]<self.currentChapterIndex-2 || [key integerValue]>self.currentChapterIndex+2) {
            [willDeleteKeys safe_addObject:key];
        }
    }];
    if (willDeleteKeys.count>0) {
        [_fictionpPageInfoDic removeObjectsForKeys:willDeleteKeys];
    }
}

-(void)changeOtherCurrentPageing
{
    [_fictionpPageInfoDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, AYPageUtils * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key integerValue]!=self.currentChapterIndex){
            [obj paging];
        }
    }];
}
#pragma mark - parvate -
-(void)startLoadFictionData
{
    if (self.currentChapterIndex<=0) {
        [self loadFictionWithChapterIndex:@[@(self.currentChapterIndex),@(self.currentChapterIndex+1)]];
    }
    else
    {
        [self loadFictionWithChapterIndex:@[@(self.currentChapterIndex),@(self.currentChapterIndex+1),@(self.currentChapterIndex-1)]];
    }
}
-(CYFictionChapterModel*)getCurrentMenuChapterModel
{
    AYFictionReadChapterModel *chapterModle = [self.fictionCatelogArray safe_objectAtIndex:self.currentChapterIndex];
    return chapterModle;
}
-(CYFictionChapterModel*)getChapterModelWithChapterIndex:(NSInteger)chapterIndex
{
    CYFictionChapterModel *chapterModle = [self.fictionCatelogArray safe_objectAtIndex:chapterIndex];
    return chapterModle;
}
-(AYPageUtils*)currentPageUtils
{
    return [self.fictionpPageInfoDic objectForKey:@(self.currentChapterIndex)];
}
-(AYPageUtils*)getPageUtilsWithChapterIndex:(NSInteger)chapterIndex
{
    return [self.fictionpPageInfoDic objectForKey:@(chapterIndex)];
}
#pragma mark - db -
//获取本地小说的阅读状态
-(AYFictionReadModel*)localFictionReadModel
{
    NSString *qureyStr = [NSString stringWithFormat:@"fictionID = '%@'",self.bookId];
    NSArray<AYFictionReadModel*> *readModelArray = [AYFictionReadModel r_query:qureyStr];
    if (readModelArray && readModelArray.count>0) //已阅读过
    {
        AYFictionReadModel *readModel = [readModelArray objectAtIndex:0];
        if (readModel) {
            return readModel;
        }
    }
    return nil;
}
//退出阅读时保存当前阅读状态
-(void)saveFictionReadModel
{
    NSString *qureyStr = [NSString stringWithFormat:@"fictionID = '%@'",self.bookId];
    NSArray<AYFictionReadModel*> *readModelArray = [AYFictionReadModel r_query:qureyStr];
    [AYFictionReadModel r_deletes:readModelArray];//先删除
    AYFictionReadChapterModel *chapterModle = [self.fictionChapterDic objectForKey:@(self.currentChapterIndex)];
    AYFictionReadModel *readModel = [AYFictionReadModel new];
    readModel.currrenReadPageIndex = [NSString stringWithFormat:@"%ld",(long)self.currentPageIndex];
    readModel.currrenReadSectionId =[chapterModle.fictionSectionID stringValue];
    readModel.fictionID =chapterModle.fictionID;
    readModel.currrenReadSectionIndex =[NSString stringWithFormat:@"%ld",(long)self.currentChapterIndex];
    readModel.currrenFontsize =@([self currentPageUtils].contentFont);
    [readModel r_saveOrUpdate];
    }
//获取本地小说某一章节
-(CYFictionChapterModel*)FictionChapterModel:(NSString*)chapterId
{
    NSString * qureyStr = [NSString stringWithFormat:@"fictionSectionID = %@",chapterId];
    NSArray<CYFictionChapterModel*> *chapterModelArray = [CYFictionChapterModel r_query:qureyStr];
    if (chapterModelArray && chapterModelArray.count>0)
    {
        CYFictionChapterModel *chapterModel = [chapterModelArray objectAtIndex:0];
        if (chapterModel) {
            return  chapterModel;
        }
    }
    return nil;
}
//获取小说目录
-(void)localFictionCatalog: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [[AYFictionCatlogManager shared] fetchFictionCatlogWithFictionId:self.bookId refresh:NO success:^(NSArray<CYFictionChapterModel *> * _Nonnull fictionCatlogArray) {
        if (fictionCatlogArray) {
            [self.fictionCatelogArray removeAllObjects];
            [self.fictionCatelogArray addObjectsFromArray:fictionCatlogArray];
            self.totalChapter = self.fictionCatelogArray.count-1;
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
//本地获取章节内容
-(NSString*)LoadchapterContentWithModel:(AYFictionReadChapterModel*)chapterModle
{
    NSError *error;
    NSString *filePathString = [NSString stringWithFormat:@"%@%@",[LESandBoxHelp docPath],chapterModle.fictionSectionContent];
    NSString *chapterContent = [NSString stringWithContentsOfFile:filePathString encoding:NSUTF8StringEncoding error:&error];
    if(error)
    {
        AYLog(@"load chapter:%@ content faild:%@", [chapterModle.fictionSectionID stringValue],[error localizedDescription]);
    }
    return chapterContent;
}
//存储某一章节
-(void)saveFictionContentToLocalWith:(AYFictionReadChapterModel*)chapterModle
{
    NSString *bookDirPath = [[LESandBoxHelp docPath] stringByAppendingPathComponent:@"AYNovel"]; //创建aynove父文件夹
    if (![LEFileManager isDirectoryExistsAtPath:bookDirPath])
    {
        //没有创建文件夹
        if (![LEFileManager createFileAtDirectoryPath:bookDirPath fileName:nil]) {
        }
        else
        {
            AYLog(@"create AYNovel diretory fiald");
        }
    }
    NSString *fictionDirPath = [bookDirPath stringByAppendingPathComponent:self.bookId];//创建小说章节文件夹
    if ([LEFileManager isDirectoryExistsAtPath:bookDirPath]) {
        if (![LEFileManager isDirectoryExistsAtPath:fictionDirPath])
        {
            //没有创建文件夹
            if (![LEFileManager createFileAtDirectoryPath:fictionDirPath fileName:nil]) {
            }
            else
            {
                AYLog(@"create fictionDirPath:%@ diretory fiald",[chapterModle.fictionSectionID stringValue]);
            }
        }
    }
    if ([LEFileManager isDirectoryExistsAtPath:fictionDirPath]) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%@.txt",[chapterModle.fictionSectionID stringValue],chapterModle.fictionSectionTitle];
        if (![LEFileManager createFileAtDirectoryPath:fictionDirPath fileName:fileName]) {
            AYLog(@"存储小说：%@ 章节：%@失败",self.bookId,chapterModle.fictionSectionTitle);
        }
        else
        {
            NSString *filePath = [fictionDirPath stringByAppendingPathComponent:fileName];
            if ([LEFileManager createFileAtPath:filePath data:[chapterModle.fictionSectionContent dataUsingEncoding:NSUTF8StringEncoding]])
            {
                chapterModle.fictionSectionContent = [filePath replacingString:[LESandBoxHelp docPath] with:@""];
                AYLog(@"保存的章节：%@路径：%@",[chapterModle.fictionSectionID stringValue],filePath);
            }
            else
            {
                AYLog(@"写入章节%@内容到%@失败",chapterModle.fictionSectionTitle,filePath);
            }
        }
    }
}
//本地某一章节的数据
-(AYFictionReadChapterModel*)localFictionChaperReadModel:(NSString*)fictionChaperId
{
    NSString * qureyStr = [NSString stringWithFormat:@"fictionSectionID = %@",fictionChaperId];
    NSArray<AYFictionReadChapterModel*>  *readChapterModelArray = [AYFictionReadChapterModel r_query:qureyStr ];
    if (readChapterModelArray && readChapterModelArray.count>0)
    {
        return readChapterModelArray[0];
    }
    return nil;
}
#pragma mark - network -
//开始加载小说逻辑
-(void)startLoadFiction:(NSString*)starChapterIndex
{
    if (starChapterIndex) {//用户指定跳转某一章节
        self.currentChapterIndex = [starChapterIndex integerValue];
        self.currentPageIndex =0;
    }
    else//读取本地阅读状态数据
    {
        AYFictionReadModel *readModle = [self localFictionReadModel];
        if (readModle) {
            if([readModle.currrenFontsize integerValue]>2)
            {
                //设置当前的字体大小
                [[NSUserDefaults standardUserDefaults] setObject:readModle.currrenFontsize forKey:kUserDefaultReadFontSize];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if(readModle.currrenReadSectionIndex)
            {
                //加载章节内容需要提前渲染  第一章时加载前两章节 其他加载前后当前三章
                NSInteger currentSectionIndex = [readModle.currrenReadSectionIndex integerValue];
                self.currentChapterIndex = currentSectionIndex;
                self.currentPageIndex =[readModle.currrenReadPageIndex integerValue];
            }
        }
    }
    if (self.fictionCatelogArray.count<=0) {
        [self localFictionCatalog:^{
            [self startLoadFictionData];
        } failure:^(NSString *errorString) {
            occasionalHint(errorString);
        }];

    }
    else
    {
        [self startLoadFictionData];
    }
}
-(void)loadFictionWithChapterIndex:(NSArray*)chatperIndexArray
{
    [chatperIndexArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self loadChatperWithIndex:[obj intValue] compete:nil failure:nil];
    }];
}
-(void)loadChatperWithIndex:(int)chatperIndex  compete: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if (chatperIndex<0 || chatperIndex>self.fictionCatelogArray.count-1) {
        return;
    }
    //看内存是否有
    if ([self.fictionChapterDic objectForKey:@(chatperIndex)])
    {
       if ([self configChaperPaging:chatperIndex])
       {
           if (chatperIndex == self.currentChapterIndex) {
               if ([self.delegate respondsToSelector:@selector(dataSourceDidFinish)]) {
                   [self.delegate dataSourceDidFinish];
               }
               
           }
           if (completeBlock) {
               completeBlock();
           }
           return;
       }

    }
    //看本地是否有没有
    if (self.fictionCatelogArray.count>0)
    {
        CYFictionChapterModel *chapterModel  = [self.fictionCatelogArray safe_objectAtIndex:chatperIndex];
        if (chapterModel)
        {
            AYFictionReadChapterModel *readChapterModel = [self localFictionChaperReadModel:[chapterModel.fictionSectionID stringValue]];
            if (readChapterModel)//有更新去读缓存
            {
                BOOL isUpdate = ([chapterModel.fictionUpdateTime longLongValue]>[readChapterModel.fictionUpdateTime longLongValue])?YES:NO;
                if (!isUpdate)//有更新从网络下载
                {
                    [self.fictionChapterDic setObject:readChapterModel forKey:@(chatperIndex)];
                    
                    if ([self configChaperPaging:chatperIndex]) {
                        
                        if (chatperIndex == self.currentChapterIndex) {
                            if ([self.delegate respondsToSelector:@selector(dataSourceDidFinish)]) {
                                [self.delegate dataSourceDidFinish];
                            }
                        }
                        if (completeBlock) {
                            completeBlock();
                        }
                        return;
                    }
                }
 
            }
        }
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        CYFictionChapterModel *chapterModel  = [self.fictionCatelogArray safe_objectAtIndex:chatperIndex];
        [params addValue:chapterModel.fictionID forKey:@"book_id"];
        [params addValue:chapterModel.fictionSectionID forKey:@"section_id"];
    }];
    //  从网络下载
    [ZWNetwork post:@"HTTP_Post_Fiction_SectionContent" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             AYFictionReadChapterModel *item= [AYFictionReadChapterModel itemWithDictionary:record];
             if (item)
             {
                 [item decodeFictionContent];
                 //把章节内容存到本地文件夹，item保存文件路径
                 [self saveFictionContentToLocalWith:item];
                 //存储到本地
                 [item r_saveOrUpdate];
                 //存到内存
                 [self.fictionChapterDic setObject:item forKey:@(chatperIndex)];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self configChaperPaging:chatperIndex];
                     if (chatperIndex == self.currentChapterIndex) {
                         if ([self.delegate respondsToSelector:@selector(dataSourceDidFinish)]) {
                             [self.delegate dataSourceDidFinish];
                         }
                     }
                 });
     
             }
         }
         if (completeBlock) {
             completeBlock();
         }
     } failure:^(LEServiceError type, NSError *error) {
         AYLog(@"load chaper %d faild:%@",chatperIndex,[error localizedDescription]);
             if (chatperIndex == self.currentChapterIndex)
             {
                 occasionalHint([error localizedDescription]);
             }
     }];
}
#pragma mark 公共方法
- (BOOL)preChapter
{
    if (self.currentChapterIndex <= 0) {
        AYLog(@"已经是第一章了！！！！");
        self.currentChapterIndex =0;
        return NO;
    }
    else
    {
        if([self isNeedShowAD:self.currentChapterIndex])
        {
            [[AYReadStatisticsManager shared] userReadFinishOneChapter:self.bookId chapterId:[[self getCurrentMenuChapterModel].fictionSectionID stringValue]];
        }
      //  self.currentChapterIndex--;
        AYLog(@"上一章为：%ld",self.currentChapterIndex-1);
        [self loadPreChater];
       // [self configPaging];

        return YES;
    }
}
- (BOOL)nextChapter
{
     if (self.currentChapterIndex >= self.totalChapter) {
        self.currentChapterIndex =self.totalChapter;
        AYLog(@"已经是最后一章了!!!!!");
        occasionalHint(AYLocalizedString(@"已是最后一章了"));
        return NO;
    }
    else
    {
        
        //已经显示广告的才记录
        if([self isNeedShowAD:self.currentChapterIndex])
        {
            [[AYReadStatisticsManager shared] userReadFinishOneChapter:self.bookId chapterId:[[self getCurrentMenuChapterModel].fictionSectionID stringValue]];
        }
        
        AYLog(@"下一章为：%ld",(long)self.currentChapterIndex+1);
        [self loadNextChapter];
      
        return YES;
    }
}

- (void)loadNextChapter
{
    //提前加载两章节
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ((self.currentChapterIndex+2)<=self.totalChapter) {
            [self loadChatperWithIndex:(int)self.currentChapterIndex+2 compete:^{
                //只保留三个对象，因为对象占内存大
                [self clearPageInfoDic];
            } failure:nil];
        }
//        if ((self.currentChapterIndex+3)<=self.totalChapter) {
//            [self loadChatperWithIndex:(int)self.currentChapterIndex+3 compete:^{
//                //只保留三个对象，因为对象占内存大
//                [self clearPageInfoDic];
//            }];
//        }
    });
}
- (void)loadPreChater
{
    //提前加载两章节
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ((self.currentChapterIndex-2)>=0) {
            [self loadChatperWithIndex:(int)self.currentChapterIndex-2 compete:^{
                //只保留三个对象，因为对象占内存大
                [self clearPageInfoDic];
            } failure:^(NSString * _Nonnull errorString) {
                
            }];
        }
//        if ((self.currentChapterIndex-3)>=0) {
//            [self loadChatperWithIndex:(int)self.currentChapterIndex-3 compete:^{
//                //只保留三个对象，因为对象占内存大
//                [self clearPageInfoDic];
//            }];
//        }
    });
}
-(void)updateChapterInfoWithChapterIndex:(NSInteger)chaterIndex pageIndex:(NSInteger)pageIndex
{
    self.currentChapterIndex = chaterIndex;
    self.currentPageIndex = pageIndex;
}
-(NSString*)name {
    return ((CYFictionChapterModel*)[_fictionChapterDic objectForKey:@(self.currentChapterIndex)]).fictionSectionTitle;
}
- (NSInteger)fontChangedPageWithCurrentPage:(NSInteger)page {
    NSInteger location = [[self currentPageUtils] locationWithPage:page];
    [self configPaging];
    
    return [ [self currentPageUtils] pageWithTextOffSet:location];
}
- (NSString *)stringWithPage:(NSInteger)page
{
    return [ [self currentPageUtils] stringOfPage:page];
}
- (NSInteger)lastPage {
    
    CYFictionChapterModel *chapterModel  =[self getCurrentMenuChapterModel];
    if (chapterModel) {
        if ([chapterModel.needMoney integerValue]>0 && ![chapterModel.unlock boolValue] && ![self isNeedShowAD:self.currentChapterIndex]) {//要收费，且没解锁过 只显示一页
            return 0;
        }
    }
    return [ [self currentPageUtils] pageCount];
}
//解锁章节返回结果
-(void)chapterChargeResult:(CYFictionChapterModel*)chargeChapterModel success:(BOOL)success
{
    if (success) {
         chargeChapterModel.unlock = [NSNumber numberWithBool:YES];
        [chargeChapterModel r_saveOrUpdate];
    }
}
- (NSString*)stringWithChapterIndex:(NSInteger)chapterIndex page:(NSInteger)page
{
    //self.currentPageIndex= page;
    return [ [self getPageUtilsWithChapterIndex:chapterIndex] stringOfPage:page];
}

- (NSInteger)lastPageWithchapterIndex:(NSInteger)chapterIndex
{
    CYFictionChapterModel *chapterModel  =[self getChapterModelWithChapterIndex:chapterIndex];
    if (chapterModel) {
        if ([chapterModel.needMoney integerValue]>0 && ![chapterModel.unlock boolValue] && ![self isNeedShowAD:chapterIndex]) {//要收费，且没解锁过 只显示一页
            return 0;
        }
    }
    return [ [self getPageUtilsWithChapterIndex:chapterIndex] pageCount];
}
- (NSString*)getChapterNameWithchapterIndex:(NSInteger)chapterIndex
{
    return ((CYFictionChapterModel*)[_fictionChapterDic objectForKey:@(chapterIndex)]).fictionSectionTitle;
}

- (BOOL)isAdvertiseSection:(NSInteger)chapterIndex
{
    CYFictionChapterModel *chapterModel = [self getChapterModelWithChapterIndex:chapterIndex];
    if([chapterModel.needMoney integerValue] ==4 && ![chapterModel.unlock boolValue])
    {
        return YES;
    }
    return NO;
}
//判断是否需要显示广告
- (BOOL)isNeedShowAD:(NSInteger)chapterInex
{
    if([self isAdvertiseSection:chapterInex])
    {
        BOOL isAdvertiseCoinUnlock = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFreeBookCoinUnlock];//是否设置成广告解锁
        if (!isAdvertiseCoinUnlock && ![[AYReadStatisticsManager shared] advertiseReadDayCountFinished])
        {
            return YES;
        }
    }
    return NO;
}

@end
