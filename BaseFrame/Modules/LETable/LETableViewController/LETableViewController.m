//
//  LETableViewController.m
//  LE
//
//  Created by 刘云鹏 on 15/10/16.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import "LETableViewController.h"
#import "LETableHelper.h"

@interface LETableViewController ()

@end

@implementation LETableViewController

@synthesize tableView = _tableView;

- (void) dealloc {
    LEReleaseCellForTable(self.tableView);
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    _tableView.lazyLoadDelegate = nil;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if ( isIOS8 ) {
        [self setUpTableView];
    } else {
        [self setUpTableViewIOS7Fixed];
    }
    self.tableView.contentInset = [self contentInsets];
    self.tableView.scrollIndicatorInsets = [self contentInsets];
    self.tableView.contentOffset = CGPointMake(0.0f, -self.tableView.contentInset.top);
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (void) setUpTableView {
    _tableView = [LETable tableViewWithTopRefreshControl:[self topRefreshControl]
                                    bottomRefreshControl:[self bottomRefreshControl]
                                          tableViewStyle:[self tableViewStyle]];
    _tableView.delegate = self;
    _tableView.lazyLoadDelegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_tableView];
    _tableTopConstraint = [NSLayoutConstraint constraintWithItem:_tableView
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.view
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1.0f constant:0.0f];
    [self.view addConstraint:self.tableTopConstraint];

    _tableBottomConstraint = [NSLayoutConstraint constraintWithItem:_tableView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f constant:0];
    [self.view addConstraint:self.tableBottomConstraint];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:_tableView
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeLeading
                                 multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:_tableView
                                  attribute:NSLayoutAttributeTrailing
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeTrailing
                                 multiplier:1.0f constant:0.0f]];
}

- (void) setUpTableViewIOS7Fixed {
    _tableView = [LETable tableViewWithFrame:self.view.bounds topRefreshControl:[self topRefreshControl] bottomRefreshControl:[self bottomRefreshControl] tableViewStyle:[self tableViewStyle]];
    _tableView.delegate = self;
    _tableView.lazyLoadDelegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tableView];
}

#pragma mark - Configuration
- (UITableViewStyle) tableViewStyle {
    return UITableViewStylePlain;
}

- (LERefreshControl *) topRefreshControl {
    return nil;
}

- (LERefreshControl *) bottomRefreshControl {
    return nil;
}

#pragma mark - UITableViewDelgate
- (void) scrollViewDidScroll : (UIScrollView *) scrollView {
    [_tableView tableViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_tableView tableViewDidEndDragging:scrollView];
}

- (BOOL) scrollViewShouldScrollToTop : (UIScrollView *) scrollView {
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark - LELazyLoadDelegate
- (void) leTableWillBeginLoadMoreAction {
    //
}
- (void) leTableRefreshAction {
    //    sleep(3.0f);
}
- (void) leTableLoadMoreAction {
    //    sleep(3.0f);
}
//ios11安全区域发生改变
-(void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
//    if (isIPhoneX) {
//        
//        if (@available(iOS 11.0, *))
//        {
//                _tableBottomConstraint.constant = -self.view.safeAreaInsets.bottom;
//        }
//    }

}
@end
