//
//  LETableViewController.h
//  LE
//
//  Created by 刘云鹏 on 15/10/16.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import "LEAFViewController.h"
#import "LETable.h"
#import "LETopRefreshControl.h"
#import "LEBottomRefreshControl.h"

@interface LETableViewController : LEAFViewController <UITableViewDelegate, UITableViewDataSource, LETableLazyLoadDelegate>

@property (nonatomic, readonly, strong) LETable * tableView;
@property (nonatomic, strong) NSLayoutConstraint * tableTopConstraint;
@property (nonatomic, readonly, strong) NSLayoutConstraint * tableBottomConstraint;

- (UITableViewStyle) tableViewStyle;

- (LERefreshControl *) topRefreshControl;
- (LERefreshControl *) bottomRefreshControl;

#pragma mark - UITableViewDelegate
//MARK:重写需要在子类中call super
- (void) scrollViewDidScroll : (UIScrollView *) scrollView;
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (BOOL) scrollViewShouldScrollToTop : (UIScrollView *) scrollView;

#pragma mark - LELazyLoadDelegate
//MARK:重写需要在子类中call super
- (void) leTableWillBeginLoadMoreAction;

#pragma mark - UITableViewDataSource
//MARK:需要在子类中实现
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
