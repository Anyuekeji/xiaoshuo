//
//  AYReadManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYReadManager : UIViewController<UINavigationControllerDelegate,UIGestureRecognizerDelegate>
//动画打开小说
-(void)openFictionAniamationWithFromImage:(UIImage*)fromImage fromViewController:(UIViewController*)fromViewController  toViewController:(UIViewController*)toViewController beforeFrame:(CGRect)beforeFrame;
@end

NS_ASSUME_NONNULL_END
