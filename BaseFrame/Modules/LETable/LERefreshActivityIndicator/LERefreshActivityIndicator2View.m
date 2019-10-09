//
//  LERefreshActivityIndicator2View.m
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/10.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "LERefreshActivityIndicator2View.h"

@interface LERefreshActivityIndicator2View ()

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL shouldAnimate;

@property (nonatomic, assign) CGFloat offset;

@property (nonatomic, strong) UIView * leftBall;
@property (nonatomic, strong) UIView * rightBall;
@property (nonatomic, strong) UIView * leftReflectionBall;
@property (nonatomic, strong) UIView * rightReflectionBall;

@end

@implementation LERefreshActivityIndicator2View

@synthesize numbers = _numbers;
@synthesize diameter = _diameter;
@synthesize radiusFactor = _radiusFactor;
@synthesize angle = _angle;
@synthesize duration =  _duration;
@synthesize verticalOffset = _verticalOffset;

@synthesize delegate = _delegate;

@synthesize isAnimating = _isAnimating;
@synthesize shouldAnimate = _shouldAnimate;

@synthesize offset = _offset;

@synthesize leftBall = _leftBall;
@synthesize rightBall = _rightBall;
@synthesize leftReflectionBall = _leftReflectionBall;
@synthesize rightReflectionBall = _rightReflectionBall;

+ (id) activityIndicatorView {
    return [[self alloc] init];
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
    }
    return self;
}

- (void) initParams {
    _numbers = 7;
    _diameter = 10.0f;
    _radiusFactor = 1.5f;
    _angle = M_PI_4;
    _duration = 0.2f;
    _verticalOffset = 2.5f;
    [self prepared];
}

- (void) adjustFrame {
    CGRect frame = self.frame;
    _offset = sin(_angle) * ( _radiusFactor + 0.5f ) * _diameter;
    frame.size.width = _offset * 2.0f + _numbers * _diameter * 2;
    frame.size.height = fabs(cos(_angle) * ( _radiusFactor + 0.5f ) * _radiusFactor) + 3 * _diameter + _verticalOffset;
    self.frame = frame;
}

- (void) setAnchorPoint : (CGPoint) anchorPoint forView : (UIView *) view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    CGPoint position = view.layer.position;
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (UIView *) createBallWithRadius : (CGFloat) radius color : (UIColor *) color position : (CGPoint) origin {
    UIView * ball = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, radius, radius)];
    ball.backgroundColor = color;
    ball.layer.cornerRadius = radius * 0.5f;
    ball.clipsToBounds = YES;
    return ball;
}

- (UIView *) createReflectionBallWithRadius : (CGFloat) radius color : (UIColor *) color position : (CGPoint) origin {
    UIView * ball = [self createBallWithRadius:radius color:color position:origin];
    ball.transform = CGAffineTransformMakeRotation(M_PI);
    
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = ball.bounds;
    gradient.startPoint = CGPointMake(0.5f, 1.0f);
    gradient.endPoint = CGPointMake(0.5f, 0.0f);
    gradient.colors = @[(id)color.CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradient.locations = @[@(0), @(0.35), @(1)];
    
    ball.layer.mask = gradient;
    return ball;
}

- (UIColor *) randomColor {
    CGFloat red   = (arc4random() % 256)/255.0f;
    CGFloat green = (arc4random() % 256)/255.0f;
    CGFloat blue  = (arc4random() % 256)/255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void) cleanForPrepared {
    [self stopAnimating];
    _leftBall = nil;
    _rightBall = nil;
    _leftReflectionBall = nil;
    _rightReflectionBall = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void) prepared {
    [self cleanForPrepared];
    [self adjustFrame];
    
    CGFloat xPos = CGRectGetWidth(self.frame) * 0.5f - (_numbers * 0.5f) * _diameter;
    CGFloat yPos = CGRectGetHeight(self.frame) - 2.0f * _diameter - _verticalOffset;
    
    for ( NSInteger i = 0 ; i < _numbers ; i ++ ) {
        UIColor * color = nil;
        if ( _delegate && [_delegate respondsToSelector:@selector(activityIndicatorView:rectangleBackgroundColorAtIndex:)] ) {
            color = [_delegate activityIndicatorView:self rectangleBackgroundColorAtIndex:i];
        } else {
            color = [self randomColor];
        }
        
        UIView * ball = [self createBallWithRadius:_diameter color:color position:CGPointMake(xPos, yPos)];
        [self addSubview:ball];
        
        UIView * reflectionBall = [self createReflectionBallWithRadius:_diameter color:color position:CGPointMake(xPos, yPos + _verticalOffset + _diameter)];
        [self addSubview:reflectionBall];
        if ( i == 0 ) {
            _leftBall = ball;
            _leftReflectionBall = reflectionBall;
        } else if ( i == _numbers - 1 ) {
            _rightBall = ball;
            _rightReflectionBall = reflectionBall;
        }
        xPos += _diameter;
    }
}

- (void) leftBallPendulate {
    [self setAnchorPoint:CGPointMake(0.5f, -_radiusFactor) forView:_leftBall];
    [UIView animateWithDuration:_duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.leftBall.transform = CGAffineTransformMakeRotation(self.angle);
                         self.leftReflectionBall.frame = CGRectMake(self.leftReflectionBall.frame.origin.x - self.offset,
                                                                self.leftReflectionBall.frame.origin.y,
                                                                self.leftReflectionBall.frame.size.width,
                                                                self.leftReflectionBall.frame.size.height);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:self.duration
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.leftBall.transform = CGAffineTransformMakeRotation(0);
                                              self.leftReflectionBall.frame = CGRectMake(self.leftReflectionBall.frame.origin.x + self.offset, self.leftReflectionBall.frame.origin.y, self.leftReflectionBall.frame.size.width, self.leftReflectionBall.frame.size.height);
                                          } completion:^(BOOL finished) {
                                              if ( self.shouldAnimate ) {
                                                  [self rightBallPendulate];
                                              }
                                          }];
                     }];
}

- (void) rightBallPendulate {
    [self setAnchorPoint:CGPointMake(0.5f, -_radiusFactor) forView:_rightBall];
    [UIView animateWithDuration:_duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.rightBall.transform = CGAffineTransformMakeRotation(-self.angle);
                         self.rightReflectionBall.frame = CGRectMake(self.rightReflectionBall.frame.origin.x + self.offset,
                                                                 self.rightReflectionBall.frame.origin.y,
                                                                 self.rightReflectionBall.frame.size.width,
                                                                 self.rightReflectionBall.frame.size.height);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:self.duration
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.rightBall.transform = CGAffineTransformMakeRotation(0);
                                              self.rightReflectionBall.frame = CGRectMake(self.rightReflectionBall.frame.origin.x - self.offset,
                                                                                      self.rightReflectionBall.frame.origin.y,
                                                                                      self.rightReflectionBall.frame.size.width,
                                                                                      self.rightReflectionBall.frame.size.height);
                                          } completion:^(BOOL finished) {
                                              if ( self.shouldAnimate ) {
                                                  [self leftBallPendulate];
                                              }
                                          }];
                     }];
}

#pragma mark - Public Methods
- (void) startAnimating {
    if ( !_isAnimating ) {
        _isAnimating = YES;
        _shouldAnimate = YES;
        [self leftBallPendulate];
    }
}

- (void) stopAnimating {
    if ( _isAnimating ) {
        _isAnimating = NO;
        _shouldAnimate = NO;
    }
}

@end
