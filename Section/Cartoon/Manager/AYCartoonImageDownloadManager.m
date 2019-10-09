//
//  AYCartoonImageDownloadManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/5.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonImageDownloadManager.h"
#import "AYCartoonChapterContentModel.h"
#import "AYCartoonReadViewController.h"
#import <YYKit/YYKit.h>
#import "ZWCacheHelper.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>
#import "UIImageView+WebCache.h"

#define  INIT_LOAD_IMAGE_COUNT 20  //初始要加载的图片数

@interface AYCartoonImageDownloadManager()
{
   // dispatch_queue_t _queue;
    //dispatch_semaphore_t _semaphore;
    dispatch_block_t _downLoadBlock;
}

@property(nonatomic ,strong) NSMutableDictionary *downLoadImageArryDic;
@property(nonatomic ,strong) NSMutableArray *downLoadingChapterIndexArray;//正在加载的章节，防止重复加载

@property(nonatomic ,assign) NSInteger newestChapterIndex;//最新的章节

@property(nonatomic ,assign) NSInteger downLoadImageCount;//当前章节已下载的图片数
@property(nonatomic ,assign) NSInteger currentChapterImageCount;//当前章节图片数

@end


@implementation AYCartoonImageDownloadManager

singleton_implementation(AYCartoonImageDownloadManager)

-(instancetype)init
{
    self = [super init];
    if (self) {
//        _queue = dispatch_queue_create("com.ayimage.queue", NULL);
      //  _semaphore = dispatch_semaphore_create(3);
        SDImageCache* cache = [SDImageCache sharedImageCache];
        //  在内存中能够存储图片的最大容量 以比特为单位 这里设为1024 也就是1M
//        cache.config.maxCacheSize = 1024;
//        //  保存在存储器中像素的总和
//        cache.maxMemoryCost = 500;
        _downLoadImageArryDic = [NSMutableDictionary new];
       // _ImageInfoDic = [YYThreadSafeDictionary dictionary];
        cache.config.shouldCacheImagesInMemory = NO;
        _downLoadingChapterIndexArray = [NSMutableArray new];

    }
    return self;
}
-(void)downLoadImageWith:(NSArray<AYCartoonChapterImageUrlModel*>*) imageUrlArray index:(NSInteger)chaperIndex
{
    _downLoadImageCount =0;

    if (imageUrlArray && imageUrlArray.count>0)
    {
        AYLog(@"currentIndex is %ld",(long)_currentChapterIndex);
        if (chaperIndex == _currentChapterIndex  && _currentChapterIndex>=0)
        {
            _currentChapterImageCount = imageUrlArray.count;
            [_downLoadImageArryDic setObject:imageUrlArray forKey:@(_currentChapterIndex)];
            [self readyDownLoadImage:_currentChapterIndex];
        }
        else
        {
            self.newestChapterIndex = chaperIndex;
            if(_currentChapterIndex<0)
            {
                [_downLoadImageArryDic setObject:imageUrlArray forKey:@(chaperIndex)];
                [self readyDownLoadImage:chaperIndex];
            }
            else
            {
                   [_downLoadImageArryDic setObject:imageUrlArray forKey:@(chaperIndex)];
            }
        }
    }
}
-(NSInteger)nextDownLoadIndex:(NSInteger)currentIndex
{
    [_downLoadImageArryDic removeObjectForKey:@(currentIndex)];
    [_downLoadingChapterIndexArray removeObject:@(currentIndex)];
    if (currentIndex == self.currentChapterIndex)//先下载当前章节
    {
        self.currentChapterIndex = -10;
    }
    if (currentIndex == self.newestChapterIndex)//先下载最后加载进来的
    {
        self.newestChapterIndex = -20;
    }
    AYLog(@"章节%d加载完成",(int)currentIndex);
    NSArray *allkeys = [_downLoadImageArryDic allKeys];
    for (NSNumber *num in allkeys) {
        if ([num integerValue]== self.currentChapterIndex) {
            return [num integerValue];

        }
        else if ([num integerValue]== self.newestChapterIndex) {
            return [num integerValue];
            
        }
        if ([num integerValue]!= currentIndex) {
            return [num integerValue];
        }
    }
    return 0;
}
-(void)readyDownLoadImage:(NSInteger)downLoadIndex
{
    if ([_downLoadingChapterIndexArray containsObject:@(downLoadIndex)]) //已在加载不用再次加载
    {
        return;
    }
    [_downLoadingChapterIndexArray safe_addObject:@(downLoadIndex)];
    NSMutableArray<AYCartoonChapterImageUrlModel *> *imageUrlArray = [_downLoadImageArryDic objectForKey:@(downLoadIndex)];
    if (imageUrlArray.count>0)
    {
        if (IOS_VERSION>=8.0f)
        {
            _downLoadBlock = dispatch_block_create(0, ^{
                [self startLoadImage:downLoadIndex];
            });
           dispatch_async(dispatch_get_global_queue(0, 0), _downLoadBlock);
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self startLoadImage:downLoadIndex];
            });
        }
    }
}

-(void)startLoadImage:(NSInteger)downLoadIndex
{
    NSMutableArray<AYCartoonChapterImageUrlModel *> *imageUrlArray = [_downLoadImageArryDic objectForKey:@(downLoadIndex)];

    if (imageUrlArray && imageUrlArray>0 )
    {
        self.downLoadingChapterIndex = downLoadIndex;
        [imageUrlArray enumerateObjectsUsingBlock:^(AYCartoonChapterImageUrlModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             @autoreleasepool {
                 NSString *imageUrl = [NSString stringWithFormat:@"%@",obj.cartoonImageUrl];
                 //  RLMThreadSafeReference *objRef = [RLMThreadSafeReference referenceWithThreadConfined:obj];
                 //dispatch_async(dispatch_get_global_queue(0, 0), ^{
                 UIImage *catcheImage= [self imageInCatche:imageUrl];
                 if(catcheImage)
                 {
                     [self handleLoadFinishOneImage:downLoadIndex];

                     [self updateImageInfo:catcheImage obj:obj];
                     AYLog(@"图片在缓存中 章：%d 第%d",(int)downLoadIndex,(int)idx);
                     if (idx == imageUrlArray.count-1)
                     {
                         [self readyDownLoadImage:[self nextDownLoadIndex:downLoadIndex]];
                     }
                 }
                 else
                 {
                     //    dispatch_semaphore_wait(self->_semaphore, DISPATCH_TIME_FOREVER);
                     SDWebImageManager *manager= [SDWebImageManager sharedManager];
                     [manager loadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed  progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                         if (finished)
                         {
                             
                             [self handleLoadFinishOneImage:downLoadIndex];

                             //dispatch_semaphore_signal(self->_semaphore);
                             AYLog(@"图片下载完成 章：%d 第%d",(int)downLoadIndex,(int)idx);
                             @autoreleasepool {
                                 if (image && !error)
                                 {
                                     [self updateImageInfo:image obj:obj];
                                 }
                                 if (idx == imageUrlArray.count-1)
                                 {
                                     [self readyDownLoadImage:[self nextDownLoadIndex:downLoadIndex]];
                                 }
                             }
                         }
                         else if(error)
                         {
                             //dispatch_semaphore_signal(self->_semaphore);
                             if (idx == imageUrlArray.count-1)
                             {
                                 [self readyDownLoadImage:[self nextDownLoadIndex:downLoadIndex]];
                             }
                         }
                     }];
                 }
             }
         }];
    }
}
-(void)updateImageInfo:(UIImage*)cartoonImage obj:(AYCartoonChapterImageUrlModel*)imageModel
{
    
        if (cartoonImage)
        {
//            RLMRealm *realm = [RLMRealm defaultRealm];
//            AYCartoonChapterImageUrlModel *urlModel = [realm resolveThreadSafeReference:objRef];
//            if (!urlModel) {
//                return; // person was deleted
//            }
            //必须要在主线程 realm对象 保存和使用必须在同一个线程
            dispatch_async(dispatch_get_main_queue(), ^{
                imageModel.cartoonImageHeight =@((ScreenWidth* cartoonImage.size.height)/ cartoonImage.size.width);
                [imageModel r_saveOrUpdate];
            });
     
        }

}
-(BOOL)imageInCatche:(NSString*)imageUrl obj:(AYCartoonChapterImageUrlModel*)chaperImageModel
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString* key = [manager cacheKeyForURL:[NSURL URLWithString:imageUrl]];
    SDImageCache* cache = [SDImageCache sharedImageCache];
    //此方法会先从memory中取。
    BOOL exist = [cache diskImageDataExistsWithKey:key];
    if (exist) {
       // [self updateImageUrlModel:image obj:chaperImageModel];
        return YES;
    }
    else
    {
        NSString *yyimageUrl = [NSString stringWithFormat:@"%@",imageUrl];
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
 
        exist = [manager.cache.diskCache containsObjectForKey:[manager cacheKeyForURL:[NSURL URLWithString:yyimageUrl]]];
        if (exist)
        {
            return YES;
        }
    }
    return NO;
}
-(UIImage*)imageInCatche:(NSString*)imageUrl
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString* key = [manager cacheKeyForURL:[NSURL URLWithString:imageUrl]];
    SDImageCache* cache = [SDImageCache sharedImageCache];
    //此方法会先从memory中取。
    UIImage *image = [cache imageFromCacheForKey:key];
    if (image) {
        return image;
    }
    else
    {
        NSString *yyimageUrl = [NSString stringWithFormat:@"%@",imageUrl];
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
        UIImage *imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:[NSURL URLWithString:yyimageUrl]] withType:YYImageCacheTypeAll];//读取image缓存
        if (imageFromMemory)
        {
            return imageFromMemory;
        }
    }
    return nil;
}
#pragma mark - prive -
-(void)handleLoadFinishOneImage:(NSInteger)loadChaterIndex
{
    if (loadChaterIndex == _currentChapterIndex)
    {
        
        NSInteger macImageCount  = (_currentChapterImageCount>INIT_LOAD_IMAGE_COUNT)?INIT_LOAD_IMAGE_COUNT:_currentChapterImageCount;

        _downLoadImageCount++;
        if (_downLoadImageCount>macImageCount)
        {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat loadProgress = (self.downLoadImageCount*1.0f)/macImageCount*1.0f;
            if (self.cartoonImageLondingProgress) {
                self.cartoonImageLondingProgress(loadProgress);
            }
        });

    }
}
#pragma mark - public -
-(void)canleAllOperation
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelAll];
    YYWebImageManager *yymanager = [YYWebImageManager sharedManager];
    [yymanager.queue cancelAllOperations];
    _currentChapterIndex = -100;
    _newestChapterIndex = -30;
    _downLoadImageCount =0;
    if (_downLoadBlock) {
        dispatch_block_cancel(_downLoadBlock);//取消队列任务
        _downLoadBlock = nil;
    }
    [_downLoadImageArryDic removeAllObjects];
    [_downLoadingChapterIndexArray removeAllObjects];
}

-(void)canleChaperTaskWithIndex:(NSInteger)chapterIndex
{
    if (_downLoadImageArryDic)
    {
        id imageArray = [_downLoadImageArryDic objectForKey:@(chapterIndex)];
        if (imageArray)
        {
            [_downLoadImageArryDic removeObjectForKey:@(chapterIndex)];
        }
    }
}
-(void)changeLoadSort:(NSInteger)startLoadChapterIndex
{
    YYWebImageManager *yymanager = [YYWebImageManager sharedManager];
    [yymanager.queue cancelAllOperations];
    if (startLoadChapterIndex != _downLoadingChapterIndex)//当前不在加载这个章节
    {
        if ([_downLoadImageArryDic objectForKey:@(startLoadChapterIndex)])//这个章节的数据还没加载完，就开始变更顺序
        {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager cancelAll];
            if (IOS_VERSION>=8.0f)
            {
                if (_downLoadBlock)
                {
                   dispatch_block_cancel(_downLoadBlock);//取消队列任务
                        [_downLoadingChapterIndexArray removeAllObjects];
                }
            }
            _currentChapterIndex = startLoadChapterIndex;
            [self readyDownLoadImage:_currentChapterIndex];
        }
    }
}

@end
