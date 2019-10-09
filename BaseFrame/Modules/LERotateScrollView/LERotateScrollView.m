//
//  LERotateScrollView.m
//  JCTopic
//
//  Created by liuyunpeng on 14/10/30.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "LERotateScrollView.h"
#import "iCarousel.h"
#import "NSTimer+LEAF.h"
#import "UIGestureRecognizer+LEAF.h"

@interface LERotateScrollView () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, readonly, strong) NSLayoutConstraint * pageControlBottomConstraint;

@end

@implementation LERotateScrollView

+ (id) viewWithFrame : (CGRect) frame {
    return [[LERotateScrollView alloc] initWithFrame:frame];
}

+ (id) view {
    return [[LERotateScrollView alloc] init];
}

#pragma mark - 实例化方法
- (void) dealloc {
    _timer = nil;
    _delegate = nil;
    _dataSource = nil;
}

/**
 * 停掉计时器
 * 当您启用了autoScrolling，必须在组件持有对象中访问此方法
 */
- (void) abolishTimer {
    if ( _timer ) {
        [_timer invalidate];
    }
}

- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self setUp];
    }
    return self;
}

- (void) setUp {
    _timeInterval = 3.0f;
    _autoScrolling = YES;
    //
    [self _setUpICarousel];
    [self _setUpPageControl];
}

- (void) _setUpICarousel {
    _iCarouselView = [[iCarousel alloc] init];
    self.iCarouselView.dataSource = self;
    self.iCarouselView.delegate = self;
    self.iCarouselView.pagingEnabled = YES;
    self.iCarouselView.type = iCarouselTypeLinear;
    self.iCarouselView.panGes.identifier = iCarouselPanGestureIdentifier;

    [self addSubview:self.iCarouselView];
    self.iCarouselView.translatesAutoresizingMaskIntoConstraints = NO;
    //
    NSDictionary * _binds = @{@"iCarousel":self.iCarouselView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[iCarousel]-0-|" options:0 metrics:nil views:_binds]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[iCarousel]-0-|" options:0 metrics:nil views:_binds]];
}

- (void) _setUpPageControl {
    _pageControl = [[UIPageControl alloc] init];
    self.pageControl.pageIndicatorTintColor = UIColorFromRGBA(0xffffff,0.5);
    self.pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0xfa556c);
 //self.pageControl.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.5,1.5);
    self.pageControl.hidesForSinglePage = YES;
    [self.pageControl addTarget:self action:@selector(pageControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    //
    NSDictionary * _binds = @{@"pageControl":self.pageControl};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pageControl]-12-|" options:0 metrics:nil views:_binds]];
    _pageControlBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self addConstraint:self.pageControlBottomConstraint];
    //
    self.pageControl.userInteractionEnabled = NO;
}

#pragma mark - Init Timer
- (void) initTimer {
    if ( [self timeInterval] > 0 && _autoScrolling && !_timer ) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:[self timeInterval]
                                                  target:self
                                                selector:@selector(timeDidFired)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer pauseTimer];
    }
}

- (void) pauseTimer {
    if ( _autoScrolling && _timer ) {
        [_timer pauseTimer];
    }
}

- (void) resumeTimer {
    if ( _autoScrolling && _timer && [self timeInterval] > 0 ) {
        [_timer resumeTimerAfterTimeInterval:[self timeInterval]];
    }
}

- (void) timeDidFired {
    if ( self.iCarouselView.numberOfItems > 0 && !self.iCarouselView.isDragging ) {
        NSUInteger currentIndex = self.iCarouselView.currentItemIndex;
        if ( self.iCarouselView.numberOfItems > currentIndex ) {
            [self.iCarouselView scrollToItemAtIndex:currentIndex + 1 animated:YES];
        }
    }
}

- (void) setCurrentPage : (NSInteger) currentPage {
    [_iCarouselView setCurrentItemIndex:currentPage];
}

- (NSInteger) currentPage {
    return _iCarouselView.currentItemIndex;
}

#pragma mark - Events
- (void) pageControlChangedValue : (UIPageControl *) pageControl {
    if ( self.iCarouselView.currentItemIndex != pageControl.currentPage ) {
        [self.iCarouselView scrollToItemAtIndex:self.pageControl.currentPage animated:YES];
    }
}

#pragma mark - iCarouselDatatSources
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if ( self.dataSource ) {
        return [self.dataSource numberOfPageInRotateScrollView:self];
    }
    return [self numberOfPages];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if ( self.dataSource ) {
        return [self.dataSource rotateScrollView:self viewForItemAtIndex:index reusingView:view];
    }
    return [self viewForItemAtIndex:index reusingView:view];
}

#pragma mark - iCarouselDelegate
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if ( [self.delegate respondsToSelector:@selector(leRotateScrollView:didClickPageAtIndex:)] ) {
        [self.delegate leRotateScrollView:self didClickPageAtIndex:index];
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    self.pageControl.currentPage = carousel.currentItemIndex;
    if ( [self.delegate respondsToSelector:@selector(leRotateScrollView:didMovedToPageAtIndex:)] ) {
        [self.delegate leRotateScrollView:self didMovedToPageAtIndex:carousel.currentItemIndex];
    }
    [self didAppearView:carousel.currentItemView atIndexPath:carousel.currentItemIndex];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            if ( self.delegate && [self.delegate respondsToSelector:@selector(leRotateScrollViewWarp:)] ) {
                return [self.delegate leRotateScrollViewWarp:self];
            }
            return YES;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value;
        }
        case iCarouselOptionFadeMax: {
            if (carousel.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems: {
            return value;
        }
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
    [self pauseTimer];
}

- (void) carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    [self resumeTimer];
}

#pragma mark - 重新加载数据逻辑
/**
 *  重新加载数据
 */
- (void) reloadData {
    //主线程内执行
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dataReset];
    });
}

/**
 *  数据重置
 */
- (void) dataReset {
    //时间创建
    [self initTimer];
    //先停掉时间
    if ( _timer ) {
        [_timer pauseTimer];
    }
    //再进行数据重载
    [self.iCarouselView reloadData];
    [self resetPageControlByCount:self.iCarouselView.numberOfItems];
    //完成后继续时间
    if ( _timer && [self timeInterval] > 0 && _autoScrolling) {
        [_timer resumeTimerAfterTimeInterval:[self timeInterval]];
    }
}

- (void) resetPageControlByCount : (NSUInteger) count {
    [self.iCarouselView scrollToItemAtIndex:0 animated:NO];
    self.pageControl.numberOfPages = count;
    self.pageControl.currentPage = 0;
}


/**
 *  设置翻页组件到底边的距离
 *
 *  @param verticalToBottom 距离
 */
- (void) setPageControlBottomOffset : (CGFloat) verticalToBottom {
    self.pageControlBottomConstraint.constant = - verticalToBottom;
    [self setNeedsLayout];
}

#pragma mark - Fuctions Override
- (NSUInteger) numberOfPages {
    return 0;
}

- (UIView *) viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    return nil;
}

- (void) didAppearView : (UIView *) view atIndexPath : (NSInteger) index {
    
}

@end
