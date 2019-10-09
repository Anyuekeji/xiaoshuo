//
//  ZWTopRefreshControl.m
//  qscode
//
//  Created by allen on 17/7/31.
//  Copyright © 2017年 2.0.2. All rights reserved.
#import "ZWTopRefreshControl.h"

#import "UIView+LEAF.h"
#import "LEUtil.h"

@interface ZWTopRefreshControl ()

@property (nonatomic, strong) UILabel * topLabel;
@property (nonatomic, strong) UILabel * bottomLabel;
@property (nonatomic, strong) UIImageView * animateImageView;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, strong) NSDate * latestRefreshTime;

@end

@implementation ZWTopRefreshControl

- (void) initParams {
    [super initParams];
    //
    [self setUpLabel];
    [self setUpAnimateImageView];
}

- (void) setUpLabel {
    _topLabel = [[UILabel alloc] init];
    self.topLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    self.topLabel.textColor = UIColorFromRGB(0x666666);
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    
    _bottomLabel = [[UILabel alloc] init];
    self.bottomLabel.font = [UIFont systemFontOfSize:11.0f];
    self.bottomLabel.textColor = UIColorFromRGB(0x848484);
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    
    if ( self.isAutoLayout ) {
        self.topLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.topLabel];
        
        self.bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.bottomLabel];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTopMargin multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottomMargin multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:2.0f]];
    } else {
        [self.contentView addSubview:self.topLabel];
        [self.contentView addSubview:self.bottomLabel];
        //
        self.topLabel.frame = CGRectMake(0.0f, 0.0f, self.contentView.width, self.contentView.height * 0.5f);
        self.topLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.bottomLabel.frame = CGRectMake(0.0f, self.contentView.height * 0.5f, self.contentView.width, self.contentView.height*0.5f);
        self.bottomLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}

- (void) setUpAnimateImageView {
    UIImage * arrowImage = [UIImage imageNamed:@"icon_drag_refresh"];
    _animateImageView = [[UIImageView alloc] initWithImage:arrowImage];
    if ( self.isAutoLayout ) {
        _animateImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.animateImageView];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.animateImageView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterXWithinMargins
                                     multiplier:0.5f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_animateImageView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_animateImageView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0f constant:arrowImage.size.width]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_animateImageView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0f constant:arrowImage.size.height]];
    } else {
        [self.contentView addSubview:_animateImageView];
        _animateImageView.frame = CGRectMake(self.contentView.centerX * 0.5f - arrowImage.size.width * 0.5f, self.contentView.frame.size.height * 0.5f - arrowImage.size.height * 0.5f, arrowImage.size.width, arrowImage.size.height);
        _animateImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    self.animateImageView.hidden = YES;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    //
    self.animateImageView.frame = CGRectMake(self.contentView.centerX * 0.5f - self.animateImageView.width * 0.5f, self.contentView.frame.size.height * 0.5f - self.animateImageView.height * 0.5f, self.animateImageView.width, self.animateImageView.height);
}

- (void) resizeHeightTo : (CGFloat) newHeight {
    if ( self.isAutoLayout && self.contentViewTopConstraint && self.superview ) {
        CGFloat height = self.bounds.size.height < newHeight ? self.bounds.size.height : newHeight;
        self.contentViewTopConstraint.constant = - height;
        //
        if ( self.isAbsorb && newHeight > self.bounds.size.height ) {
            [self makeTransitionWithYOffset:self.bounds.size.height - newHeight];
        }
    } else {
        CGRect frame = self.contentView.frame;
        CGFloat newY = self.contentView.bounds.size.height - newHeight;
        frame.origin.y = newY < 0 ? 0 : newY;
        self.contentView.frame = frame;
        if ( self.isAbsorb && newY < 0.0f ) {
            [self makeTransitionWithYOffset:newY];
        }
    }
    [self setNeedsLayout];
}

- (void) normalStateAction {
    if ( self.isAbsorb ) [self resetTransitionWithAnimation:NO];
    //
    self.topLabel.text = [NSString stringWithFormat:@"%@...",AYLocalizedString(@"下拉刷新")];
    if ( self.latestRefreshTime ) {
        self.bottomLabel.text = LETimeByNow(self.latestRefreshTime);
    }
}

- (void) awakenStateAction {
    self.topLabel.text = [NSString stringWithFormat:@"%@...",AYLocalizedString(@"松开手指刷新")];
}

- (void) respondStateAction {
    [self startActivityAnimation];
    self.topLabel.text = [NSString stringWithFormat:@"%@...",AYLocalizedString(@"正在加载")];
}

- (void) stepEndStateAction {
    if ( self.isAbsorb ) [self resetTransitionWithAnimation:NO];
    //
    [self resetLatestRefreshTimeString];
    [self stopActivityAnimation];
    [self refreshControlStateChangedTo:LERefreshControlStateNormal];
}

- (void) resetLatestRefreshTimeString {
    self.latestRefreshTime = [NSDate date];
}

- (void) startActivityAnimation {
    if ( !self.isAnimating ) {
        _isAnimating = YES;
        self.animateImageView.hidden = NO;
        [self.animateImageView.layer removeAllAnimations];
        //
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue = @(M_PI);
        rotationAnimation.duration = 0.30;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = MAXFLOAT;
        rotationAnimation.removedOnCompletion = NO;
        [self.animateImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

- (void) reTransilationTo:(CGFloat)newHeight {
    [self makeTransitionWithYOffset:-newHeight];
}

- (void) stopActivityAnimation {
    if ( self.isAnimating ) {
        _isAnimating = NO;
        [self.animateImageView.layer removeAllAnimations];
        self.animateImageView.hidden = YES;
    }
}

- (void) resetTransitionWithAnimation : (BOOL) animate {
    if ( animate ) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    } else {
        self.transform = CGAffineTransformIdentity;
    }
}

- (void) makeTransitionWithYOffset : (CGFloat) yOffset {
    self.transform = CGAffineTransformMakeTranslation(0.0f, yOffset);
}

@end
