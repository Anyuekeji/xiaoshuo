//
//  LECollectionViewController.m
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/9.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "LECollectionViewController.h"
#import "LECollectionHelper.h"

@interface LECollectionViewController ()

@end

@implementation LECollectionViewController

@synthesize collectionView = _collectionView;

- (void) dealloc {
    LEReleaseCellForCollection(_collectionView);
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    _collectionView.lazyLoadDelegate = nil;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if ( isIOS8 ) {
        [self setUpCollectionView];
    } else {
        [self setUpCollectionViewIOS7Fixed];
    }
    self.collectionView.contentInset = [self contentInsets];
    self.collectionView.scrollIndicatorInsets = [self contentInsets];
    self.collectionView.contentOffset = CGPointMake(0.0f, -self.collectionView.contentInset.top);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) setUpCollectionView {
    _collectionView = [LECollection collectionViewWithTopRefreshControl:[self topRefreshControl]
                                    bottomRefreshControl:[self bottomRefreshControl]];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.delegate = self;
    _collectionView.lazyLoadDelegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_collectionView];
    _collectionTopConstraint = [NSLayoutConstraint constraintWithItem:_collectionView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0f constant:0.0f];
    [self.view addConstraint:self.collectionTopConstraint];
    _collectionBottomConstraint = [NSLayoutConstraint constraintWithItem:_collectionView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0f constant:0.0f];
    [self.view addConstraint:self.collectionBottomConstraint];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:_collectionView
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeLeading
                                 multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:_collectionView
                                  attribute:NSLayoutAttributeTrailing
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeTrailing
                                 multiplier:1.0f constant:0.0f]];
}

- (void) setUpCollectionViewIOS7Fixed {
    _collectionView = [LECollection collectionViewWithFrame:self.view.bounds topRefreshControl:[self topRefreshControl] bottomRefreshControl:[self bottomRefreshControl]];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.delegate = self;
    _collectionView.lazyLoadDelegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_collectionView];
}

#pragma mark - Configuration
- (LERefreshControl *) topRefreshControl {
    return nil;
}

- (LERefreshControl *) bottomRefreshControl {
    return nil;
}

#pragma mark - UICollectionViewDelgate
- (void) scrollViewDidScroll : (UIScrollView *) scrollView {
    [_collectionView collectionViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_collectionView collectionViewDidEndDragging:scrollView];
}

- (BOOL) scrollViewShouldScrollToTop : (UIScrollView *) scrollView {
//    [self showNavBar];
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//    return nil;
//    
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//
//    return CGSizeZero;
//
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//
//    return CGSizeZero;
//}


#pragma mark - LELazyLoadDelegate
//- (void) leCollectionWillBeginLoadMoreAction {
////    [self showNavBarAnimated:NO];
//}
//
//- (void) leCollectionRefreshAction {
////    sleep(3.0f);
//}
//
//- (void) leCollectionLoadMoreAction {
////    sleep(3.0f);
//}

@end
