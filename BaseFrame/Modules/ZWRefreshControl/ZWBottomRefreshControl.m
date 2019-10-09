//
//  ZWBottomRefreshControl.m
//  qscode
//
//  Created by allen on 17/7/31.
//  Copyright © 2017年 2.0.2. All rights reserved.

#import "ZWBottomRefreshControl.h"
#import "UIView+LEAF.h"

@interface ZWBottomRefreshControl ()

@property (nonatomic, strong) UILabel * messLabel;

@property (nonatomic, strong) UIImageView * animateImageView;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation ZWBottomRefreshControl

- (void) initParams {
    [super initParams];
    //重置高度
    if ( self.isAutoLayout ) {
        self.contentViewTopConstraint.constant = - [self controlHeight];
    } else {
        self.contentView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    }
    [self initMessLabel];
    [self initAnimateImageView];
}

- (void) initMessLabel {
    _messLabel = [[UILabel alloc] init];
    _messLabel.font = [UIFont systemFontOfSize:13.0f];
    _messLabel.textColor = UIColorFromRGB(0x666666);
    _messLabel.textAlignment = NSTextAlignmentCenter;
    if ( self.isAutoLayout ) {
        _messLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_messLabel];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_messLabel
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterXWithinMargins
                                     multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_messLabel
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterYWithinMargins
                                     multiplier:1.0f constant:0.0f]];
    } else {
        [self.contentView addSubview:_messLabel];
        _messLabel.frame = CGRectMake(0.0f, 0.0f, self.contentView.width, self.contentView.height);
        self.messLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void) initAnimateImageView {
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

- (void) normalStateAction {
    self.messLabel.text = [NSString stringWithFormat:@"%@...",AYLocalizedString(@"上拉加载更多")];
}

- (void) awakenStateAction {
    self.messLabel.text = [NSString stringWithFormat:@"%@...",AYLocalizedString(@"松开手指加载更多")];
}

- (void) respondStateAction {
    self.messLabel.text = [NSString stringWithFormat:@"%@...",AYLocalizedString(@"正在加载")];
    [self startActivityAnimation];
}

- (void) stepEndStateAction {
    [self stopActivityAnimation];
    [self refreshControlStateChangedTo:LERefreshControlStateNormal];
}

- (void) forcedSpecialAction {
    self.messLabel.text = self.hiddenWhenForcedSpecial ? @"" : AYLocalizedString(@"已加载完");
    [self stopActivityAnimation];
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

- (void) stopActivityAnimation {
    if ( self.isAnimating ) {
        _isAnimating = NO;
        [self.animateImageView.layer removeAllAnimations];
        self.animateImageView.hidden = YES;
    }
}

- (CGFloat) awakenHeight {
    return - 30.0f;
}

#pragma mark - Public API
- (void)forcedToCloseControl:(BOOL)forced {
    if (forced) {
        [self refreshControlStateChangedTo:LERefreshControlStateForcedSpecial];
    } else {
        [self refreshControlStateChangedTo:LERefreshControlStateNormal];
    }
}
@end
