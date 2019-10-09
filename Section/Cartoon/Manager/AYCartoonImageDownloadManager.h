//
//  AYCartoonImageDownloadManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/5.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AYCartoonChapterImageUrlModel;
@class AYCartoonReadViewController;

@interface AYCartoonImageDownloadManager : NSObject

singleton_interface(AYCartoonImageDownloadManager)


//开始下载
-(void)downLoadImageWith:(NSArray<AYCartoonChapterImageUrlModel*>*) imageUrlArray index:(NSInteger)chaperIndex;

//取消下载线程
//-(void)cancleDownLoadOpearation:(NSString*)imageUrl;

//读取缓存中图片
-(UIImage*)imageInCatche:(NSString*)imageUrl;

//获取图片信息
//-(AYCartoonChapterImageUrlModel*)getImageInfoWith:(NSString*)imageUrl;
//取消所有任务
-(void)canleAllOperation;

//取消某一章的任务
-(void)canleChaperTaskWithIndex:(NSInteger)chapterIndex;

@property(nonatomic ,assign) NSInteger currentChapterIndex;//当前阅读的章节

@property(nonatomic ,assign) NSInteger downLoadingChapterIndex;//正在加载的章节
//改变加载顺序
-(void)changeLoadSort:(NSInteger)startLoadChapterIndex;

/**
 *  图片下载进度回调
 */
@property (copy, nonatomic) void(^cartoonImageLondingProgress)(CGFloat progress);
@end

NS_ASSUME_NONNULL_END
