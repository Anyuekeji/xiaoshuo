//
//  AYFictionFreeViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/21.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYFictionFreeViewController.h"
#import "AYFictionTableViewCell.h"
#import "AYFictionViewModle.h"
#import "AYFictionModel.h"
#import "AYCartoonViewModel.h"
#import "AYCartoonTableViewCell.h"
#import "AYCartoonModel.h"

@interface AYFictionFreeViewController ()
@property (nonatomic, readwrite, strong) AYFictionViewModle * fictionViewModel; //小说数据处理
@property (nonatomic, readwrite, strong) AYCartoonViewModel * cartoonViewModel; //小说数据处理

//是否是小说
@property (assign, nonatomic) BOOL fiction;

@property (assign, nonatomic) AYFictionViewType fictionViewType;

@end

@implementation AYFictionFreeViewController
-(instancetype)initWithParas:(NSDictionary*)para
{
    self = [super init];
    if (self) {
        _fiction = [para[@"fiction"] boolValue];
        _fictionViewType = [para[@"type"] integerValue];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateData];
    [self configurateTableView];
    [self loadData:YES complete:nil];
   
    // Do any additional setup after loading the view.
}

-(void)loadData:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    if (_fictionViewType == AYFictionViewTypeFree) {
        [self loadFictionList:refresh complete:completeBlock];
    }
    else if (_fictionViewType == AYFictionViewTypeLove) {
        [self loadFictionLoveList:refresh complete:completeBlock];
    }
    else if (_fictionViewType == AYFictionViewTypeChuangxiao) {
        [self loadFictionBuyList:refresh complete:completeBlock];
    }
}
#pragma mark - Init

- (void) configurateTableView {
    LERegisterCellForTable([AYFictionTableViewCell class], self.tableView);
    LERegisterCellForTable([AYCartoonTableViewCell class], self.tableView);

    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
}
- (void) configurateData
{
    if (_fiction) {
        self.fictionViewModel = [AYFictionViewModle viewModelWithViewController:self];
        self.fictionViewModel.viewType=self.fictionViewType;
    }
    else
    {
        self.cartoonViewModel = [AYCartoonViewModel viewModelWithViewController:self];
        self.cartoonViewModel.viewType= self.fictionViewType;
    }
    if (_fictionViewType == AYFictionViewTypeFree) {
        self.title = AYLocalizedString(@"免费专区");
    }
    else if (_fictionViewType == AYFictionViewTypeLove) {
        self.title = AYLocalizedString(@"用户最爱");
    }
    else if (_fictionViewType == AYFictionViewTypeChuangxiao) {
        self.title = AYLocalizedString(@"热门畅销");
  ;    }
}
#pragma mark - network -
-(void)loadFictionList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    if(!completeBlock)
    {
        [self showHUD];
    }
    if (_fiction) {
        [_fictionViewModel getFictionFreeListDataByAction:refresh success:^(long endTime) {
            if(!completeBlock)
            {
                [self hideHUD];
            }
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
        }failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            if(!completeBlock)
            {
                [self hideHUD];
            }
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
    else
    {
        [_cartoonViewModel getCartoonFreeListDataByAction:refresh success:^(long endTime) {
            if(!completeBlock)
            {
                [self hideHUD];
            }
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
        }failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            if(!completeBlock)
            {
                [self hideHUD];
            }
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
}
-(void)loadFictionBuyList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    if(!completeBlock)
    {
        [self showHUD];
    }
    if (_fiction) {
        [_fictionViewModel getFictionUserBuyListDataByAction:refresh success:^() {
            if(!completeBlock)
            {
                [self hideHUD];
            }
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
        }failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            if(!completeBlock)
            {
                [self hideHUD];
            }
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
    else
    {
        [_cartoonViewModel getCartoonUserBuyListDataByAction:refresh success:^() {
            if(!completeBlock)
            {
                [self hideHUD];
            }
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
        }failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            if(!completeBlock)
            {
                [self hideHUD];
            }
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
}
-(void)loadFictionLoveList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    if(!completeBlock)
    {
        [self showHUD];
    }
    if (_fiction) {
        [_fictionViewModel getFictionListDataByAction:refresh success:^() {
            if(!completeBlock)
            {
                [self hideHUD];
            }
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
        }failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            if(!completeBlock)
            {
                [self hideHUD];
            }
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
    else
    {
        [_cartoonViewModel getCartoonListDataByAction:refresh success:^() {
            if(!completeBlock)
            {
                [self hideHUD];
            }
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
        }failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            if(!completeBlock)
            {
                [self hideHUD];
            }
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
}
#pragma mark - LETableView Configurate
- (LERefreshControl *) topRefreshControl {
    return [ZWTopRefreshControl controlWithAdsorb];
}
- (LERefreshControl *) bottomRefreshControl {
    return [ZWBottomRefreshControl control];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _fiction?[_fictionViewModel numberOfSections]:[_cartoonViewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  _fiction?[_fictionViewModel numberOfRowsInSection:section]:[_cartoonViewModel numberOfRowsInSection:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_fiction)
    {
        id object = [self.fictionViewModel objectForIndexPath:indexPath];
        AYFictionTableViewCell* cell=   LEGetCellForTable([AYFictionTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
    }
    else
    {
        id object = [self.cartoonViewModel objectForIndexPath:indexPath];
        AYCartoonTableViewCell* cell=   LEGetCellForTable([AYCartoonTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
    }
    
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_fiction)
    {
        id object = [self.fictionViewModel objectForIndexPath:indexPath];
        CGFloat cellHeight =LEGetHeightForCellWithObject(AYFictionTableViewCell.class, object,nil);
        return  cellHeight;
    }
    else
    {
        id object = [self.cartoonViewModel objectForIndexPath:indexPath];
        CGFloat cellHeight =LEGetHeightForCellWithObject(AYCartoonTableViewCell.class, object,nil);
        return  cellHeight;
    }
    
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_fiction)
    {
        AYFictionModel *model = [_fictionViewModel objectForIndexPath:indexPath];
        [ZWREventsManager sendViewControllerEvent:kEventAYFictionDetailViewController parameters:model];
    }
    else
    {
        AYCartoonModel *cartoonModel  = [_cartoonViewModel objectForIndexPath:indexPath];
        [ZWREventsManager sendViewControllerEvent:kEventAYCartoonContainViewController parameters:cartoonModel];
    }
}

#pragma mark - LELazyLoadDelegate
- (void) leTableRefreshChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:YES complete:completeBlock];
    
}

- (void) leTableLoadMoreChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:NO complete:completeBlock];
}

- (BOOL) leTableLoadNotAnyMore {
    return   _fiction?_fictionViewModel.isNotAnyMoreData:_cartoonViewModel.isNotAnyMoreData;
}

- (void) leTableChockAction : (BOOL) isRefresh complete : (void (^)(void)) completeBlock {
    [self loadData:isRefresh complete:completeBlock];
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if(parameters && [parameters isKindOfClass:NSDictionary.class])
    {
        return YES;
    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYFictionFreeViewController alloc] initWithParas:parameters];
}
@end
