//
//  AYBaseViewModle.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYBaseViewModle : NSObject
@property (nonatomic, readonly, weak) UIViewController * linkViewController;

/*
 * 生成实例对象
 */
+ (id) viewModel;

/**
 *  绑定控制器
 *
 *  @param viewController 控制器
 *
 *  @return 实例
 */
+ (id) viewModelWithViewController : (UIViewController *) viewController;

/*
 * 子类在本方法做初始化动作
 */
- (void) setUp;
@end

NS_ASSUME_NONNULL_END
