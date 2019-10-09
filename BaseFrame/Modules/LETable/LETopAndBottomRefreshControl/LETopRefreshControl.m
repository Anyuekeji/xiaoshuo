//
//  LETopRefreshControl.m
//  xiaoyuanplus
//
//  Created by刘云鹏 on 14/12/10.
//  Copyright (c) 2014年刘云鹏. All rights reserved.
//

#import "LETopRefreshControl.h"
#import "LERefreshActivityIndicatorView.h"

@interface LETopRefreshControl ()

@property (nonatomic, strong) UIImageView * indicatorImageView;
@property (nonatomic, strong) LERefreshActivityIndicatorView * indicatorAnimateView;

@end

@implementation LETopRefreshControl

@synthesize indicatorImageView = _indicatorImageView;
@synthesize indicatorAnimateView = _indicatorAnimateView;

- (void) initParams {
    [super initParams];
    //
    [self initIndicatorImageView];
    [self initActivityIndicatorView];
}

- (void) initIndicatorImageView {
    UIImage * arrowImage = [UIImage imageNamed:@"lazyload_blueArrowUp"];
    _indicatorImageView = [[UIImageView alloc] initWithImage:arrowImage];
    if ( self.isAutoLayout ) {
        _indicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_indicatorImageView];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_indicatorImageView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f constant:0.0f]];
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
        _indicatorImageView.frame = CGRectMake(self.contentView.frame.size.width * 0.5f - arrowImage.size.width * 0.5f, self.contentView.frame.size.height * 0.5f - arrowImage.size.height * 0.5f, arrowImage.size.width, arrowImage.size.height);
        _indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
}

- (void) initActivityIndicatorView {
    _indicatorAnimateView = [LERefreshActivityIndicatorView activityIndicatorView];
}

- (void) resizeHeightTo : (CGFloat) newHeight {
    if ( self.isAutoLayout && self.contentViewTopConstraint && self.superview ) {
        newHeight = self.bounds.size.height < newHeight ? self.bounds.size.height : newHeight;
        self.contentViewTopConstraint.constant = - newHeight;
    } else {
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.contentView.bounds.size.height - newHeight;
        frame.origin.y = frame.origin.y < 0 ? 0 : frame.origin.y;
        self.contentView.frame = frame;
    }
    [self setNeedsLayout];
}

- (void) normalStateAction {
    [self stopImageAnimation];
}

- (void) awakenStateAction {
    [self startImageAnimation];
}

- (void) respondStateAction {
    [self startActivityAnimation];
}

- (void) stepEndStateAction {
    [self stopActivityAnimation];
    [self refreshControlStateChangedTo:LERefreshControlStateNormal];
}

- (void) startActivityAnimation {
    _indicatorImageView.hidden = YES;
    if ( _indicatorAnimateView ) {
        _indicatorAnimateView.center = CGPointMake(self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f);
        if ( self.contentView != _indicatorAnimateView.superview ) {
            [self.contentView addSubview:_indicatorAnimateView];
        }
        [_indicatorAnimateView startAnimating];
    }
}

- (void) stopActivityAnimation {
    _indicatorImageView.hidden = NO;
    if ( _indicatorAnimateView ) {
        [_indicatorAnimateView stopAnimating];
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

@end
