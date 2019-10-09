//
//  AYFictionReadViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/19.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"



NS_ASSUME_NONNULL_BEGIN
@class  CYFictionChapterModel;

@protocol AYFictionReadViewModelDelegate <NSObject>

- (void)dataSourceDidFinish;

@end
@interface AYFictionReadViewModel : AYBaseViewModle
/** 当前书籍的编号 */
@property (nonatomic, copy) NSString *bookId;
;
/** 当前章节数 */
@property (nonatomic, assign) NSInteger currentChapterIndex;
/**当前读到第几页*/
@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, assign, readonly) NSInteger lastPage;
@property (nonatomic, assign) NSInteger textFont;

@property (nonatomic, weak) id<AYFictionReadViewModelDelegate>delegate;
//下载小说指定的章节 调用前先赋值bookid
@property (nonatomic, strong) NSMutableArray<CYFictionChapterModel*> *fictionCatelogArray; //小说的目录
-(void)loadFictionWithChapterIndex:(NSArray*)chatperIndexArray;
//开始阅读小说
-(void)startLoadFiction:(NSString*)starChapterIndex;
//开始加载小说某一章节
-(void)loadChatperWithIndex:(int)chatperIndex  compete: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

//保存当前阅读状态
-(void)saveFictionReadModel;
//获取当前章节model
-(CYFictionChapterModel*)getCurrentMenuChapterModel;
//获取章节model
-(CYFictionChapterModel*)getChapterModelWithChapterIndex:(NSInteger)chapterIndex;
//解锁章节返回结果
-(void)chapterChargeResult:(CYFictionChapterModel*)chargeChapterModel success:(BOOL)success;

- (void)openChapter;
- (BOOL)preChapter;
- (BOOL)nextChapter;

//是否是免费小说里需要插广告章节
- (BOOL)isAdvertiseSection:(NSInteger)chapterIndex;
//是否是免费小说里需要显示广告
- (BOOL)isNeedShowAD:(NSInteger)chapterInex;


- (void)loadNextChapter;
- (void)loadPreChater;
//更新章节信息
-(void)updateChapterInfoWithChapterIndex:(NSInteger)chaterIndex pageIndex:(NSInteger)pageIndex;

- (void)cacheContentTextWithNumbers:(NSInteger)number;
/** 根据当前页数计算并返回改变字号后的页数 */
- (NSInteger)fontChangedPageWithCurrentPage:(NSInteger)page;
/** 根据page页的字符串内容*/
- (NSString*)stringWithPage:(NSInteger)page;

- (NSString*)name;

/** 根据指定章节指定page页的字符串内容*/
- (NSString*)stringWithChapterIndex:(NSInteger)chapterIndex page:(NSInteger)page;

/** 根据指定章节的最后一页*/
- (NSInteger)lastPageWithchapterIndex:(NSInteger)chapterIndex;
/** 根据指定章节的标题*/
- (NSString*)getChapterNameWithchapterIndex:(NSInteger)chapterIndex;
@end

NS_ASSUME_NONNULL_END
