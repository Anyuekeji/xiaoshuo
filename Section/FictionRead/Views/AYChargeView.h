//
//  AYChargeView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYFictionChapterModel;

#define CHARGE_MASK_TAG   86546
#define AD_CHARGE_TAG   86558


@interface AYChargeView : UIView
+(void)showChargeViewInView:(UIView*)parentView fiction:(BOOL)isFiction chapterModel:(CYFictionChapterModel*) chapterModel  chargeReslut:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut;
+(void)removeChargeView;
-(instancetype)initWithFrame:(CGRect)frame  fiction:(BOOL)isFiction chapterModel:(CYFictionChapterModel*) chapterModel  chargeReslut:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut;
@end

NS_ASSUME_NONNULL_END
