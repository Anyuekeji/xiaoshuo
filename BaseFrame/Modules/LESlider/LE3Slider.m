//
//  LE3Slider.m
//  LE
//
//  Created by Leaf on 15/10/17.
//  Copyright © 2015年 Leaf. All rights reserved.
//

#import "LE3Slider.h"
#import "UIView+LEAF.h"

const int HANDLE_TOUCH_AREA_EXPANSION = -20;    //增大的触碰区域

@interface LE3Slider ()

@property (nonatomic, strong) CALayer * baseLine;
@property (nonatomic, strong) CALayer * rightLine;
@property (nonatomic, strong) CALayer * leftLine;
@property (nonatomic, strong) CALayer * handle;

@end

@implementation LE3Slider

@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize currentValue = _currentValue;
@synthesize cacheValue = _cacheValue;

@synthesize baseColour = _baseColour;
@synthesize leftColour = _leftColour;
@synthesize rightColour = _rightColour;
@synthesize handleColour = _handleColour;

@synthesize diameter = _diameter;
@synthesize barSidePadding = _barSidePadding;
@synthesize lineHeight = _lineHeight;

- (id)initWithCoder:(NSCoder *)aCoder {
    if ( self = [super initWithCoder:aCoder] ) {
        [self setUp];
    }
    return self;
}

-  (id) initWithFrame : (CGRect) aRect {
    self = [super initWithFrame:aRect];
    if ( self = [super initWithFrame:aRect] ) {
        [self setUp];
    }
    return self;
}

- (void) setUp {
    _lineHeight = 2.0f;
    _barSidePadding = 15.0f;
    _diameter = 16.0f;
    //
    self.baseLine = [CALayer layer];
    self.baseLine.backgroundColor = RGB(128.0f, 128.0f, 128.0f).CGColor;
    [self.layer addSublayer:self.baseLine];
    //
    self.rightLine = [CALayer layer];
    self.rightLine.backgroundColor = RGB(68.0f, 68.0f, 68.0f).CGColor;
    [self.layer addSublayer:self.rightLine];
    //
    self.leftLine = [CALayer layer];
    self.leftLine.backgroundColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:self.leftLine];
    //
    self.handle = [CALayer layer];
    //self.handle.borderWidth = 1.0f;
    //self.handle.borderColor = self.leftLine.backgroundColor;
    self.handle.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:self.handle];
    //self.handle.cornerRadius = self.diameter * 0.5f;
    self.handle.frame = CGRectMake(0.0f, 0.0f, self.diameter, self.diameter);
}

- (void) refresh {
    CGFloat beginX = self.baseLine.frame.origin.x;
    CGFloat width = self.baseLine.frame.size.width;
    CGFloat centerY = CGRectGetMidY(self.baseLine.frame);
    
    CGFloat handleBeginX = beginX + self.handle.frame.size.width * 0.5f;
    CGFloat handleWidth = width - self.handle.frame.size.width;
    //
    CGFloat passed = [self currentProgress];
    CGFloat cached = [self cacheProgress];
    //
    CGFloat handlePositionX = handleBeginX + passed * handleWidth;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES] ;
    self.handle.position = CGPointMake(handlePositionX, centerY);
    self.leftLine.frame = CGRectMake(beginX, self.baseLine.frame.origin.y, handlePositionX - beginX, self.baseLine.frame.size.height);
    self.rightLine.frame = CGRectMake(beginX, self.baseLine.frame.origin.y, cached * width - beginX, self.baseLine.frame.size.height);
    [CATransaction commit];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    //
    CGFloat yMiddle = CGRectGetMidY(self.bounds);
    CGFloat width = self.width - 2 * self.barSidePadding;
    self.baseLine.frame = CGRectMake(self.barSidePadding, yMiddle - self.lineHeight * 0.5f, width, self.lineHeight);
    [self refresh];
}

#pragma mark - Helper
- (CGFloat) currentProgress {
    return self.maximumValue - self.minimumValue > 0 ? (self.currentValue - self.minimumValue) / (self.maximumValue - self.minimumValue) : 0.5f;
}

- (CGFloat) cacheProgress {
    return self.maximumValue - self.minimumValue > 0 ? (self.cacheValue - self.minimumValue) / (self.maximumValue - self.minimumValue) : 0.8f;
}

#pragma mark - Touch Tracking
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint gesturePressLocation = [touches.anyObject locationInView:self];
    if (CGRectContainsPoint(CGRectInset(self.handle.frame, HANDLE_TOUCH_AREA_EXPANSION, HANDLE_TOUCH_AREA_EXPANSION), gesturePressLocation)) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [touches.anyObject locationInView:self];
    CGFloat percentage = (location.x - CGRectGetMinX(self.baseLine.frame) - self.diameter * 0.5f) / (CGRectGetMaxX(self.baseLine.frame) - CGRectGetMinX(self.baseLine.frame) - self.diameter);
    percentage = percentage < 0 ? 0.0f : percentage;
    percentage = percentage > 1 ? 1.0f : percentage;
    
    self.currentValue = percentage * (self.maximumValue - self.minimumValue) + self.minimumValue;
    if ( self.delegate && [self.delegate respondsToSelector:@selector(le3Slider:doUpdateCurrentValueTo:)] ) {
        [self.delegate le3Slider:self doUpdateCurrentValueTo:self.currentValue];
    }
    [self refresh];
}


- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint gesturePressLocation = [touch locationInView:self];
    if ( CGRectContainsPoint(CGRectInset(self.handle.frame, HANDLE_TOUCH_AREA_EXPANSION, HANDLE_TOUCH_AREA_EXPANSION), gesturePressLocation)) {
        [self animateHandle:self.handle withSelection:YES];
        return YES;
    }
    return NO;
}
- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    CGFloat percentage = (location.x - CGRectGetMinX(self.baseLine.frame) - self.diameter * 0.5f) / (CGRectGetMaxX(self.baseLine.frame) - CGRectGetMinX(self.baseLine.frame) - self.diameter);
    percentage = percentage < 0 ? 0.0f : percentage;
    percentage = percentage > 1 ? 1.0f : percentage;
    
    self.currentValue = percentage * (self.maximumValue - self.minimumValue) + self.minimumValue;
    if ( self.delegate && [self.delegate respondsToSelector:@selector(le3Slider:doUpdateCurrentValueTo:)] ) {
        [self.delegate le3Slider:self doUpdateCurrentValueTo:self.currentValue];
    }

    return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if ( self.delegate && [self.delegate respondsToSelector:@selector(le3Slider:didUpdateCurrentValueTo:)] ) {
        [self.delegate le3Slider:self didUpdateCurrentValueTo:self.currentValue];
    }
    [self animateHandle:self.handle withSelection:NO];
}

#pragma mark - Animation
- (void)animateHandle:(CALayer*)handle withSelection:(BOOL)selected {
    if (selected){
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.25f];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ];
        handle.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0f);
        [CATransaction commit];
    } else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.25f];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ];
        handle.transform = CATransform3DIdentity;
        [CATransaction commit];
    }
}

#pragma mark - Setter & Getter
- (void) setLineHeight:(NSUInteger)lineHeight {
    _lineHeight = lineHeight;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void) setDiameter:(NSUInteger)diameter {
    _diameter = diameter;
    self.handle.frame = CGRectMake(0.0f, 0.0f, _diameter, _diameter);
    self.handle.cornerRadius = _diameter * 0.5f;
}

- (void) setBarSidePadding:(NSUInteger)barSidePadding {
    _barSidePadding = barSidePadding;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void) setMinimumValue:(CGFloat)minimumValue {
    _minimumValue = minimumValue;
    if ( _maximumValue > _minimumValue ) {
        [self refresh];
    }
}

- (void) setMaximumValue:(CGFloat)maximumValue {
    _maximumValue = maximumValue;
    if ( _maximumValue > _minimumValue ) {
        [self refresh];
    }
}

- (void) setCurrentValue:(CGFloat)currentValue {
    _currentValue = currentValue;
    if ( _minimumValue <= _currentValue && _currentValue <= _maximumValue ) {
        [self refresh];
    }
}

- (void) setCacheValue:(CGFloat)cacheValue {
    _cacheValue = cacheValue;
    if ( _cacheValue >= _currentValue && _cacheValue <= _maximumValue ) {
        [self refresh];
    }
}

- (void) setBaseColour:(UIColor *)baseColour {
    self.baseLine.backgroundColor = baseColour.CGColor;
}

- (UIColor *) baseColour {
    return [UIColor colorWithCGColor:self.baseLine.backgroundColor];
}

- (void) setLeftColour:(UIColor *)leftColour {
    self.leftLine.backgroundColor = leftColour.CGColor;
    self.handle.borderColor = self.leftLine.backgroundColor;
}

- (UIColor *) leftColour {
    return [UIColor colorWithCGColor:self.leftLine.backgroundColor];
}

- (void) setRightColour:(UIColor *)rightColour {
    self.rightLine.backgroundColor = rightColour.CGColor;
}

- (UIColor *) rightColour {
    return [UIColor colorWithCGColor:self.rightLine.backgroundColor];
}

- (void) setHandleColour:(UIColor *)handleColour {
    self.handle.backgroundColor = handleColour.CGColor;
}

- (UIColor *) handleColour {
    return [UIColor colorWithCGColor:self.handle.backgroundColor];
}

@end
