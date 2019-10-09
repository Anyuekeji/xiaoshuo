//
//  AYCartoonReadViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"

@class AYCartoonChapterContentModel;

@class AYCartoonChapterModel;

@class CYFictionChapterModel;

NS_ASSUME_NONNULL_BEGIN

@protocol AYCartoonReadViewControllerDelegate<NSObject>
//返回
-(void)cartoonReadScrollViewDidScroll:(UIScrollView *)scrollView;
//下一章
-(void)nextChapterInReadViewController;
//上一章
-(void)preChapterInReadViewController;
@end

@interface AYCartoonReadViewController : LETableViewController
-(instancetype)initWithChapterModel:(AYCartoonChapterContentModel*)chapterModel;
//重新加载
-(void)reloadRows:(NSIndexPath*)indexPath;

-(void)showUnlockTypeView:(BOOL)advetise;

@property (nonatomic,weak) id<AYCartoonReadViewControllerDelegate> cartoondDelegate;

@property(nonatomic,strong) AYCartoonChapterContentModel *cartoonDetailModel; //章节数据
@property(nonatomic,strong) AYCartoonChapterModel *cartoonChapterModel; //章节数据
@property(nonatomic,assign) BOOL isPre; //是否从上一章切换过来
@property(nonatomic,assign) BOOL showAd; //是否可以显示广告

@property (nonatomic, copy) void (^chargeResultAction)(CYFictionChapterModel * chapterModel ,BOOL success);
@end

NS_ASSUME_NONNULL_END
