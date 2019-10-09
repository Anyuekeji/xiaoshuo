//
//  LEBatteryView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEBatteryView : UIView
@property (nonatomic,strong) UIColor *contentColor;//填充颜色 默认与lineColor颜色相同
@property (nonatomic,strong) UIColor *warningColor;//电量低于10%的填充颜色，默认与填充颜色相同
@property (nonatomic,strong) UIColor *lineColor;
-(instancetype)initWithLineColor:(UIColor *)lineColor;
- (void)runProgress:(NSInteger)progressValue;
@end

NS_ASSUME_NONNULL_END
