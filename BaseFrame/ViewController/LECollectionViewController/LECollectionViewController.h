//
//  LECollectionViewController.h
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/9.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "LEAFViewController.h"
#import "LECollection.h"
#import "LETopRefreshControl.h"
#import "LEBottomRefreshControl.h"

@interface LECollectionViewController : LEAFViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, LECollectionLazyLoadDelegate,UICollectionViewDelegate>

@property (nonatomic, readonly, strong) LECollection * collectionView;
@property (nonatomic, readonly, strong) NSLayoutConstraint * collectionTopConstraint;
@property (nonatomic, readonly, strong) NSLayoutConstraint * collectionBottomConstraint;

- (LERefreshControl *) topRefreshControl;
- (LERefreshControl *) bottomRefreshControl;

#pragma mark - UICollectionViewDelegate
//MARK:需要在子类中call super
- (void) scrollViewDidScroll : (UIScrollView *) scrollView;
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (BOOL) scrollViewShouldScrollToTop : (UIScrollView *) scrollView;

#pragma mark - LELazyLoadDelegate
//MARK:如果集成了顶部导航栏的隐藏和出现需要在子类中call super
- (void) leCollectionWillBeginLoadMoreAction;

#pragma mark - UICollectionViewDataSource
//MARK:需要在子类中实现
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
