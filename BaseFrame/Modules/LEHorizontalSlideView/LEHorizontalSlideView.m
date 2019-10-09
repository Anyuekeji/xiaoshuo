//
//  LEHorizontalSlideView.m
//  CallU
//
//  Created by Leaf on 16/4/14.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import "LEHorizontalSlideView.h"
#import "UIView+LEAF.h"
#import "LE3Slider.h"
#import <iCarousel.h>

typedef NS_ENUM(NSInteger, LEHorizontalPageType) {
    LEHorizontalPageTypePrefix      =   -1,
    LEHorizontalPageTypeCurrent     =   0,
    LEHorizontalPageTypeSuffix      =   1,
};

typedef NS_ENUM(NSInteger, LEHorizontalPageActionType) {
    LEHorizontalPageActionTypePrefix        =   -1,
    LEHorizontalPageActionTypeNull          =   0,
    LEHorizontalPageActionTypeSuffix        =   1,
};

#define vAnimateToHalf  0.36f

@interface LEHorizontalSlideView () <UIGestureRecognizerDelegate> {
    __weak UIView * _prefixPointer;
    __weak UIView * _currentPointer;
    __weak UIView * _suffixPointer;
    
    CGFloat _damping;   //注意不能为0
    
    __weak UIGestureRecognizer * _interactivePopGestureRecognizer;
}

@property (nonatomic, strong) UIView * prefixPage;
@property (nonatomic, strong) UIView * currentPage;
@property (nonatomic, strong) UIView * suffixPage;

@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> * operationConstraints;

@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;

@end

@implementation LEHorizontalSlideView

- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self setUp];
    }
    return self;
}

- (void) setUp {
    [self setUpParams];
    [self setUpView];
    [self setUpPanGesture];
}

- (void) setUpParams {
    _damping = 8.0f;
    _currentItemIndex = -1; //初始状态
    self.operationConstraints = [NSMutableArray arrayWithCapacity:3];
    self.exclusiveTouch = YES;
}

- (void) setUpView {
    UIView * (^createViewPage)() = ^(){
        UIView * view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        return view;
    };
    //页面生成
    self.prefixPage = createViewPage();
    self.currentPage = createViewPage();
    self.suffixPage = createViewPage();
    [self setUpConstraintToView:self.prefixPage pageType:LEHorizontalPageTypePrefix];
    [self setUpConstraintToView:self.currentPage pageType:LEHorizontalPageTypeCurrent];
    [self setUpConstraintToView:self.suffixPage pageType:LEHorizontalPageTypeSuffix];
    //指针指向
    _prefixPointer = self.prefixPage;
    _currentPointer = self.currentPage;
    _suffixPointer = self.suffixPage;
}

- (void) setUpPanGesture {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanEvents:)];
    self.panGestureRecognizer.identifier = LEHorizontalSlideGestureIdentifier;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void) handlePanEvents : (UIPanGestureRecognizer *) panGestureRecognizer {
    CGFloat offset = [panGestureRecognizer translationInView:panGestureRecognizer.view].x;
    CGFloat xVelocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view].x;
    switch ( panGestureRecognizer.state ) {
        case UIGestureRecognizerStateBegan: break;
        case UIGestureRecognizerStateChanged: {
            [self animatingWhenPanGestureTranslatingX:offset];
        }   break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            [self animationWhenPanGestureStop:xVelocity];
        }   break;
        default:    break;
    }
    [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
}

#pragma mark - Gesture Animation
- (void) animatingWhenPanGestureTranslatingX : (CGFloat) offset {
    //核心动画帧
    CGFloat _minValue = - self.bounds.size.width;
    CGFloat _maxValue = self.bounds.size.width;
    BOOL haveNextPage = (self.currentItemIndex > 0 && offset > 0) || (self.currentItemIndex + 1 < self.numberOfItems && offset < 0);
    //执行动画
    CGAffineTransform transform = self.transform;
    if ( haveNextPage ) {
        transform.tx = transform.tx + offset;
    } else {
        transform.tx = offset / ceilf( fabs(transform.tx) / _damping + 1.0f) + transform.tx;
    }
    transform.tx = transform.tx >= _minValue ? transform.tx : _minValue;
    transform.tx = transform.tx <= _maxValue ? transform.tx : _maxValue;
    self.transform = transform;
}

- (void) animationWhenPanGestureStop : (CGFloat) xVelocity {
    CGFloat curTx = self.transform.tx;
    CGFloat value = self.bounds.size.width * 0.5f;
    NSTimeInterval duration = vAnimateToHalf;  //执行时间是一个半场的时间
    
    if ( curTx >= value || (curTx > 0.0f && xVelocity > 1000.0f && self.currentItemIndex > 0 ) ) {
        duration = duration * (value * 2.0f - curTx) / value;
        [self doEndAnimationActionWithActionType:LEHorizontalPageActionTypePrefix duration:duration];
    } else if ( curTx <= -value || (curTx < 0.0f && xVelocity < 1000.0f && self.currentItemIndex + 1 < self.numberOfItems) ) {
        duration = duration * (value * 2.0f + curTx) / value;
        [self doEndAnimationActionWithActionType:LEHorizontalPageActionTypeSuffix duration:duration];
    } else {
        duration = duration * fabs(curTx) / value;
        [self doEndAnimationActionWithActionType:LEHorizontalPageActionTypeNull duration:duration];
    }
}

- (void) doEndAnimationActionWithActionType : (LEHorizontalPageActionType) actionType duration : (NSTimeInterval) duration {
    CGFloat endTx = 0.0f;
    if ( actionType == LEHorizontalPageActionTypePrefix ) {
        endTx = self.bounds.size.width;
    } else if ( actionType == LEHorizontalPageActionTypeSuffix ) {
        endTx = -self.bounds.size.width;
    }
    //
    self.panGestureRecognizer.enabled = NO;
    CGAffineTransform transform = self.transform;
    transform.tx = endTx;
    [UIView animateWithDuration:duration animations:^{
        self.transform = transform;
    } completion:^(BOOL finished) {
        [self resetPointersAndConstraintsWithAction:actionType];
        self.transform = CGAffineTransformIdentity;
        self.panGestureRecognizer.enabled = YES;
    }];
}

- (void) resetPointersAndConstraintsWithAction : (LEHorizontalPageActionType) actionType  {
    void (^resetConstraints)() = ^(){
        [self removeConstraints:self.operationConstraints];
        [self.operationConstraints removeAllObjects];
        [self addConstraintToView:self->_prefixPointer pageType:LEHorizontalPageTypePrefix];
        [self addConstraintToView:self->_currentPointer pageType:LEHorizontalPageTypeCurrent];
        [self addConstraintToView:self->_suffixPointer pageType:LEHorizontalPageTypeSuffix];
    };
    __weak UIView * _weakPointer;
    if ( actionType == LEHorizontalPageActionTypePrefix ) {
        _weakPointer = _prefixPointer;
        _prefixPointer = _suffixPointer;
        _suffixPointer = _currentPointer;
        _currentPointer = _weakPointer;
        resetConstraints();
        _latestItemIndex = _currentItemIndex;
        _currentItemIndex --;
        [self loadPageAtIndex:_currentItemIndex - 1 forPage:_prefixPointer];
        [self checkSwitchInteractivePopGestureRecognizer];
        if ( self.delegate && [self.delegate respondsToSelector:@selector(horizontalSlideViewCurrentItemIndexDidChange:)] ) {
            [self.delegate horizontalSlideViewCurrentItemIndexDidChange:self];
        }
    } else if ( actionType == LEHorizontalPageActionTypeSuffix ) {
        _weakPointer = _suffixPointer;
        _suffixPointer = _prefixPointer;
        _prefixPointer = _currentPointer;
        _currentPointer = _weakPointer;
        resetConstraints();
        _latestItemIndex = _currentItemIndex;
        _currentItemIndex ++;
        [self loadPageAtIndex:_currentItemIndex + 1 forPage:_suffixPointer];
        [self checkSwitchInteractivePopGestureRecognizer];
        if ( self.delegate && [self.delegate respondsToSelector:@selector(horizontalSlideViewCurrentItemIndexDidChange:)] ) {
            [self.delegate horizontalSlideViewCurrentItemIndexDidChange:self];
        }
    }
}

#pragma mark - Constraints
- (void) setUpConstraintToView : (UIView *) view pageType : (LEHorizontalPageType) pageType {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    //
    [self addConstraintToView:view pageType:pageType];
}

- (void) addConstraintToView : (UIView *) view pageType : (LEHorizontalPageType) pageType {
    switch ( pageType ) {
        case LEHorizontalPageTypePrefix:
            [self.operationConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
            [self addConstraint:self.operationConstraints.lastObject];
            break;
        case LEHorizontalPageTypeCurrent:
            [self.operationConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
            [self addConstraint:self.operationConstraints.lastObject];
            break;
        case LEHorizontalPageTypeSuffix:
            [self.operationConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
            [self addConstraint:self.operationConstraints.lastObject];
        default:
            break;
    }
}

#pragma mark -  UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( [touch.view isKindOfClass:[LE3Slider class]] ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    return fabs(translation.x) >= fabs(translation.y);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
        return NO;
    }
    if ( otherGestureRecognizer.identifier == iCarouselPanGestureIdentifier ) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( otherGestureRecognizer == [self interactivePopGestureRecognizer] ) {
        return YES;
    } else if ( [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] && otherGestureRecognizer.state == UIGestureRecognizerStateBegan ) {
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    AYLog(@"parent touchesBegan");
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    AYLog(@"parent touchesMoved");
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    AYLog(@"parent touchesEnded");
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    AYLog(@"parent touchesCancelled");
    
}
#pragma mark - 数据配置
- (void) reloadData {
    if ( self.dataSource ) {
        _numberOfItems = [self.dataSource numberOfItemsInSlideView:self];
        self.currentItemIndex = 0;
    }
}

- (void) loadPageAtIndex : (NSInteger) index forPage: (UIView *) pageView {
    if ( self.dataSource && index >= 0 && index < self.numberOfItems ) {
        UIView * reuseView = pageView.subviews.count > 0 ? pageView.subviews.firstObject : nil;
        UIView * containerView = [self.dataSource horizontalSlideView:self viewForItemAtIndex:index reusingView:reuseView];
        [self addView:containerView ToView:pageView];
    } else {
        //移走所有子页面
        [pageView removeAllSubviews];
    }
}

- (void) addView : (UIView *) reuseView ToView : (UIView *) pageView {
    if ( ![pageView.subviews containsObject:reuseView] ) {   //如果不是已经包含的子界面
        //移走所有子界面
        [pageView removeAllSubviews];
        //移出本页面
        if ( reuseView.superview ) {
            [reuseView removeFromSuperview];
        }
        //添加新的子界面
        [pageView addSubview:reuseView];
        //约束
        reuseView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary * _binds = @{@"reuse":reuseView};
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==0@999)-[reuse]-(==0@999)-|" options:0 metrics:nil views:_binds]];
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==0@999)-[reuse]-(==0@999)-|" options:0 metrics:nil views:_binds]];
    }
}

#pragma mark - 设置页面
- (void) setCurrentItemIndex:(NSUInteger)currentItemIndex {
    if ( _currentItemIndex != currentItemIndex && currentItemIndex < self.numberOfItems ) {
        _latestItemIndex = _currentItemIndex;
        _currentItemIndex = currentItemIndex;
        //
        [self loadPageAtIndex:_currentItemIndex - 1 forPage:_prefixPointer];
        [self loadPageAtIndex:_currentItemIndex forPage:_currentPointer];
        [self loadPageAtIndex:_currentItemIndex + 1 forPage:_suffixPointer];
        //开关左滑动退出页面逻辑
        [self checkSwitchInteractivePopGestureRecognizer];
        //发送代理通知
        if ( self.delegate && [self.delegate respondsToSelector:@selector(horizontalSlideViewCurrentItemIndexDidChange:)] ) {
            [self.delegate horizontalSlideViewCurrentItemIndexDidChange:self];
        }
    }
}

- (void) setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [_suffixPage setBackgroundColor:backgroundColor];
    [_prefixPage setBackgroundColor:backgroundColor];
    [_currentPage setBackgroundColor:backgroundColor];
}

- (void) checkSwitchInteractivePopGestureRecognizer {
    if ( self.currentItemIndex == 0 ) {
        [self enableInteractivePopGestureRecognizer];
    } else {
        [self disableInteractivePopGestureRecognizer];
    }
}

- (UIGestureRecognizer *) interactivePopGestureRecognizer {
    if ( !_interactivePopGestureRecognizer ) {
        UINavigationController * navigationController = nil;
        for (UIView* next = [self superview]; next; next = next.superview) {
            UIResponder* nextResponder = [next nextResponder];
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                navigationController = [(UIViewController *)nextResponder navigationController];
                break;
            }
        }
        if ( navigationController ) {
            _interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer;
         //   _interactivePopGestureRecognizer.enabled = NO;
        }
    }
    return _interactivePopGestureRecognizer;
}

- (void) enableInteractivePopGestureRecognizer {
    [[self interactivePopGestureRecognizer] setEnabled:YES];
}

- (void) disableInteractivePopGestureRecognizer {
    [[self interactivePopGestureRecognizer] setEnabled:NO];
}

@end
