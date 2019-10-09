//
//  LERefreshActivityIndicatorView.m
//  xiaoyuanplus
//
//  Created by 刘云鹏 on 14/12/10.
//  Copyright (c) 2014年 刘云鹏. All rights reserved.
//

#import "LERefreshActivityIndicatorView.h"

@interface LERefreshActivityIndicatorView ()

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL needRestartAnimating;

@end

@implementation LERefreshActivityIndicatorView

@synthesize numbers = _numbers;
@synthesize internalSpacing = _internalSpacing;
@synthesize size = _size;
@synthesize duration = _duration;
@synthesize delay = _delay;

@synthesize delegate = _delegate;

@synthesize isAnimating = _isAnimating;

+ (id) activityIndicatorView {
    return [[self alloc] init];
}

- (void) dealloc {
    [self removeNotifications];
}

#pragma mark - Initializations
- (instancetype) initWithFrame : (CGRect) frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self initParams];
    }
    return self;
}

- (instancetype) initWithCoder : (NSCoder *) aDecoder {
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self initParams];
    }
    return self;
}

- (instancetype) init {
    self = [super init];
    if ( self ) {
        [self initParams];
        [self setUpNotifications];
    }
    return self;
}

- (void) initParams {
    _numbers = 5;
    _internalSpacing = 3.0f;
    _size = CGSizeMake(5.0f, 8.5f);
    _duration = 1.0f;
    _delay = 0.1f;
    [self adjustFrame];
}

#pragma mark - Notifications
- (void) setUpNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) didEnterBackgroundNotification {
    if ( self.isAnimating ) {
        [self stopAnimating];
        self.needRestartAnimating = YES;
    }
}

- (void) willEnterForegroundNotification {
    if ( self.needRestartAnimating ) {
        self.needRestartAnimating = NO;
        [self startAnimating];
    }
}

#pragma mark - Functions
- (UIView *) createRectangleWithSize : (CGSize) size color : (UIColor *) color positionX : (CGFloat) x {
    UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(x, 0, self.size.width, self.size.height)];
    rectangle.backgroundColor = color;
    return rectangle;
}

- (CAKeyframeAnimation *) createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.repeatCount = INFINITY;
    anim.beginTime = CACurrentMediaTime() + delay;
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f],[NSNumber numberWithFloat:2.5f],[NSNumber numberWithFloat:1.0f],[NSNumber numberWithFloat:1.0f], nil];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}

- (CAAnimation *) addAnimateWithDuration : (CGFloat) duration delay : (CGFloat) delay {
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = YES;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:M_PI];
    animation.duration = duration;
    animation.beginTime = delay;
    
    return animation;
}

- (UIColor *) randomColor {
    CGFloat red   = (arc4random() % 256)/255.0f;
    CGFloat green = (arc4random() % 256)/255.0f;
    CGFloat blue  = (arc4random() % 256)/255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void) addRectangles {
    for (NSInteger i = 0; i < _numbers; i++) {
        UIColor *color = nil;
        if ( _delegate && [_delegate respondsToSelector:@selector(activityIndicatorView:rectangleBackgroundColorAtIndex:)] ) {
            color = [_delegate activityIndicatorView:self rectangleBackgroundColorAtIndex:i];
        } else {
            color = [self randomColor];
        }
        UIView *rectangle = [self createRectangleWithSize:_size color:color positionX:i * (_size.width + _internalSpacing)];
//        [rectangle.layer addAnimation:[self createAnimationWithDuration:_duration delay:_delay * i] forKey:@"rectangle"];
        [rectangle.layer addAnimation:[self addAnimateWithDuration:_duration delay:_delay * i] forKey:@"rectangle"];
        [self addSubview:rectangle];
    }
}

- (void) removeRectangles {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}

- (void) adjustFrame {
    CGRect frame = self.frame;
    frame.size.width = (_numbers * (_size.width + _internalSpacing)) - _internalSpacing;
    frame.size.height = _size.height;
    self.frame = frame;
}

#pragma mark - Public Methods
- (void) startAnimating {
    if ( !_isAnimating ) {
        [self addRectangles];
        _isAnimating = YES;
        self.hidden = NO;
    }
}

- (void) stopAnimating {
    if ( _isAnimating ) {
        [self removeRectangles];
        _isAnimating = NO;
        self.hidden = YES;
    }
}

- (void) setNumbers : (NSInteger) numbers {
    _numbers = numbers;
    [self adjustFrame];
}

- (void) setSize : (CGSize) size {
    _size = size;
    [self adjustFrame];
}

- (void) setInternalSpacing : (CGFloat) internalSpacing {
    _internalSpacing = internalSpacing;
    [self adjustFrame];
}

@end

