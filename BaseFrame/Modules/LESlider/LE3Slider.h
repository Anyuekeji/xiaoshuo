//
//  LE3Slider.h
//  LE
//
//  Created by Leaf on 15/10/17.
//  Copyright © 2015年 Leaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol LE3SliderDelegate;
/**-----------------------------------------------------------------------------
 * @name LE3Slider
 * -----------------------------------------------------------------------------
 * 三段选择器
 */
IB_DESIGNABLE
@interface LE3Slider : UIControl

@property (nonatomic, assign) IBInspectable CGFloat minimumValue;
@property (nonatomic, assign) IBInspectable CGFloat maximumValue;  //>minimumValue
@property (nonatomic, assign) IBInspectable CGFloat currentValue;  //minimumValue<=currentValue<=maximumValue
@property (nonatomic, assign) IBInspectable CGFloat cacheValue;    //currentValue<=cacheValue<=maximumValue

@property (nonatomic, strong) IBInspectable UIColor * baseColour;
@property (nonatomic, strong) IBInspectable UIColor * leftColour;
@property (nonatomic, strong) IBInspectable UIColor * rightColour;
@property (nonatomic, strong) IBInspectable UIColor * handleColour;

@property (nonatomic, assign) IBInspectable NSUInteger diameter;
@property (nonatomic, assign) IBInspectable NSUInteger barSidePadding;
@property (nonatomic, assign) IBInspectable NSUInteger lineHeight;

@property (nonatomic, weak) id<LE3SliderDelegate> delegate;

- (CGFloat) currentProgress;

@end

@protocol LE3SliderDelegate <NSObject>

@optional
- (void) le3Slider : (LE3Slider *) slider didUpdateCurrentValueTo : (CGFloat) currentValue;
- (void) le3Slider : (LE3Slider *) slider doUpdateCurrentValueTo : (CGFloat)currentValue;

@end
