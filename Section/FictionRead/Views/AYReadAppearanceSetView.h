//
//  AYReadAppearanceSetView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class  AYReadAppearanceSetView;

@protocol AYReadAppearanceSetViewDelegate<NSObject>
//屏幕亮度
-(void)screenLightChanged:(AYReadAppearanceSetView *)appearanceSetView value:(CGFloat)lightValue;
//字体大小
-(void)fontSizeChange:(AYReadAppearanceSetView *)appearanceSetView value:(CGFloat)fontSizeValue;
//背景颜色
-(void)backgroundColorChange:(AYReadAppearanceSetView *)appearanceSetView value:(UIColor*)backGroudColor;
//翻页方式
-(void)turnPageChange:(AYReadAppearanceSetView *)appearanceSetView value:(AYFictionReadTurnPageType)turnPageType;
@end

@interface AYReadAppearanceSetView : UIView
+(void)showAppearanceSetViewInView:(UIView*)parentView;
@property (nonatomic,weak) id<AYReadAppearanceSetViewDelegate> delegate;
+(void)removeAppearanceSetView;
@end

NS_ASSUME_NONNULL_END
