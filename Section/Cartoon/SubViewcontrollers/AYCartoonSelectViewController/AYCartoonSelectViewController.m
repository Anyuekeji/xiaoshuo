//
//  AYCartoonSelectViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonSelectViewController.h"
#import "AYCartoonCollectionViewCell.h"
#import "AYCartoonChapterModel.h"
#import "AYCartoonModel.h"
#import "AYCartoonContainViewController.h"
#import "AYCartoonCatlogMananger.h" //漫画目录管理

@interface AYCartoonSelectViewController ()
@property (nonatomic ,strong) NSMutableArray<AYCartoonChapterModel*> *dataArray;
@property (nonatomic ,assign) BOOL expand; //扩展模式
@property (nonatomic ,strong) UIView *maskView; //渐变遮盖层
@property (nonatomic ,strong) UICollectionViewCell *oldCell;
@property (nonatomic, strong) AYCartoonModel * cartoonModel; //数据源
@property (nonatomic, assign) NSInteger  sum_chapters; //总章节
@property (nonatomic, copy) NSString *update_time_day; //几天前更新
@property (nonatomic, assign) NSInteger  update_status; //是否完结
@property (nonatomic, assign) NSInteger update_section; //更新到几章
@property (nonatomic, strong) AYCartoonContainViewController * cartoonContainViewController; //数据源

@end

#define STATT_EXPAND_NUM 20
@implementation AYCartoonSelectViewController

-(instancetype)initWithPara:(id)para
{
    self = [super init];
    if (self) {
        self.cartoonModel = para;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureUi];
    [self loadCartoonChapterArray];
    // Do any additional setup after loading the view.
}
-(void)dealloc
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)configureUi
{
    self.title = AYLocalizedString(@"目录");
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[AYCartoonCollectionViewCell class] forCellWithReuseIdentifier:@"AYCartoonCollectionViewCell"];
    [self.collectionView registerClass:[ALCartoonSelectHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ALCartoonSelectHeadView"];
    [self.collectionView registerClass:[ALCartoonSelectFootView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ALCartoonSelectFootView"];


}
#pragma mark - db -
-(void)saveCartoonCatalog:(NSArray<AYCartoonChapterModel*>*)chaperArray
{
    NSString *qureyStr = [NSString stringWithFormat:@"cartoonId = '%@'",self.cartoonModel.cartoonID];
    NSArray<AYCartoonChapterModel*> *localChapterArray = [AYCartoonChapterModel r_query:qureyStr];
    if(localChapterArray)
    {
        [AYCartoonChapterModel r_deletes:localChapterArray];//先删除
    }
    [AYCartoonChapterModel r_saveOrUpdates:chaperArray];
}
#pragma mark - network  -
-(void)loadCartoonChapterArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    [[AYCartoonCatlogMananger shared] clearData];

    [[AYCartoonCatlogMananger shared] fetchCartoonCatlogWithCartoonId:self.cartoonModel.cartoonID refresh:(self.dataArray.count>0?NO:YES) success:^(NSArray<AYCartoonChapterModel *> * _Nonnull cartoonCatlogArray ,int count_all,NSString * update_day) {
        [self.dataArray removeAllObjects];
        if (cartoonCatlogArray.count>0) {
            [self.dataArray safe_addObjectsFromArray:cartoonCatlogArray];
            if(self.dataArray.count>STATT_EXPAND_NUM )
            {
                self.expand = NO; //不是扩展开
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.collectionView addSubview:[self createMaskView]];
                });
            }
            else
            {
                self.expand = YES;
            }
        }
//        self.sum_chapters =count_all;
//        self.update_time_day = update_day;
        
        self.update_status =count_all;
        self.update_section = [update_day intValue];
        [self.collectionView reloadData];
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}
#pragma mark - ui  -

-(UIView*)createMaskView
{
    if(!_maskView)
    {
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.contentSize.height-50-50-20, ScreenWidth, 50)];
     // maskView.backgroundColor = [UIColor clearColor];
        _maskView = maskView;
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = maskView.bounds;  // 设置显示的frame
        
        UIColor *colorOne =UIColorFromRGBA(0xffffff, 1.0f);
        UIColor *colorThree = UIColorFromRGBA(0xffffff, 0.0f);;
        UIColor *colorTwo = UIColorFromRGBA(0xffffff, 0.5f);;
        
        gradientLayer.colors = @[(id)colorOne.CGColor,(id)colorTwo.CGColor,(id)colorThree.CGColor];  // 设置渐变颜色
        //    gradientLayer.locations = @[@0.0, @0.2, @0.5];    // 颜色的起点位置，递增，并且数量跟颜色数量相等
        gradientLayer.startPoint = CGPointMake(1, 1);   //
        gradientLayer.endPoint = CGPointMake(0, 0);     //
        [maskView.layer addSublayer:gradientLayer];
        
    }
    
    return _maskView;
   
}
#pragma mark  - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!_expand) {
        return STATT_EXPAND_NUM;
    }
    return _dataArray.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma mark-  - UICollectionViewDelegate -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    AYCartoonChapterModel *chapterModel=  [_dataArray safe_objectAtIndex:indexPath.row];
    if(!chapterModel)
    {
        return;
    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (_oldCell && ![_oldCell isEqual:cell]) {
        _oldCell.selected = NO;
    }
    else
    {
        cell.selected = YES;
        _oldCell = cell;
    }
    chapterModel.startChapterIndex = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    chapterModel.cartoontTitle = self.cartoonModel.cartoonTitle;
   NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:chapterModel,@"chapter",self.cartoonModel,@"cartoon", nil];
    [ZWREventsManager sendViewControllerEvent:kEventAYCartoonReadPageViewController parameters:para];
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AYCartoonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AYCartoonCollectionViewCell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
   AYCartoonChapterModel *model = [_dataArray safe_objectAtIndex:indexPath.row];
    
    [cell filCellWithModel:model];
    return cell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((ScreenWidth-30-30)/4.0f, 40);
    
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        ALCartoonSelectHeadView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ALCartoonSelectHeadView" forIndexPath:indexPath];
        [header setBackgroundColor:[UIColor clearColor]];
        //NSString *title = [NSString stringWithFormat:AYLocalizedString(@"  全部章节(%d)   %@更新"),_sum_chapters,_update_time_day];
        
        NSString *update_section = (self.update_status==1)?@"":[NSString stringWithFormat:AYLocalizedString(@"(更新%d章节)"),self.update_section];
        
        NSString *title = [NSString stringWithFormat:@"%@ %@",((self.update_status==1)?AYLocalizedString(@"已完结"):AYLocalizedString(@"连载中")),update_section];
        [header filCellWithModel:title];
        return header;
        
    }
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        if (_dataArray.count>STATT_EXPAND_NUM) {
            ALCartoonSelectFootView *footter = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ALCartoonSelectFootView" forIndexPath:indexPath];
            footter.ayClickFootAction = ^(BOOL expand) {
                self.expand = expand;
                [self.collectionView reloadData];
                if (!expand) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.collectionView addSubview:[self createMaskView]];
                    });
                }
                else
                {
                    if (self.maskView) {
                        [self.maskView removeFromSuperview];
                        self.maskView = nil;
                    }
                }
            };
            return footter;
        }
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(self.view.bounds.size.width-30, 50);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (_dataArray.count>STATT_EXPAND_NUM) {
        return CGSizeMake(self.view.bounds.size.width, 50);
    }
    return CGSizeMake(0, 0);
}
//这个是两行cell之间的间距（上下行cell的间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 15,10, 15);//分别为上、左、下、右
}
#pragma mark- scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self cartoonContainViewController]) {
        [self.cartoonContainViewController subScrollViewDidScroll:scrollView];
    }
}
#pragma mark- getter and setter -

-(AYCartoonContainViewController*)cartoonContainViewController
{
    if (!_cartoonContainViewController)
    {
        UIViewController *nextViewController = self.parentViewController;
        while (nextViewController) {
            if ([nextViewController isKindOfClass:AYCartoonContainViewController.class]) {
                return (AYCartoonContainViewController*)nextViewController;
            }
            nextViewController = nextViewController.parentViewController;
        }
    }
    return _cartoonContainViewController;
}
#pragma mark - ZWR2SegmentViewControllerProtocol -

+ (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewControllerWithSegmentRegisterItem : (id) object segmentItem : (ZWR2SegmentItem *) segmentItem {
    return [[self alloc] initWithPara:object];
}
#pragma mark - ZWRChainReactionProtocol
/**当前选中状态又重新选择了这个tabbar，联动效应事件 */
- (void) zwrChainReactionEventTabBarDidReClickAfterAppear {
    [self.collectionView refreshing];
}

#pragma mark - ZWRSegmentReuseProtocol
- (void) segmentRecivedMemoryWarning {
    
}
- (void) segmentViewWillAppear {
    if ([self cartoonContainViewController]) {
        [self.cartoonContainViewController switchScrollView:self.collectionView];
    }
}
- (void) segmentViewWillDisappear {
    
}
/**
 *  当进入显示栏位的时候将会调用此方法，可实现相关逻辑
 */
- (void) segmentDidLoadViewController {
    //加载列表数据
   // [[self collectionView] launchRefreshing];
}

- (NSString *) uniqueIdentifier {
    return @"1";
}

- (NSString *) segmentTitle {
    return AYLocalizedString(@"选集");
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters && [parameters isKindOfClass:AYCartoonModel.class]) {
        return YES;
    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYCartoonSelectViewController alloc] initWithPara:parameters];
}

@end
