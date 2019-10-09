//
//  AYFictionEidterRecommendViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/21.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYFictionEidterRecommendViewController.h"
#import "AYFictionViewModle.h"
#import "AYFictionTableViewCell.h"
#import "AYFictionModel.h"
#import "AYCartoonModel.h"
#import "AYADSkipManager.h" //banner跳转管理
#import "AYBookModel.h"

@interface AYFictionEidterRecommendViewController ()
@property (nonatomic, readwrite, strong) AYFictionViewModle * fictionViewModel; //小说数据处理

@property (nonatomic, assign) BOOL isTimeFree; //是否是限时免费

@end

@implementation AYFictionEidterRecommendViewController

-(instancetype)initWithParas:(BOOL)para
{
    self = [super init];
    if (self) {
        self.isTimeFree = para;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateData];
    [self loadList:nil];
    // Do any additional setup after loading the view.
   // HTTP_Post_Fiction_Rec
}
#pragma mark - Init
- (void) configurateTableView
{
    LERegisterCellForTable([AYFictionTableViewCell class], self.tableView);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
- (void) configurateData
{
    self.title =_isTimeFree?AYLocalizedString(@"限时免费"):AYLocalizedString(@"小说");
    self.fictionViewModel = [AYFictionViewModle viewModelWithViewController:self];
    self.fictionViewModel.viewType=_isTimeFree?AYFictionViewTypeTimeFree: AYFictionViewTypeRcommmend;
}
#pragma mark - network -
-(void)loadList:(void(^)(void)) completeBlock
{
     [self showHUD];
    if (_isTimeFree) {
        [_fictionViewModel getTimeFictionFreeListDataByAction:YES success:^(long endTime) {
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
            [self hideHUD];
        } failure:^(NSString * _Nonnull errorString) {
            [self hideHUD];
            occasionalHint(errorString);
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
    else
    {
        [_fictionViewModel getRecommendFictionListDataByAction:YES  success:^{
            [self.tableView reloadData];
            if (completeBlock) {
                completeBlock();
            }
            [self hideHUD];
            
            
        } failure:^(NSString * _Nonnull errorString) {
            [self hideHUD];
            occasionalHint(errorString);
            if (completeBlock) {
                completeBlock();
            }
        }];
    }


}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [_fictionViewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [_fictionViewModel numberOfRowsInSection:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
        id object = [self.fictionViewModel objectForIndexPath:indexPath];
    AYCartoonTableViewCell* cell=   LEGetCellForTable([AYFictionTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

        id object = [self.fictionViewModel objectForIndexPath:indexPath];
        CGFloat cellHeight =LEGetHeightForCellWithObject(AYFictionTableViewCell.class, object,nil);
        return  cellHeight;

    
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    AYFictionModel *model = [_fictionViewModel objectForIndexPath:indexPath];
    [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYFictionDetailViewController parameters:model];

}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYFictionEidterRecommendViewController alloc] initWithParas:[parameters boolValue]];
}
@end


