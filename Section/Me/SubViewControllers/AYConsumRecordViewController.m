//
//  AYConsumRecordViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/17.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYConsumRecordViewController.h"
#import "AYConsumeModel.h"
#import "AYMeTableViewCell.h"
#import "AYCoinSectionModel.h"

@interface AYConsumRecordViewController ()
@property(nonatomic,strong)NSMutableArray<AYConsumeModel*> *userConsumArray;
@property(nonatomic,strong)NSMutableArray<AYCoinSectionModel*> *sectionChargeArray;

@property(nonatomic,assign) BOOL  hasMoreData;
@property (nonatomic, assign) int page;//页数
@property(nonatomic,strong)NSMutableDictionary *sectionHeadViewDic;

@end

#define  CONSUM_RECORD_HEADVIEW_HEIGHT 56

@implementation AYConsumRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateData];
    //[self loadUserChargeRecordData:YES complete:nil];
    
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
#pragma mark - Init
- (void) configurateTableView
{
    
    self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
 LERegisterCellForTable(AYMeConsumeRecoreTableViewCell.class, self.tableView);    self.tableView.showsVerticalScrollIndicator =NO;
    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.tableView setTableFooterView:footView];
    self.view.backgroundColor = RGB(243, 243, 243);
}
- (void) configurateData
{
    self.page =1;
    _userConsumArray= [NSMutableArray new];
    _sectionChargeArray= [NSMutableArray new];
}

-(void)dealWithData
{
    _sectionHeadViewDic = [NSMutableDictionary new];
    
    NSMutableDictionary *chargeDic = [NSMutableDictionary new];
    [_userConsumArray enumerateObjectsUsingBlock:^(AYConsumeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *valueArray = [chargeDic objectForKey:obj.local_time];
        if (valueArray) {
            [valueArray safe_addObject:obj];
        }
        else
        {
            valueArray  = [NSMutableArray array];
            [valueArray safe_addObject:obj];
            [chargeDic setObject:valueArray forKey:obj.local_time];
        }
    }];
    NSArray *keyArray =chargeDic.allKeys;
    NSArray *result = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1]; //降序
    }];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AYCoinSectionModel *sectionModel = [AYCoinSectionModel new];
        if(idx <2)
        {
            sectionModel.expand = YES;
        }
        sectionModel.subItemArray = [chargeDic objectForKey:obj];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj integerValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dateString= [formatter stringFromDate: date];
        __block NSInteger sumChargeNum=0;
        [sectionModel.subItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if ([obj isKindOfClass:AYConsumeModel.class]) {
                 AYConsumeModel *chargeModel = obj;
                 sumChargeNum+=[chargeModel.consumeCoinNum integerValue];
             }
         }];
        NSString *sectionTitle = [NSString stringWithFormat:@"%@ %@ %ld",dateString,AYLocalizedString(@"总消耗:"),(long)sumChargeNum];
        sectionModel.sectionTitle = [self addCoinImageToString:sectionTitle];
        [self.sectionChargeArray safe_addObject:sectionModel];
    }];
    
}
-(NSMutableAttributedString*)addCoinImageToString:(NSString*)originString
{
    NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = [UIImage imageNamed:@"wujiaoxin"];
    backAttachment.bounds = CGRectMake(0, -2, 14, 14);
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:originString];
    NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    [orginalAttributString appendAttributedString:newAttributString];
    return  orginalAttributString;
}
#pragma mark - LETableView Configurate
- (LERefreshControl *) topRefreshControl {
    return [ZWTopRefreshControl controlWithAdsorb];
}

//- (LERefreshControl *) bottomRefreshControl {
//    return [ZWBottomRefreshControl control];
//}
#pragma mark - UI -
-(UIView*)createHeadViewWithSection:(NSInteger)section
{
    UIView *sectionHeadView =[_sectionHeadViewDic objectForKey:@(section)];
    if (sectionHeadView) {
        return sectionHeadView;
    }
    AYCoinSectionModel *model = [self.sectionChargeArray objectAtIndex:section];
    CGFloat headViewHeight = CONSUM_RECORD_HEADVIEW_HEIGHT;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, headViewHeight)];
    [headView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
    //  [headView setBackgroundColor:[UIColor whiteColor]];
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    titleLable.frame = CGRectMake(15, 1, ScreenWidth-30-12-5, headViewHeight-4);
    titleLable.attributedText = model.sectionTitle;
    [titleLable setBackgroundColor:[UIColor clearColor]];
    UIView *underLine = [[UIView alloc]  initWithFrame:CGRectMake(0, headView.height-0.8f, headView.width, 0.5f)];
    [underLine setBackgroundColor:UIColorFromRGB(0xe7e7e7)];
    [headView addSubview:underLine];
    [headView addSubview:titleLable];
    
    UIImageView *arrayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(headView.width-16-15, (headViewHeight-16)/2.0f, 16, 16)];
    [headView addSubview:arrayImageView];
    [arrayImageView setImage:LEImage(@"arry_right_black")];
    if (model.expand) {
        arrayImageView.transform =     CGAffineTransformMakeRotation(90 *M_PI / 180.0);
    }
    LEWeakSelf(self)
    [headView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        model.expand=!model.expand;
        [UIView animateWithDuration:0.3f animations:^{
            [UIView performWithoutAnimation:^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                
            }];
            
            if(model.expand)
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
-(void)loadUserChargeRecordData:(BOOL)refresh complete:(void(^)(void)) completeBlock
{
    if (!completeBlock) {
      //  [self showHUD];
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
    }];
    [ZWNetwork post:@"HTTP_Post_Consum_Record" parameters:para success:^(id record)
     {
         if (completeBlock) {
             completeBlock();
         }
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSArray *itemArray = [AYConsumeModel itemsWithArray:record];
             if (itemArray.count<DEFAUT_PAGE_SIZE) {
                 self.hasMoreData = NO;
             }
             else
             {
                 self.hasMoreData = YES;
             }
             if (itemArray.count>0) {
                 if(refresh)
                 {
                     [self.userConsumArray removeAllObjects];
                     [self.sectionChargeArray removeAllObjects];
                 }
                 [self.userConsumArray safe_addObjectsFromArray:itemArray];
                 [self dealWithData];
                 [self.tableView reloadData];
                 
             }
      
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
    return self.sectionChargeArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AYCoinSectionModel *model = [self.sectionChargeArray objectAtIndex:section];
    if (model.expand) {
        return model.subItemArray.count;
    }
    return 0;
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AYCoinSectionModel *model = [self.sectionChargeArray objectAtIndex:indexPath.section];
    id object = [model.subItemArray safe_objectAtIndex:indexPath.row];
    AYMeConsumeRecoreTableViewCell *cell = LEGetCellForTable(AYMeConsumeRecoreTableViewCell.class, tableView, indexPath);
    [cell filCellWithModel:object];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    
    UIView *headView = [self createHeadViewWithSection:section];
    return headView;
    
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AYCoinSectionModel *model = [self.sectionChargeArray objectAtIndex:indexPath.section];
    id object = [model.subItemArray safe_objectAtIndex:indexPath.row];
    return  LEGetHeightForCellWithObject(AYMeConsumeRecoreTableViewCell.class, object, nil);
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //没有数据就为0
    AYCoinSectionModel *model = [self.sectionChargeArray objectAtIndex:section];
    if(!model)
    {
        return 0;
    }
    return CONSUM_RECORD_HEADVIEW_HEIGHT;
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
    return !_hasMoreData;
}

- (void) leTableChockAction : (BOOL) isRefresh complete : (void (^)(void)) completeBlock {
    [self loadUserChargeRecordData:isRefresh complete:completeBlock];
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
    [self loadUserChargeRecordData:YES complete:nil];
}

- (NSString *) uniqueIdentifier {
    return @"2";
}

- (NSString *) segmentTitle {
    return AYLocalizedString(@"消耗");
}
@end
