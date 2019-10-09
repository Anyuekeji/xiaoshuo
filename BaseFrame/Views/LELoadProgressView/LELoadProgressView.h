//
//  LELoadProgressView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger) {
    progressBar = 0,//条形
    loopProgressBar = 1,//环形
    circularProgressBar = 2,//圆形
    tankFormProgressBar = 3,//内胆型
}ProgressBarType;

@interface LELoadProgressView : UIView

/**
 初始化progress
 
 @param frame 设置坐标及大小
 @param type 选择progress的类型
 @return 返回自己
 */
- (instancetype)initWithFrame:(CGRect)frame type:(ProgressBarType)type;

/**
 进度条背景颜色
 */
@property (nonatomic, strong) UIColor      *progressBarBGC;

/**
 下载进度条颜色
 */
@property (nonatomic, strong) UIColor      *fillColor;

/**
 边框颜色
 */
@property (nonatomic, strong) UIColor      *strokeColor;

/**
 下载进度
 */
@property (nonatomic, assign) CGFloat      loadingProgress;

@end

NS_ASSUME_NONNULL_END
