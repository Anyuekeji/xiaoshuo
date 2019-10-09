//
//  AYFriendSegmentViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/23.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFriendSegmentViewController.h"
#import "AYInvationViewController.h" //邀请好友
#import "AYMyFriendViewController.h"//我的好友
#import "LESegment.h"
#import <NSString+YYAdd.h>

@interface AYFriendSegmentViewController ()

@end

@implementation AYFriendSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUi];
    [self configurateData];
    // Do any additional setup after loading the view.
}
-(BOOL)shouldShowNavigationBar
{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)configureUi
{
    self.segmentControl.bottomLineColor = RGB(250, 85, 108);
    CGFloat detailfontWidth =  LETextWidth(AYLocalizedString(@"邀请好友"), [UIFont systemFontOfSize:14]);
    CGFloat selectfontWidth =  LETextWidth(AYLocalizedString(@"我的好友"), [UIFont systemFontOfSize:14]);
    
    CGFloat originx = (ScreenWidth - detailfontWidth - selectfontWidth)/4.0f;
    self.segmentControl.itemOrginX = originx;
    self.segmentControl.horizontalGap =originx;
    self.segmentControl.selectedColor = RGB(51, 51, 51);
    self.segmentControl.normalColor = RGB(102, 102, 102);
}
- (void) configurateData
{
    self.title = AYLocalizedString(@"邀请好友");
    
    NSMutableArray<ZWR2SegmentItem *> * segs = [NSMutableArray array];
    NSArray *itemArray = @[AYLocalizedString(@"邀请好友"),AYLocalizedString(@"我的好友")];
    NSArray *classArray = @[@"AYInvationViewController",@"AYMyFriendViewController"];
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [segs addObject:[ZWR2SegmentItem segmentItemWithIdentifier:@(idx)
                                                             title:obj
                                            forViewControllerClass:NSClassFromString(classArray[idx])
                                                      registerItem:obj]];
    }];
    //实施页面内容
    [self setSegments:segs];
}
#pragma mark - ZWRChainReactionProtocol
/**
 *  当前选中状态又重新选择了这个tabbar，会向当前所在控制器发送本请求事件
 */
- (void) zwrChainReactionEventTabBarDidReClickAfterAppear {
    UIViewController * viewController = self.currentSelectedViewController;
    if ( viewController && [viewController conformsToProtocol:@protocol(ZWRChainReactionProtocol)] ) {
        UIViewController<ZWRChainReactionProtocol> * zwrcrpViewController = (UIViewController<ZWRChainReactionProtocol> *)viewController;
        if ( [zwrcrpViewController respondsToSelector:@selector(zwrChainReactionEventTabBarDidReClickAfterAppear)] ) {
            [zwrcrpViewController zwrChainReactionEventTabBarDidReClickAfterAppear];
        }
    }
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYFriendSegmentViewController controller];
}
@end
