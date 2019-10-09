//
//  AYReadTopView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class  AYReadTopView;
@protocol AYReadTopViewDelegate<NSObject>
//返回
-(void)backInReadTopView:(AYReadTopView *)topView;
//分享
-(void)shareInReadTopView:(AYReadTopView *)topView;
//在广告模式下切换解锁模式
-(void)switchUnlockModeInAdverttiseModeIReadTopView:(AYReadTopView *)topView unlockMode:(BOOL)unlockAdvertise;
@end


@interface AYReadTopView : UIView

@property (nonatomic,weak) id<AYReadTopViewDelegate> delegate;

@property(nonatomic,copy) NSString *title;

//切换成广告或者正常模式
-(void)changeToAdvertiseMode:(BOOL)advertiseMode;

//广告模式下切换成金币解锁或者广告解锁
-(void)changeCoinModeInAdverse:(BOOL)coin;
@end

NS_ASSUME_NONNULL_END
