//
//  AYShareView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYShareView : UIView
+(void)showShareViewInView:(UIView*)parentView shareParams:(NSMutableDictionary*) shareParams;
//初始化
-(instancetype)initWithFrame:(CGRect)frame shareParams:(NSMutableDictionary*) shareParams;
//参数
@property (nonatomic, strong) NSMutableDictionary* shareParas;

@property (nonatomic, weak) UIViewController* shareParentViewController;

-(void)shareToPlatforWithType:(AYSharePlatformType) platformType;
//回调
@property (nonatomic, copy) void (^ShareViewAction)(void);
@end

NS_ASSUME_NONNULL_END
