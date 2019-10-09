//
//  LEHud.h
//  LE
//
//  Created by Leaf on 15/10/16.
//  Copyright © 2015年 Leaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

extern NSString * const LEHudDidReceiveTouchEventNotification;
extern NSString * const LEHudWillDisappearNotification;
extern NSString * const LEHudDidDisappearNotification;
extern NSString * const LEHudWillAppearNotification;
extern NSString * const LEHudDidAppearNotification;

extern NSString * const LEHudStatusUserInfoKey;

enum {
    LEHudMaskTypeNone = 1,  // allow user interactions while HUD is displayed
    LEHudMaskTypeClear,     // don't allow
    LEHudMaskTypeBlack,     // don't allow and dim the UI in the back of the HUD
    LEHudMaskTypeGradient   // don't allow and dim the UI with a a-la-alert-view bg gradient
};

typedef NSUInteger LEHudMaskType;

/**-----------------------------------------------------------------------------
 * @name LEHud
 * -----------------------------------------------------------------------------
 * 自动消失的锁屏提示
 */
@interface LEHud : UIView

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
@property (readwrite, nonatomic, retain) UIColor *hudBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIColor *hudForegroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIColor *hudStatusShadowColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIColor *hudRingBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIColor *hudRingForegroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIFont *hudFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIImage *hudSuccessImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIImage *hudErrorImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIImage *hudWarningImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
#endif

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)show;
+ (void)showWithMaskType:(LEHudMaskType)maskType;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(LEHudMaskType)maskType;

+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress status:(NSString*)status;
+ (void)showProgress:(float)progress status:(NSString*)status maskType:(LEHudMaskType)maskType;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

// stops the activity indicator, shows a glyph + status, and dismisses HUD 1s later
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showWarningWithStatus:(NSString*)string;
+ (void)showImage:(UIImage*)image status:(NSString*)status; // use 28x28 white pngs

+ (void)popActivity;
+ (void)dismiss;

+ (BOOL)isVisible;

@end

