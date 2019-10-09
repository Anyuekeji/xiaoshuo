//
//  AYShareManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYShareManager.h"
#import "AYFictionModel.h"
#import "AYCartoonModel.h"
#import "AYCartoonChapterModel.h"
#import "AYShareView.h"
#import "ZWDeviceSupport.h"
#import "AYBookModel.h"

@implementation AYShareManager

static  bool  shareFinished = YES;
//分享小说
+(void)ShareFictionWith:(AYFictionModel*)fictionModel parentView:(UIView*)parentView
{
    if (!shareFinished) {//防止短时间内弹出多个
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shareFinished = YES;
    });
    shareFinished = NO;
    
//    if ([parentView viewWithTag:SHAREVIEW_TAG]) { //没有才显示
//        return;
//    }
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams setObject:fictionModel.fictionTitle?fictionModel.fictionTitle:@"" forKey:@"title"];
    [shareParams setObject:fictionModel.fictionImageUrl?fictionModel.fictionImageUrl:@"" forKey:@"image"];
    [shareParams setObject:fictionModel.fictionID forKey:@"bookId"];

    //[shareParams setObject:@"swewfewf   " forKey:@"desc"];
    [shareParams setObject:fictionModel.fictionIntroduce?fictionModel.fictionIntroduce:@"" forKey:@"desc"];
    NSString *shareUrl = [NSString stringWithFormat:@"%@home/share/index?bid=%@&uid=%@&deviceToken=%@",[AYUtitle getServerUrl],fictionModel.fictionID,([AYUserManager isUserLogin]?[AYUserManager userId]:@""),[AYUtitle getDeviceUniqueId]];
    [shareParams setObject:shareUrl forKey:@"link"];
    [AYShareView showShareViewInView:parentView shareParams:shareParams];
}

//分享漫画
+(void)ShareCartoonWith:(AYCartoonModel*)cartoonModel parentView:(UIView*)parentView
{
    if (!shareFinished) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shareFinished = YES;
    });
    shareFinished = NO;
//    if ([parentView viewWithTag:SHAREVIEW_TAG]) {
//        return;
//    }
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams setObject:cartoonModel.cartoonTitle?cartoonModel.cartoonTitle:@"" forKey:@"title"];
    [shareParams setObject:cartoonModel.cartoonImageUrl?cartoonModel.cartoonImageUrl:@"" forKey:@"image"];
  [shareParams setObject:cartoonModel.cartoonID forKey:@"bookId"];
    [shareParams setObject:cartoonModel.cartoonIntroduce ?cartoonModel.cartoonIntroduce:@"" forKey:@"desc"];
    NSString *shareUrl = [NSString stringWithFormat:@"%@home/shares/index?cid=%@&uid=%@&deviceToken=%@",[AYUtitle getServerUrl],(cartoonModel.cartoonID?cartoonModel.cartoonID:@""),([AYUserManager isUserLogin]?[AYUserManager userId]:@""),[AYUtitle getDeviceUniqueId]];
    [shareParams setObject:shareUrl forKey:@"link"];
    [AYShareView showShareViewInView:parentView shareParams:shareParams];
}
//分享书
+(void)ShareBookWith:(AYBookModel*)bookModel parentView:(UIView*)parentView
{
    if (!shareFinished) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shareFinished = YES;
    });
    shareFinished = NO;
    //    if ([parentView viewWithTag:SHAREVIEW_TAG]) {
    //        return;
    //    }
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams setObject:bookModel.bookTitle?bookModel.bookTitle:@"" forKey:@"title"];
    [shareParams setObject:bookModel.bookImageUrl?bookModel.bookImageUrl:@"" forKey:@"image"];
    [shareParams setObject:bookModel.bookID forKey:@"bookId"];
    [shareParams setObject:bookModel.bookIntroduce ?bookModel.bookIntroduce:@"" forKey:@"desc"];
    NSString *shareUrl = [NSString stringWithFormat:@"%@home/shares/index?cid=%@&uid=%@&deviceToken=%@",[AYUtitle getServerUrl],(bookModel.bookID?bookModel.bookID:@""),([AYUserManager isUserLogin]?[AYUserManager userId]:@""),[AYUtitle getDeviceUniqueId]];
    [shareParams setObject:shareUrl forKey:@"link"];
    [AYShareView showShareViewInView:parentView shareParams:shareParams];
}
//分享漫画某一章节
+(void)ShareCartoonChapterWith:(AYCartoonChapterModel*)cartoonChapterModel parentView:(UIView*)parentView
{
    
}
@end
