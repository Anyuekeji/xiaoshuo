//
//  LECollection.m
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/10.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "LECollection.h"

@interface LECollection ()

@property (nonatomic, strong) NSLayoutConstraint * bottomRefreshControlConstraint;
@property (nonatomic, assign) BOOL isAutoLayout;
@property (nonatomic, assign) BOOL forceRefreshEvent;

@end

@implementation LECollection

@synthesize topRefreshControl = _topRefreshControl;
@synthesize bottomRefreshControl = _bottomRefreshControl;
@synthesize supportTopRefresh = _supportTopRefresh;
@synthesize supportBottomRefresh = _supportBottomRefresh;

@synthesize inRefreshEvent = _inRefreshEvent;
@synthesize hadRefreshing = _hadRefreshing;

@synthesize lazyLoadDelegate = _lazyLoadDelegate;

@synthesize bottomRefreshControlConstraint = _bottomRefreshControlConstraint;
@synthesize isAutoLayout = _isAutoLayout;

@synthesize cancelStick = _cancelStick;
@synthesize stickHeight = _stickHeight;

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        
    }
    return self;
}

#pragma mark - Initializations
+ (id) collectionView {
    return [self collectionViewWithTopRefreshControl:nil bottomRefreshControl:nil];
}

+ (id) collectionViewWithTopRefreshControl : (LERefreshControl *) topRefreshControl {
    return [self collectionViewWithTopRefreshControl:topRefreshControl bottomRefreshControl:nil];
}

+ (id) collectionViewWithBottomRefreshControl : (LERefreshControl *) bottomRefreshControl {
    return [self collectionViewWithTopRefreshControl:nil bottomRefreshControl:bottomRefreshControl];
}

+ (id) collectionViewWithTopRefreshControl:(LERefreshControl *)topRefreshControl bottomRefreshControl : (LERefreshControl *) bottomRefreshControl {
    return [[self alloc] initWithTopRefreshControl:topRefreshControl bottomRefreshControl:bottomRefreshControl];
}

+ (id) collectionViewWithFrame:(CGRect)frame topRefreshControl:(LERefreshControl *)topRefreshControl bottomRefreshControl:(LERefreshControl *)bottomRefreshControl {
    return [[self alloc] initWithFrame:frame topRefreshControl:topRefreshControl bottomRefreshControl:bottomRefreshControl];
}

- (instancetype) initWithTopRefreshControl : (LERefreshControl *) topRefreshControl bottomRefreshControl : (LERefreshControl *) bottomRefreshControl {
    self = [self init];
    if ( self ) {
        [self initParamsWithTopRefreshControl:topRefreshControl bottomRefreshControll:bottomRefreshControl isAutoLayout:isIOS8];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame topRefreshControl : (LERefreshControl *) topRefreshControl bottomRefreshControl : (LERefreshControl *) bottomRefreshControl {
    self = [self initWithFrame:frame];
    if ( self ) {
        [self initParamsWithTopRefreshControl:topRefreshControl bottomRefreshControll:bottomRefreshControl isAutoLayout:NO];
    }
    return self;
}

- (void) initParamsWithTopRefreshControl : (LERefreshControl *) topRefreshControl bottomRefreshControll : (LERefreshControl *) bottomRefreshControl isAutoLayout : (BOOL) isAutoLayout {
    _topRefreshControl = topRefreshControl;
    _supportTopRefresh = _topRefreshControl != nil;
    _bottomRefreshControl = bottomRefreshControl;
    _supportBottomRefresh = _bottomRefreshControl != nil;
    
    _isAutoLayout = isAutoLayout;
    self.translatesAutoresizingMaskIntoConstraints = !_isAutoLayout;
    if ( _supportTopRefresh ) [self preparedTopRefreshControl];
    if ( _supportBottomRefresh ) [self preparedBottomRefreshControl];
    _hadRefreshing = NO;
}

#pragma mark - RefreshControl Constraint
- (void) preparedTopRefreshControl {
    if ( _isAutoLayout ) {
        [self addSubview:_topRefreshControl];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_topRefreshControl
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1.0f constant:0]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_topRefreshControl
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0f constant:[_topRefreshControl controlHeight]]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_topRefreshControl
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f constant:0.0f]];
    } else {
        CGFloat width = self.bounds.size.width > 0 ? self.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
        _topRefreshControl.frame = CGRectMake(0.0f, -[_topRefreshControl controlHeight], width, [_topRefreshControl controlHeight]);
        [self addSubview:_topRefreshControl];
    }
    [_topRefreshControl refreshControlStateChangedTo:LERefreshControlStateNormal];
}

- (void) preparedBottomRefreshControl {
    if ( _isAutoLayout ) {
        [self addSubview:_bottomRefreshControl];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_bottomRefreshControl
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1.0f constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_bottomRefreshControl
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0f constant:[_bottomRefreshControl controlHeight]]];
        _bottomRefreshControlConstraint = [NSLayoutConstraint constraintWithItem:_bottomRefreshControl
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0f constant:50.0f];
        [self addConstraint:self.bottomRefreshControlConstraint];
    } else {
        CGFloat width = self.bounds.size.width > 0 ? self.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
        _bottomRefreshControl.frame = CGRectMake(0.0f, self.bounds.size.height, width, [_bottomRefreshControl controlHeight]);
        [self addSubview:_bottomRefreshControl];
    }
    [_bottomRefreshControl refreshControlStateChangedTo:LERefreshControlStateNormal];
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"contentSize"] ) {
        if ( _isAutoLayout ) {
            _bottomRefreshControlConstraint.constant = self.contentSize.height + self.contentInset.top < self.frame.size.height ? self.frame.size.height - self.contentInset.top : self.contentSize.height;
        } else {
            CGRect frame = _bottomRefreshControl.frame;
            frame.origin.y = self.contentSize.height + self.contentInset.top < self.frame.size.height ? self.frame.size.height - self.contentInset.top : self.contentSize.height;
            _bottomRefreshControl.frame = frame;
        }
        [self setNeedsLayout];
    }
}

- (void) dealloc {
    self.delegate = nil;
    self.dataSource = nil;
    self.lazyLoadDelegate = nil;
    if ( _supportBottomRefresh ) {
        [self removeObserver:self forKeyPath:@"contentSize"];
    }
    _topRefreshControl = nil;
    _bottomRefreshControl = nil;
    _lazyLoadDelegate = nil;
    _bottomRefreshControlConstraint = nil;
}

#pragma mark - ScrollView Delegate
- (void) collectionViewDidScroll : (UIScrollView *) scrollView {
    //如果是强制刷新动作，且已经识别到状态改变，需要锁住现在的所有offset值不再做变更，直到结束
    if ( _forceRefreshEvent && [_topRefreshControl state] == LERefreshControlStateAwaken )
        return ;
    //顶部刷新动作
    if ( _supportTopRefresh && !_inRefreshEvent ) {
        CGFloat offsetY = scrollView.contentOffset.y + self.contentInset.top;
        if ( offsetY < [_topRefreshControl awakenHeight] ) {
            if ( offsetY < 0.0f ) {
                [_topRefreshControl resizeHeightTo:fabs(offsetY)];
            }
            [_topRefreshControl refreshControlStateChangedTo:LERefreshControlStateAwaken];
        } else if ( _topRefreshControl.state != LERefreshControlStateRespond ) {
            if ( offsetY < 0.0f ) {
                [_topRefreshControl resizeHeightTo:fabs(offsetY)];
            }
            [_topRefreshControl refreshControlStateChangedTo:LERefreshControlStateNormal];
        }
    }
    //底部刷新动作
    if ( _supportBottomRefresh && !_inRefreshEvent ) {
        CGFloat offsetY = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height + scrollView.contentInset.bottom;
        if ( scrollView.frame.size.height > scrollView.contentSize.height ) {
            offsetY = - scrollView.contentOffset.y;
        }
        CGFloat dragHeight = [_bottomRefreshControl awakenHeight];
        if ( offsetY <= dragHeight && _bottomRefreshControl.state != LERefreshControlStateForcedSpecial ) {
            [_bottomRefreshControl refreshControlStateChangedTo:LERefreshControlStateAwaken];
        } else if ( _bottomRefreshControl.state != LERefreshControlStateRespond && _bottomRefreshControl.state != LERefreshControlStateForcedSpecial ) {
            [_bottomRefreshControl refreshControlStateChangedTo:LERefreshControlStateNormal];
        }
    }
    //取消粘性
    if ( _cancelStick && _stickHeight > 0.0f && scrollView.contentInset.top == 0 ) {
        if ( scrollView.contentOffset.y <= _stickHeight && scrollView.contentOffset.y > 0.0f ) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
        } else if ( scrollView.contentOffset.y >= _stickHeight ) {
            scrollView.contentInset = UIEdgeInsetsMake(-_stickHeight, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
        }
    }
}

- (void) collectionViewDidEndDragging : (UIScrollView *) scrollView {
    if ( _supportTopRefresh && [_topRefreshControl refreshControlStateChangedTo:LERefreshControlStateRespond] && !_inRefreshEvent) {
        [self leCollectionBeginRefreshAction];
    }
    
    if ( _supportBottomRefresh && [_bottomRefreshControl refreshControlStateChangedTo:LERefreshControlStateRespond] && !_inRefreshEvent ) {
        [self leCollectionBeginLoadMoreAction];
    }
}

- (void) leCollectionWillBeginRefreshOrLoadMoreAction : (BOOL) isRefreshOrNotLoadMore {
    if ( isRefreshOrNotLoadMore && _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionWillBeginRefreshAction)] ) {
        [_lazyLoadDelegate leCollectionWillBeginRefreshAction];
    } else if ( !isRefreshOrNotLoadMore && _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionWillBeginLoadMoreAction)] ) {
        [_lazyLoadDelegate leCollectionWillBeginLoadMoreAction];
    }
}

- (void) leCollectionBeginLoadMoreAction {
    _inRefreshEvent = YES;
    [UIView animateWithDuration:0.0f animations:^{
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, [self.bottomRefreshControl controlHeight] + self.contentInset.bottom, self.contentInset.right);
    } completion:^(BOOL finished) {
        [self leCollectionWillBeginRefreshOrLoadMoreAction:NO];
    }];
    __weak __typeof(&*self) weakSelf = self;
    if ( _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionLoadMoreChokeAction:)] ) {
        [_lazyLoadDelegate leCollectionLoadMoreChokeAction:^{
            [weakSelf leCollectionEndLoadMoreBlockAction];
        }];
    } else if ( _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionLoadMoreAction)] ) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.lazyLoadDelegate leCollectionLoadMoreAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf leCollectionEndLoadMoreBlockAction];
            });
        });

    }
}

- (void) leCollectionEndLoadMoreBlockAction {
    if ( _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionLoadMoreActionDone)] ) {
        [_lazyLoadDelegate leCollectionLoadMoreActionDone];
    }
    [self reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom - [self.bottomRefreshControl controlHeight], self.contentInset.right);
    } completion:^(BOOL finished) {
        self->_inRefreshEvent = NO;
    }];
}

- (void) leCollectionBeginRefreshAction {
    _inRefreshEvent = YES;
    [UIView animateWithDuration:0.0f animations:^{
        self.contentInset = UIEdgeInsetsMake([self.topRefreshControl controlHeight] + self.contentInset.top, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
    } completion:^(BOOL finished) {
        [self leCollectionWillBeginRefreshOrLoadMoreAction:YES];
    }];
    __weak __typeof(&*self) weakSelf = self;
    if ( _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionRefreshChokeAction:)] ) {
        [_lazyLoadDelegate leCollectionRefreshChokeAction:^{
            [weakSelf leCollectionEndRefreshBlockAction];
        }];
    } else if ( _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionRefreshAction)] ) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.lazyLoadDelegate leCollectionRefreshAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf leCollectionEndRefreshBlockAction];
            });
        });
    }
}

- (void) leCollectionEndRefreshBlockAction {
    if ( _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionRefreshActionDone)] ) {
        [_lazyLoadDelegate leCollectionRefreshActionDone];
    }
    [self reloadData];
    
    [_topRefreshControl refreshControlStateChangedTo:LERefreshControlStateStepEnd];
    [UIView animateWithDuration:0.2f animations:^{
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top - [self.topRefreshControl controlHeight], self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
    } completion:^(BOOL finished) {
        self->_inRefreshEvent = NO;
    }];
}

- (void) reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self ) {
            [self checkIfLoadNotAnyMore];
            [super reloadData];
        }
    });
}

- (void) checkIfLoadNotAnyMore {
    if ( _supportBottomRefresh ) {
        [_bottomRefreshControl refreshControlStateChangedTo:LERefreshControlStateStepEnd];
        if ( _lazyLoadDelegate && [_lazyLoadDelegate respondsToSelector:@selector(leCollectionLoadNotAnyMore)] ) {
            if ( [_lazyLoadDelegate leCollectionLoadNotAnyMore] ) {
                [_bottomRefreshControl refreshControlStateChangedTo:LERefreshControlStateForcedSpecial];
            } else {
                [_bottomRefreshControl refreshControlStateChangedTo:LERefreshControlStateNormal];
            }
        }
    }
}

/**
 *  只执行一次的刷行动作
 */
- (void) launchRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self->_supportTopRefresh && !self->_hadRefreshing ) {
            self->_forceRefreshEvent = YES;
            [UIView animateWithDuration:0.25 animations:^{
                self.contentOffset = CGPointMake(self.contentOffset.x, [self.topRefreshControl awakenHeight] - 1.0f - self.contentInset.top);
            } completion:^(BOOL bl){
                self->_forceRefreshEvent = NO;
                [self collectionViewDidEndDragging:self];
                self->_hadRefreshing = YES;
            }];
        }
    });
}
/**
 *  可多次执行
 */
- (void) refreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self->_supportTopRefresh && !self->_inRefreshEvent) {
            self->_forceRefreshEvent = YES;
            [UIView animateWithDuration:0.25 animations:^{
                self.contentOffset = CGPointMake(self.contentOffset.x, [self.topRefreshControl awakenHeight] - 1.0f - self.contentInset.top);
            } completion:^(BOOL finished) {
                self->_forceRefreshEvent = NO;
                [self collectionViewDidEndDragging:self];
                self->_hadRefreshing = YES;
            }];
        }
    });
}

/**
 *  在非refreshEvent状态下直接重新加载数据，在refreshEvent状态下将等待到超时
 */
- (void) reloadAfterRefreshEvent {
    if ( !_inRefreshEvent ) {
        [self reloadData];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger times = 300;  //最多等待30秒
            while ( !self->_inRefreshEvent && times > 0) {
                usleep(100000); //等待0.1秒
                times --;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        });
    }
}

@end
