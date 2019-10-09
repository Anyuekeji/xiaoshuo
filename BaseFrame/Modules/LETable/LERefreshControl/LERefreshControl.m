//
//  LEDynamic.m
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/10.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "LERefreshControl.h"

@implementation LERefreshControl

@synthesize state = _state;

@synthesize contentView = _contentView;
@synthesize contentViewTopConstraint = _contentViewTopConstraint;
@synthesize autoLayout = _autoLayout;

+ (id) control {
    if ( isIOS8 ) {
        id view = [[self alloc] init];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        return view;
    } else {
        id view = [[self alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
        return view;
    }
}

+ (id) controlWithAdsorb {
    id view = [self control];
    [view setAdsorb:YES];
    return view;
}

+ (id) controlWithFrame : (CGRect) frame {
    id view = [[self alloc] initWithFrame:frame];
    return view;
}

- (instancetype) initWithCoder : (NSCoder *) aDecoder {
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        _autoLayout = YES;
        [self initContentView];
        [self initParams];

    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _autoLayout = CGRectEqualToRect(frame, CGRectZero);
        [self initContentView];
        [self initParams];
    }
    return self;
}

- (void) initParams {
    _state = LERefreshControlStateStepEnd;
    self.clipsToBounds = YES;
}

- (void) initContentView {
    if ( _autoLayout ) {
        _contentView = [[UIView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentView];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_contentView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1.0f constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_contentView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_contentView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f constant:0.0f]];
        _contentViewTopConstraint =
        [NSLayoutConstraint constraintWithItem:_contentView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0f constant:0.0f];
        [self addConstraint:_contentViewTopConstraint];
    } else {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
    }
}

- (BOOL) refreshControlStateChangedTo : (LERefreshControlState) newState {
    switch ( newState ) {
        case LERefreshControlStateNormal:
            if ( _state != LERefreshControlStateNormal ) {
                _state = LERefreshControlStateNormal;
                [self normalStateAction];
            }
            break;
        case LERefreshControlStateAwaken:
            if ( _state == LERefreshControlStateNormal ) {
                _state = LERefreshControlStateAwaken;
                [self awakenStateAction];
            }
            break;
        case LERefreshControlStateRespond:
            if ( _state == LERefreshControlStateAwaken ) {
                _state = LERefreshControlStateRespond;
                [self respondStateAction];
            }
            break;
        case LERefreshControlStateStepEnd:
            if ( _state == LERefreshControlStateRespond ) {
                _state = LERefreshControlStateStepEnd;
                [self stepEndStateAction];
            }
            break;
        case LERefreshControlStateForcedSpecial:
            _state = LERefreshControlStateForcedSpecial;
            [self forcedSpecialAction];
            break;
        default:
            break;
    }
    return _state == newState;
}

- (void) normalStateAction {
    
}

- (void) awakenStateAction {
    
}

- (void) respondStateAction {
    
}

- (void) stepEndStateAction {
    
}

- (void) forcedSpecialAction {
    
}

- (void) resizeHeightTo : (CGFloat) newHeight {

}

- (void) reTransilationTo : (CGFloat) newHeight {

}

- (CGFloat) controlHeight {
    return 44.0f;
}

- (CGFloat) awakenHeight {
    return -44.0f;
}

- (void) setAdsorb : (BOOL) adsorb {
    _adsorb = YES;
}

@end
