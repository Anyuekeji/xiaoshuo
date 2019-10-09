//
//  AYBookmailViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/11.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYBookmailViewController.h"
#import "AYFreeBookViewController.h"//免费
#import "AYFictionViewController.h" //小说
#import "AYCartoonViewController.h" //漫画
#import "LESegment.h"
#import <NSString+YYAdd.h>
#import "AYBookMailTopView.h"

@interface AYBookmailViewController ()
@property(nonatomic,strong)AYBookMailTopView *topView;
@end

@implementation AYBookmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUi];
    [self configurateData];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //由于任务栏隐藏了导航栏，会改变当前view的高度 所以要重置高度
    self.view.height = self.parentViewController.view.height-Height_TapBar;
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
-(void)configureUi
{
    self.segmentControl.bottomLineColor = RGB(250, 85, 108);
    CGFloat cartoonfontWidth =  LETextWidth(AYLocalizedString(@"漫画"), [UIFont systemFontOfSize:13]);
    CGFloat fictionfontWidth =  LETextWidth(AYLocalizedString(@"小说"), [UIFont systemFontOfSize:13]);
    CGFloat freefontWidth =  LETextWidth(AYLocalizedString(@"免费"), [UIFont systemFontOfSize:13]);
    CGFloat originx = (ScreenWidth - cartoonfontWidth - fictionfontWidth-freefontWidth)/5.0f;
   self.segmentControl.itemOrginX = originx-6;
    self.segmentControl.horizontalGap =originx;
    self.segmentControl.selectedColor = RGB(250, 85, 108);
    self.segmentControl.normalColor = RGB(102, 102, 102);
    [self.view addSubview:self.topView];
    self.segmenControlTopContraint.constant = self.topView.height;
//    self.segmentControl.type = LESegmentTypeFixedWidth;
//    self.segmentControl.itemFixedWidth = ScreenWidth/3.0f;

}
- (void) configurateData
{
    NSMutableArray<ZWR2SegmentItem *> * segs = [NSMutableArray array];
    NSArray *itemArray = @[AYLocalizedString(@"小说"),AYLocalizedString(@"免费"),AYLocalizedString(@"漫画")];
    NSArray *classArray = @[@"AYFictionViewController",@"AYFreeBookViewController",@"AYCartoonViewController"];
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [segs addObject:[ZWR2SegmentItem segmentItemWithIdentifier:@(idx)
                                                             title:obj
                                            forViewControllerClass:NSClassFromString(classArray[idx])
                                                      registerItem:obj]];
    }];
    //实施页面内容
    [self setSegments:segs];
}
#pragma mark - Getter and setter -
-(AYBookMailTopView*)topView
{
    if (!_topView) {
        _topView = [[AYBookMailTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, Height_TopBar)];
    }
    return _topView;
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
#pragma mark - public  -
-(void)updateSegmentIndex
{
    if (self.currentIndex!=0)
    {
        self.currentIndex=0;
    }
}
-(void)showNavagationBar:(BOOL)show animate:(BOOL)animate
{
    if (show && self.topView.top<0)
    {
    self.segmenControlTopContraint.constant=self.topView.height;

        [UIView animateWithDuration:(animate?.3f:0) animations:^{
                self.topView.top = 0;
            self.topView.alpha =1;
            [self.view layoutIfNeeded];
            }];
    }
    else if (!show && self.topView.top>=0)
    {
    self.segmenControlTopContraint.constant=STATUS_BAR_HEIGHT;

        [UIView animateWithDuration:(animate?.3f:0) animations:^{
            self.topView.top = -self.topView.height+10;
            self.topView.alpha =0;
            [self.view layoutIfNeeded];
        }];
    }

}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYBookmailViewController controller];
}
@end
