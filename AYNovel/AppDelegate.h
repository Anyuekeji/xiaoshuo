//
//  AppDelegate.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//切换到登录或者主界面状态
-(void)changeToLoginOrMainViewController:(BOOL)login;

//更新用户的金币
-(void)updateUserCoin: (void(^)(void)) completeBlock;
@end

