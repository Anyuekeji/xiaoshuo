//
//  AYReadBottomView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class  AYReadBottomView;

@protocol AYReadBottomViewDelegate<NSObject>
//菜单
-(void)menuInReadBottomView:(AYReadBottomView *)bottomView;
//日夜间切换
-(void)dayNightSwitchInReadBottompView:(AYReadBottomView *)bottomView  day:(BOOL)day;
//font设置
-(void)fontSetInReadBottomView:(AYReadBottomView *)bottomView;
//评论
-(void)commentInReadBottomView:(AYReadBottomView *)bottomView;
@end

@interface AYReadBottomView : UIView
@property (nonatomic,weak) id<AYReadBottomViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
