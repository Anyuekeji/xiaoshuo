//
//  AYShareManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AYFictionModel;
@class AYCartoonModel;
@class AYCartoonChapterModel;
@class AYBookModel;
NS_ASSUME_NONNULL_BEGIN


@interface AYShareManager : NSObject
//分享小说
+(void)ShareFictionWith:(AYFictionModel*)fictionModel parentView:(UIView*)parentView;

//分享漫画
+(void)ShareCartoonWith:(AYCartoonModel*)cartoonModel parentView:(UIView*)parentView;

//分享书架
+(void)ShareBookWith:(AYBookModel*)bookModel parentView:(UIView*)parentView;
//分享漫画某一章节
+(void)ShareCartoonChapterWith:(AYCartoonChapterModel*)cartoonChapterModel parentView:(UIView*)parentView;

//邀请
+(void)ShareInviteInfoWith:(UIView*)parentView;


@end

NS_ASSUME_NONNULL_END
