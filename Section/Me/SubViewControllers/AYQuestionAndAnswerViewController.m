//
//  AYQuestionAndAnswerViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/26.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYQuestionAndAnswerViewController.h"
#import "AYMeTableViewCell.h"
#import "AYQAModel.h"

@interface AYQuestionAndAnswerViewController ()
@property(nonatomic,strong)NSMutableArray *QAArray;
@property(nonatomic,strong)NSMutableDictionary *sectionHeadViewDic;
@property (copy, nonatomic) void(^callBack)(id obj);

@end

#define  QA_HEADVIEW_HEIGHT 56
@implementation AYQuestionAndAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureData];
    [self loadQA];
    // Do any additional setup after loading the view.
}
-(void)configureData
{
    self.title = AYLocalizedString(@"常见问题");
    _QAArray = [NSMutableArray array];
    _sectionHeadViewDic = [NSMutableDictionary new];
}
-(void)configureUI
{
    [self configureTableview];
}
-(void)configureTableview
{
  LERegisterCellForTable(AYMeAnswerTableViewCell.class, self.tableView);

    self.tableView.tableFooterView = [UIView new];
    //LEConfigurateCellBehaviorsFunctions([AYMeAnswerTableViewCell class], @selector(filCellWithModel: ),nil);

}
#pragma mark - UI -
-(UIView*)createHeadViewWithSection:(NSInteger)section
{
    UIView *sectionHeadView =[_sectionHeadViewDic objectForKey:@(section)];
    if (sectionHeadView) {
        return sectionHeadView;
    }
    AYQAModel *qaModel = [_QAArray safe_objectAtIndex:section];
    CGFloat headViewHeight = QA_HEADVIEW_HEIGHT;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, headViewHeight)];
  //  [headView setBackgroundColor:[UIColor whiteColor]];
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont boldSystemFontOfSize:DEFAUT_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    titleLable.frame = CGRectMake(15, 1, ScreenWidth-30-12-5, headViewHeight-4);
    titleLable.text = qaModel.question;
    [titleLable setBackgroundColor:[UIColor clearColor]];
    UIView *underLine = [[UIView alloc]  initWithFrame:CGRectMake(0, headView.height-0.8f, headView.width, 0.5f)];
    [underLine setBackgroundColor:UIColorFromRGB(0xe7e7e7)];
    [headView addSubview:underLine];
    [headView addSubview:titleLable];
    
    UIImageView *arrayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(headView.width-16-15, (headViewHeight-16)/2.0f, 16, 16)];
    [headView addSubview:arrayImageView];
    [arrayImageView setImage:LEImage(@"arry_right_black")];
    if (qaModel.expand) {
        arrayImageView.transform =     CGAffineTransformMakeRotation(90 *M_PI / 180.0);
    }
    LEWeakSelf(self)
    [headView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        qaModel.expand=!qaModel.expand;
        [UIView animateWithDuration:0.3f animations:^{
            [UIView performWithoutAnimation:^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                
            }];
            
            if(qaModel.expand)
            {
                arrayImageView.transform =   CGAffineTransformMakeRotation(90 *M_PI / 180.0);
            }
            else
            {
                arrayImageView.transform =   CGAffineTransformIdentity;
            }
            
        }];
    }];
    [_sectionHeadViewDic setObject:headView forKey:@(section)];
    return headView;
}
#pragma mark - network -
-(void)loadQA
{
    [self showHUD];
    [ZWNetwork post:@"HTTP_Post_QA" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             [self hideHUD];
             NSArray *itemArray = [AYQAModel itemsWithArray:record];
             [self.QAArray addObjectsFromArray:itemArray];
             [self.QAArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 AYQAModel *qaModel =(AYQAModel*)obj;
                 qaModel.expand = NO;
             }];
             [self.tableView reloadData];
             
         }
     } failure:^(LEServiceError type, NSError *error) {
         [self hideHUD];
         occasionalHint([error localizedDescription]);
     }];

}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.QAArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AYQAModel *qaModel = [_QAArray safe_objectAtIndex:section];
    if (qaModel.expand) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AYQAModel *qaModel = [_QAArray safe_objectAtIndex:indexPath.section];
    AYMeAnswerTableViewCell* cell=   LEGetCellForTable([AYMeAnswerTableViewCell class], tableView, indexPath);
    [cell filCellWithModel:qaModel.answer];
    return cell;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    
    UIView *headView = [self createHeadViewWithSection:section];
    return headView;
   
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AYQAModel *qaModel = [_QAArray safe_objectAtIndex:indexPath.section];
    if(!qaModel)
    {
        return 0;
    }
    CGFloat textHeight = LETextHeight(qaModel.answer, [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE], ScreenWidth-30)+25;
    //CGFloat cellHeight=LEGetHeightForCellWithObject(AYMeAnswerTableViewCell.class, qaModel.answer,nil);
    return  textHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //没有数据就为0
    AYQAModel *qaModel = [_QAArray safe_objectAtIndex:section];
    if(!qaModel)
    {
        return 0;
    }
    return QA_HEADVIEW_HEIGHT;
}
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section ==1 && indexPath.row ==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
        if(self.callBack)
        {
            self.callBack(@(YES));
        }
    }
}
//headerview  不悬停
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    CGFloat sectionHeaderHeight = QA_HEADVIEW_HEIGHT;
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
    return [AYQuestionAndAnswerViewController controller];
}
+ (void) eventSetCallBack:(void(^)(id obj)) block controller:(UIViewController*)controller;
{
    if ([controller isKindOfClass:[AYQuestionAndAnswerViewController class]]){
        AYQuestionAndAnswerViewController *viewController = (AYQuestionAndAnswerViewController*)controller;
        viewController.callBack= block;
    }
}
@end
