//
//  AYMainViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LEAFViewController.h"

typedef NS_ENUM(NSInteger, AYNavigationBarViewStyle) {
    AYNavigationBarViewStyleBookrack         =   1, //书架
    AYNavigationBarViewStyleBookmail   =   2,  //书城
    AYRNavigationBarViewStyleTask      =   3, //任务
    AYRNavigationBarViewStyleMe      =   4,//我的
    
};
NS_ASSUME_NONNULL_BEGIN

@interface AYMainViewController : LEAFViewController
/**
 导航栏样式设置
 */
@property (nonatomic, assign) AYNavigationBarViewStyle navigationBarViewStyle;
@end

NS_ASSUME_NONNULL_END
