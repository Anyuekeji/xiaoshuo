//
//  AYCommentViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCommentViewController.h"
#import "AYCommentTableViewCell.h" //cell
#import "AYCommentModel.h"

@interface AYCommentViewController ()
@property(nonatomic,strong) NSMutableArray<AYCommentModel*> *commentList;
@property(nonatomic,copy) NSString  *bookId;
@property(nonatomic,assign) BOOL  hasMoreData;
@property(nonatomic,assign) AYCommentType  commentType;
@property (nonatomic, assign) int page;//页数

@end

@implementation AYCommentViewController

-(instancetype)initWithParas:(NSDictionary*)para
{
    self = [super init];
    if (self)
    {
        self.bookId = para[@"book_id"];
        self.commentType = [para[@"type"] integerValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateData];
    [self configurateTableView];
    [self loadFictionCommentList:YES complete:nil];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark - Init
- (void) configurateTableView {
    LERegisterCellForTable(AYCommentTableViewCell.class, self.tableView);
    LEConfigurateCellBehaviorsFunctions([AYCommentTableViewCell class], @selector(fillCellWithModel: ),nil);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
- (void) configurateData
{
    self.page =1;
    self.title = AYLocalizedString(@"评论");
    _commentList = [NSMutableArray new];
}

#pragma mark - network -
-(void)loadFictionCommentList:(BOOL)refresh complete:(void(^)(void)) completeBlock
{
    if (!completeBlock) {
        [self showHUD];
    }
    
    if (refresh) {
        self.page =1;
    }
    else
    {
        self.page+=1;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(self.page) forKey:@"page"]; //删除的小说id
        if ([self.bookId integerValue]>0)
        {
            switch (self.commentType) {
                case AYCommentTypeSelf:
                    
                    break;
                case AYCommentTypeFiction:
                    [params addValue:self.bookId forKey:@"book_id"]; //删除的小说id
                    break;
                case AYCommentTypeCartoon:
                    [params addValue:self.bookId forKey:@"cartoon_id"]; //删除的小说id
                    break;
                default:
                    break;
            }
            

        }
    }];
  //  HTTP_Post_User_CommentList
    [ZWNetwork post:(self.commentType == AYCommentTypeSelf)?@"HTTP_Post_User_CommentList":@"HTTP_Post_Book_Commen" parameters:para success:^(id record)
     {
         if (completeBlock) {
             completeBlock();
         }
         [self hideHUD];
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYCommentModel itemsWithArray:record];
             if (refresh) {
                 [self.commentList removeAllObjects];
             }
             if (itemArray.count<DEFAUT_PAGE_SIZE) {
                 self.hasMoreData = NO;
             }
             else
             {
                 self.hasMoreData = YES;
             }
             if (itemArray.count>0) {
                 [self.commentList safe_addObjectsFromArray:itemArray];
                 [self.tableView reloadData];
             }
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         [self hideHUD];
         occasionalHint([error localizedDescription]);
         if (completeBlock) {
             completeBlock();
         }
         
     }];
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
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_commentList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_commentList safe_objectAtIndex:indexPath.row];
    AYCommentTableViewCell *cell = LEGetCellForTable(AYCommentTableViewCell.class, tableView, indexPath);
    [cell fillCellWithModel:object];
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_commentList safe_objectAtIndex:indexPath.row];
    CGFloat cellHeight =LEGetHeightForCellWithObject(AYCommentTableViewCell.class, object,nil);
    return  cellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
#pragma mark - LELazyLoadDelegate
- (void) leTableRefreshChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:YES complete:completeBlock];
}

- (void) leTableLoadMoreChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:NO complete:completeBlock];
}

- (BOOL) leTableLoadNotAnyMore {
    return !_hasMoreData;
}

- (void) leTableChockAction : (BOOL) isRefresh complete : (void (^)(void)) completeBlock {
    
    [self loadFictionCommentList:isRefresh complete:completeBlock];
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters && [parameters isKindOfClass:NSDictionary.class]) {
        return YES;

    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYCommentViewController alloc] initWithParas:parameters];
}
@end
