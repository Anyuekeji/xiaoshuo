//
//  AYFictionReadContentViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/19.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYFictionChapterModel;

@interface AYFictionReadContentViewController : UIViewController
/** 显示的字符串 */
@property (nonatomic, copy) NSString *content;
/** 当前页数 */
@property (nonatomic, assign) NSInteger currentPage;
/** 当前章节 */
@property (nonatomic, assign) NSInteger currentChapterIndex;
/** 总页数 */
@property (nonatomic, assign) NSInteger totalPage;
/** 字体大小*/
@property (nonatomic, assign) NSInteger font;
/** 这一页是否显示广告*/
@property (nonatomic, assign) BOOL showAd;
/** 这一章是否显示广告*/
@property (nonatomic, assign) BOOL chapterShowAd;
/**字体颜色*/
@property (nonatomic, strong) UIColor *textColor;
/**title*/
@property (nonatomic, strong) NSString *chapterTitle;
/**翻页方式*/
@property (nonatomic, assign) AYFictionReadTurnPageType turnPageType;

/**chapterModel*/
@property (nonatomic, strong) CYFictionChapterModel *chapterModel;
//重新加载数据
@property (nonatomic, copy) void (^reloadSectionContent)(void);
//充值回调
@property (nonatomic, copy) void (^chargeResultAction)(CYFictionChapterModel * chapterModel ,BOOL success);
//更新外雇
-(void)updateContentApperance;

@end

@interface AYFictionReadContentTopview : UIView
-(void)updateTopValue:(NSString*)title;
@end
@interface AYFictionReadContentBottomview : UIView
-(instancetype)initWithFrame:(CGRect)frame showAd:(BOOL)showAd;

-(void)updateBottomValue:(NSInteger)totalpage current:(NSInteger)currentPage showAd:(BOOL)showAd;
@end
NS_ASSUME_NONNULL_END
