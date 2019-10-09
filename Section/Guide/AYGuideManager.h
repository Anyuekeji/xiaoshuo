//
//  AYGuideManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/28.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
//所有引导类型
typedef NS_ENUM(NSInteger, AYGuideType) {
    AYGuideTypeClassificationZone       =   0, //分类专区
    AYGuideTypeFreeZone         =   1, //免费
    AYGuideTypeRecommendFiction         =   2, //精选小说
    AYGuideTypeTask       =   3, //任务栏
    AYGuideTypeSign         =   4, //签到
    AYGuideTypeDoTask         =   5, //做任务    AYGuideTypeClassificationZone       =   0, //分类专区
    AYGuideTypeChargeGuide         =   6, //充值引导
    AYGuideTypeShare         =   7, //分享
};
//哪个界面的引导图
typedef NS_ENUM(NSInteger, AYGuideViewType)
{
    AYGuideViewTypeFiction      =   0, //小说界面
    AYGuideViewTypeTask      =   1, //任务界面
    AYGuideViewTypeFictionDetail      =   2, //小说详情界面
};


NS_ASSUME_NONNULL_BEGIN

@interface AYGuideManager : NSObject
-(void)addGuideView:(UIView*)parentView;

-(void)showGuideWithViewType:(AYGuideViewType) viewType;

+(BOOL)guideFinishWithViewType:(AYGuideViewType)viewType;
//引导图完成
@property (nonatomic, copy) void (^guideFinish)(void);

@end

NS_ASSUME_NONNULL_END
