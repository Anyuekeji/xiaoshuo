//
//  AYTaskShareViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/18.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYTaskShareViewController.h"
#import "AYTaskTableViewCell.h"
#import "AYBookModel.h" //书本model
#import "AYADSkipManager.h"
#import "AYFictionModel.h"

@interface AYTaskShareViewController ()
@property(nonatomic,strong) NSMutableArray *shareBookList; //最近阅读
@property(nonatomic,strong) NSMutableArray *fictionRecommendArray; //小说推荐
@end

@implementation AYTaskShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configurateData];
    [self configurateTableView];
    [self loadShareBookList:YES complete:nil];
    [self getRecommendFictionListDataByAction:YES success:nil failure:nil];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
#pragma mark - Init
- (void) configurateTableView
{
    LERegisterCellForTable(AYTaskShareCell.class, self.tableView);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
- (void) configurateData
{
    self.title = AYLocalizedString(@"每日分享");
    _shareBookList = [NSMutableArray new];
    _fictionRecommendArray = [NSMutableArray new];
}

#pragma mark - network -
-(void)loadShareBookList:(BOOL)refresh complete:(void(^)(void)) completeBlock
{
    [self showHUD];
    [ZWNetwork post:@"HTTP_Post_Recent_Read" parameters:nil success:^(id record)
     {
         if (completeBlock) {
             completeBlock();
         }
         [self hideHUD];
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYBookModel itemsWithArray:record];
             if (refresh) {
                 [self.shareBookList removeAllObjects];
             }
             if (itemArray.count>0) {
                 [self.shareBookList safe_addObjectsFromArray:itemArray];
                 [UIView performWithoutAnimation:^{
                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                 }];             }
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         [self hideHUD];
         occasionalHint([error localizedDescription]);
         if (completeBlock) {
             completeBlock();
         }
         
     }];
}
- (void) getRecommendFictionListDataByAction : (BOOL) isRefresh success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Fiction_Rec" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYFictionModel itemsWithArray:record];
             if (isRefresh) {
                 [self.fictionRecommendArray removeAllObjects];
             }
             [self.fictionRecommendArray safe_addObjectsFromArray:itemArray];
             if (completeBlock)
             {
                 completeBlock();
             }
             [UIView performWithoutAnimation:^{
                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
             }];
         }
     } failure:^(LEServiceError type, NSError *error) {
         occasionalHint([error localizedDescription]);
     }];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==1) {
        return [_fictionRecommendArray count];

    }
    return [_shareBookList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object;
    if (indexPath.section ==1) {
        object = [_fictionRecommendArray safe_objectAtIndex:indexPath.row];
    }
    else
    {
        object = [_shareBookList safe_objectAtIndex:indexPath.row];

    }
    AYTaskShareCell *cell = LEGetCellForTable(AYTaskShareCell.class, tableView, indexPath);
    [cell fillCellWithModel:object];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UILabel *headLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:17] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    headLable.frame = CGRectMake(0, 0, ScreenWidth, 40);
    headLable.backgroundColor = [UIColor whiteColor];
    headLable.text =(section ==0)?[NSString stringWithFormat:@"    %@",AYLocalizedString(@"最近阅读")]:[NSString stringWithFormat:@"    %@",AYLocalizedString(@"最新推荐")];
    return headLable;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object;

    if (indexPath.section ==1) {
        object = [_fictionRecommendArray safe_objectAtIndex:indexPath.row];
    }
    else
    {
        object = [_shareBookList safe_objectAtIndex:indexPath.row];
        
    }
    CGFloat cellHeight =LEGetHeightForCellWithObject(AYTaskShareCell.class, object,nil);
    return  cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_fictionRecommendArray.count<=0 && section==1) {
        return 0;
    }
    else if (self.shareBookList.count<=0 && section==0) {
        return 0;
    }
    return 40;
}
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==0) {
        AYBookModel *object = [_shareBookList safe_objectAtIndex:indexPath.row];
        object.bookDestinationType= @(2);
        [AYADSkipManager adSkipWithModel:object];
    }
    else
    {
        AYFictionModel *fictionModel = [_fictionRecommendArray safe_objectAtIndex:indexPath.row];
            [ZWREventsManager sendViewControllerEvent:kEventAYFuctionReadViewController parameters:fictionModel];
    }
}
//headerview  不悬停
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYTaskShareViewController controller];
}
@end
