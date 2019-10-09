//
//  AYCartoonPageViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

NS_ASSUME_NONNULL_BEGIN


@class AYCartoonChapterModel;

@class CYFictionChapterModel;

@interface AYCartoonPageViewModel : AYBaseViewModle
///**
// *  数据组
// */
//- (NSInteger) numberOfSections;
///**
// *  数据行
// */
//- (NSInteger) numberOfRowsInSection:(NSInteger)section;
/**
 *  获取对象
 */

@property (nonatomic, strong) NSMutableArray<AYCartoonChapterModel*> *cartoonCatelogArray; //漫画的目录

- (id) objectForIndexPath : (NSInteger ) index;

//是否通过看视频广告解锁
- (BOOL)isNeedShowAD;
//是否广告section
- (BOOL)isAdvertiseSection;
/**
 *  下一章
 */
-(void)nextChapter:(void(^)(AYResultType resultType)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
/**
 *  上一章
 */
-(void)preChapter:(void(^)(AYResultType resultType)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;

/**
 *  加载某一章
 */
-(void)loadChatperWithIndex:(int)chatperIndex success:(void(^)(AYResultType failType)) completeBlock failure : (void(^)(NSString * errorString,AYResultType failType)) failureBlock;
/**
 *  加载某一章
 */
-(void)loadChatperWithIndex:(int)chatperIndex success:(void(^)(AYResultType failType)) completeBlock failure : (void(^)(NSString * errorString,AYResultType failType)) failureBlock;
/**
 *  当前漫画章节
 */
@property(nonatomic,assign)NSInteger currentChapterIndex;
/**
 *  图片下载进度回调
 */
@property (copy, nonatomic) void(^cartoonImageLodingProgress)(CGFloat progress);

/**
 *  当前漫画model
 */
@property(nonatomic,assign)AYCartoonChapterModel* currentChapterModel;
//保存当前阅读状态
-(void)saveCartoonReadModel;

//获取当前章节目录model
-(AYCartoonChapterModel*)getCurrentMenuChapterModel;


//解锁章节返回结果
-(void)chapterChargeResult:(CYFictionChapterModel*)chargeChapterModel success:(BOOL)success;

/**
 *  获取漫画数据
 */
- (void) getCartoonChapterDataByIndex:(NSArray*)chatperIndexArray  success:(void(^)(AYResultType resultType)) completeBlock failure : (void(^)(NSString * errorString,AYResultType failType)) failureBlock;

//开始阅读 startChapterIndex==-1时 从缓存读 不为-1时 按照指定的章节读
-(void)startLoadCartoon:(NSInteger) startChapterIndex success:(void(^)(AYResultType resultType)) completeBlock failure : (void(^)(NSString * errorString,AYResultType failType)) failureBlock;
@end

NS_ASSUME_NONNULL_END
