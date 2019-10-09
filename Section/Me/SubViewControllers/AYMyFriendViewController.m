//
//  AYMyFriendViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/22.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYMyFriendViewController.h"
#import "AYFriendModel.h"
#import "AYMeTableViewCell.h"

@interface AYMyFriendViewController ()
@property(nonatomic,strong)NSMutableArray<AYFriendModel*> *friendArray;
@property(nonatomic,assign)BOOL notAnyMore;
@property (nonatomic, assign) int page;//小说页数
@property (nonatomic, assign) NSString *friendNum;//好友数
@property (nonatomic, assign) NSString * friendRewardCoinNum;//获得的奖励数
@end

@implementation AYMyFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateData];
    [self loadFriendRecordData:YES success:nil failure:nil];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldShowNavigationBar
{
    return YES;
}
#pragma mark - UI -
-(UIView*)headView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 36)];
    UIButton *frienderNum = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) title:[NSString stringWithFormat:@"%@%@",self.friendNum,AYLocalizedString(@"人")] image:LEImage(@"user")];
    frienderNum.frame = CGRectMake(0, 0, ScreenWidth/2.0f, 36);
    [headView addSubview:frienderNum];
    
    UIButton *frienderRewardNum = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) title:[NSString stringWithFormat:@"+%@",self.friendRewardCoinNum] image:LEImage(@"wujiaoxin_select")];
    frienderRewardNum.frame = CGRectMake(ScreenWidth/2.0f, 0, ScreenWidth/2.0f, 36);
    [headView addSubview:frienderRewardNum];
    
    UIView *lineView = [[UIView alloc] initWithFrame: CGRectMake((ScreenWidth-1)/2.0f, 0, 1, headView.height)];
    lineView.backgroundColor = UIColorFromRGB(0xf7f7f7);
    [headView addSubview:lineView];
    return headView;
}
#pragma mark - Init
- (void) configurateTableView
{
 LERegisterCellForTable(AYMeFriendRecoreTableViewCell.class, self.tableView);
    self.tableView.showsVerticalScrollIndicator =NO;
    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.tableView setTableFooterView:footView];
    self.view.backgroundColor = RGB(243, 243, 243);
    self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
}
- (void) configurateData
{
    self.view.backgroundColor = [UIColor whiteColor];
    _friendArray= [NSMutableArray new];
}
#pragma mark - LETableView Configurate
- (LERefreshControl *) topRefreshControl {
    return [ZWTopRefreshControl controlWithAdsorb];
}

- (LERefreshControl *) bottomRefreshControl {
    return [ZWBottomRefreshControl control];
}
#pragma mark - network -
-(void)loadFriendRecordData: (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if (isRefresh) {
        self.page =1;
    }
    else
    {
        self.page+=1;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(self.page) forKey:@"page"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_Invate_Friend" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             NSString *userCount = record[@"user_count"];
             self.friendNum = userCount?userCount:@"0";
             NSString *userRewardCount = record[@"icon_count"];
             self.friendRewardCoinNum = userRewardCount?userRewardCount:@"0";
             if (record[@"user_invite"])
             {
                 NSArray *itemArray = [AYFriendModel itemsWithArray:record[@"user_invite"]];
                 if (itemArray.count>0) {
                     [self.friendArray removeAllObjects];
                     [self.friendArray safe_addObjectsFromArray:itemArray];
                     [self.tableView reloadData];
                     if (itemArray.count<DEFAUT_PAGE_SIZE) {
                         self->_notAnyMore = YES;
                     }
                     else
                     {
                         self->_notAnyMore = NO;
                     }
                 }
             }
             
             if (!self.tableView.tableHeaderView) {
                 self.tableView.tableHeaderView = [self headView];
             }
         }
         if (completeBlock) {
             completeBlock();
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         occasionalHint([error localizedDescription]);
         if (completeBlock) {
             completeBlock();
         }
     }];

}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friendArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_friendArray safe_objectAtIndex:indexPath.row];
    AYMeFriendRecoreTableViewCell *cell = LEGetCellForTable(AYMeFriendRecoreTableViewCell.class, tableView, indexPath);
    [cell filCellWithModel:object];
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_friendArray safe_objectAtIndex:indexPath.row];
    return  LEGetHeightForCellWithObject(AYMeFriendRecoreTableViewCell.class, object, nil);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - LELazyLoadDelegate
- (void) leTableRefreshChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:YES complete:completeBlock];
    
}

- (void) leTableLoadMoreChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:NO complete:completeBlock];
}

- (BOOL) leTableLoadNotAnyMore {
    return self.notAnyMore;
}

- (void) leTableChockAction : (BOOL) isRefresh complete : (void (^)(void)) completeBlock
{
    [self loadFriendRecordData:isRefresh success:completeBlock failure:nil];
}

#pragma mark - ZWR2SegmentViewControllerProtocol -

+ (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewControllerWithSegmentRegisterItem : (id) object segmentItem : (ZWR2SegmentItem *) segmentItem {
    return [self controller];
}
#pragma mark - ZWRChainReactionProtocol
/**当前选中状态又重新选择了这个tabbar，联动效应事件 */
- (void) zwrChainReactionEventTabBarDidReClickAfterAppear {
    [self.tableView refreshing];
}

#pragma mark - ZWRSegmentReuseProtocol
- (void) segmentRecivedMemoryWarning {
    
}
- (void) segmentViewWillAppear {
    
}
- (void) segmentViewWillDisappear {
    
}
/**
 *  当进入显示栏位的时候将会调用此方法，可实现相关逻辑
 */
- (void) segmentDidLoadViewController {
    //加载列表数据
    [self.tableView launchRefreshing];
}

- (NSString *) uniqueIdentifier {
    return @"0";
}

- (NSString *) segmentTitle {
    return AYLocalizedString(@"我的好友");
}



@end
