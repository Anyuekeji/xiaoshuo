//
//  AYNavigationController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYNavigationController : UINavigationController

/**
 *  配置全局导航颜色
 *
 *  @param color 色值
 */
+ (void) configurateNavigationBarColor : (UIColor *) color;

@end

NS_ASSUME_NONNULL_END
