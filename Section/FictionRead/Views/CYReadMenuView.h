//
//  CYReadMenuView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AYFictionModel;
@class CYFictionChapterModel;

@interface CYReadMenuView : UIView
+(void)showMenuViewInView:(UIView*)parentView fictionModel:(AYFictionModel*)fictinModel currentChapterIndex:(NSInteger)currentChapterIndex menuList:(NSArray<CYFictionChapterModel*>*)menuList chapterSelect:(void(^)(CYFictionChapterModel * chapterModel,NSInteger chapterIndex)) chatperSelect;
-(instancetype)initWithFrame:(CGRect)frame fictionModel:(AYFictionModel*)fictinModel currentChapterIndex:(NSInteger)currentChapterIndex menuList:(NSArray<CYFictionChapterModel*>*)menuList;

@property (nonatomic, copy) void (^menuViewAction)(CYFictionChapterModel * chapterModel ,NSInteger chapterIndex);
@end

NS_ASSUME_NONNULL_END
