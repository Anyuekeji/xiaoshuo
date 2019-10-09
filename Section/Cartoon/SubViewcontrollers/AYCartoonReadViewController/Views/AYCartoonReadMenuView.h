//
//  AYCartoonReadMenuView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/6.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AYCartoonModel;
@class AYCartoonChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonReadMenuView : UIView
+(void)showMenuViewInView:(UIView*)parentView cartoonModel:(AYCartoonModel*)cartoonModel currentChapterIndex:(NSInteger)currentChapterIndex menuList:(NSArray<AYCartoonChapterModel*>*)menuList chapterSelect:(void(^)(AYCartoonChapterModel * chapterModel,NSInteger chapterIndex)) chatperSelect;
-(instancetype)initWithFrame:(CGRect)frame cartoonModel:(AYCartoonModel*)cartoonModel  currentChapterIndex:(NSInteger)currentChapterIndex menuList:(NSArray<AYCartoonChapterModel*>*)menuList;

@property (nonatomic, copy) void (^cartoonMenuViewAction)(AYCartoonChapterModel * chapterModel ,NSInteger chapterIndex);
@end

NS_ASSUME_NONNULL_END
