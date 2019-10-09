//
//  LEBottomRefreshControl.m
//  xiaoyuanplus
//
//  Created by刘云鹏 on 14/12/10.
//  Copyright (c) 2014年刘云鹏. All rights reserved.
//

#import "LEBottomRefreshControl.h"
#import "LERefreshActivityIndicator2View.h"
#import "UIView+LEAF.h"

@interface LEBottomRefreshControl ()

@property (nonatomic, strong) LERefreshActivityIndicator2View * indicatorAnimateView;
@property (nonatomic, strong) UIImageView * indicatorImageView;
@property (nonatomic, strong) UILabel * messLabel;

@end

@implementation LEBottomRefreshControl

@synthesize indicatorImageView = _indicatorImageView;
@synthesize indicatorAnimateView = _indicatorAnimateView;
@synthesize messLabel = _messLabel;

- (void) initParams {
    [super initParams];
    //重置高度
    if ( self.isAutoLayout ) {
        self.contentViewTopConstraint.constant = - [self controlHeight];
    } else {
        self.contentView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    }
    [self initIndicatorImageView];
    [self initActivityIndicatorView];
    [self initMessLabel];
}

- (void) initIndicatorImageView {
    UIImage * arrowImage = [UIImage imageNamed:@"lazyload_blueArrowDown"];
    _indicatorImageView = [[UIImageView alloc] initWithImage:arrowImage];
    if ( self.isAutoLayout ) {
        _indicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_indicatorImageView];
//        [self.contentView addConstraint:
//         [NSLayoutConstraint constraintWithItem:_indicatorImageView
//                                      attribute:NSLayoutAttributeCenterX
//                                      relatedBy:NSLayoutRelationEqual
//                                         toItem:self.contentView
//                                      attribute:NSLayoutAttributeCenterX
//                                     multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_indicatorImageView
                                      attribute:NSLayoutAttributeLeading
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeLeading
                                     multiplier:1.0f constant:64.0f]
         ];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_indicatorImageView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_indicatorImageView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0f constant:arrowImage.size.width]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_indicatorImageView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0f constant:arrowImage.size.height]];
    } else {
        [self.contentView addSubview:_indicatorImageView];
        _indicatorImageView.frame = CGRectMake(self.contentView.frame.size.width * 0.20f - arrowImage.size.width * 0.5f, self.contentView.frame.size.height * 0.5f - arrowImage.size.height * 0.5f, arrowImage.size.width, arrowImage.size.height);
        _indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
}

- (void) initActivityIndicatorView {
    _indicatorAnimateView = [LERefreshActivityIndicator2View activityIndicatorView];
}

- (void) initMessLabel {
    _messLabel = [[UILabel alloc] init];
    _messLabel.font = [UIFont systemFontOfSize:16.0f];
    _messLabel.textColor = UIColorFromRGB(0x999999);
    _messLabel.textAlignment = NSTextAlignmentCenter;
    if ( self.isAutoLayout ) {
        _messLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_messLabel];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_messLabel
                                      attribute:NSLayoutAttributeLeading
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_indicatorImageView
                                      attribute:NSLayoutAttributeTrailing
                                     multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_messLabel
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_messLabel
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_messLabel
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f constant:0.0f]];
    } else {
        [self.contentView addSubview:_messLabel];
        _messLabel.frame = CGRectMake(_indicatorImageView.right, 0.0f, self.contentView.width - _indicatorImageView.right * 2.0f, self.contentView.height);
        _messLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    }
}

- (void) normalStateAction {
    self.messLabel.text = @"向上滑动查看更多";
    [self stopImageAnimation];
}

- (void) awakenStateAction {
    self.messLabel.text = @"松开加载更多";
    [self startImageAnimation];
}

- (void) respondStateAction {
    self.messLabel.text = nil;
    [self startActivityAnimation];
}

- (void) stepEndStateAction {
    [self stopActivityAnimation];
    [self refreshControlStateChangedTo:LERefreshControlStateNormal];
}

- (void) forcedSpecialAction {
    self.messLabel.text = AYLocalizedString(@"已加载完");
    [self stopActivityAnimation];
}

- (void) startActivityAnimation {
    _indicatorImageView.hidden = YES;
    if ( _indicatorAnimateView ) {
        _indicatorAnimateView.hidden = NO;
        _indicatorAnimateView.center = CGPointMake(self.bounds.size.width * 0.5f, _indicatorAnimateView.frame.size.height * 0.5f);
        if ( _indicatorAnimateView.superview != self.contentView ) {
            [self.contentView addSubview:_indicatorAnimateView];
        }
        [_indicatorAnimateView startAnimating];
    }
}

- (void) stopActivityAnimation {
    _indicatorImageView.hidden = NO;
    if ( _indicatorAnimateView ) {
        [_indicatorAnimateView stopAnimating];
        _indicatorAnimateView.hidden = YES;
    }
}

- (void) startImageAnimation {
    if ( _indicatorImageView && _indicatorImageView.image ) {
        [UIView animateWithDuration:0.3f animations:^{
            self.indicatorImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
}

- (void) stopImageAnimation {
    if ( _indicatorImageView && _indicatorImageView.image ) {
        [UIView animateWithDuration:0.3f animations:^{
            self.indicatorImageView.transform = CGAffineTransformMakeRotation(0.0f);
        }];
    }
}

- (CGFloat) awakenHeight {
    return -20.0f;
}

@end
