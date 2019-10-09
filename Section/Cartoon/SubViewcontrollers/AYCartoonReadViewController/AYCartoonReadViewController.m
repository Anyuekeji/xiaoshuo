//
//  AYCartoonReadViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonReadViewController.h"
#import "AYCartoonReadViewModel.h"
#import "AYCartoonDetailTableViewCell.h"
#import <UIImageView+YYWebImage.h>
#import "AYCartoonChapterContentModel.h" //章节内容model
#import "AYFictionDetailTableViewCell.h"
#import "UIScrollView+GestureRecognizser.h"
#import "ZWCacheHelper.h"
#import "AYChargeView.h" //提示付费和充值view
#import "AYCartoonImageDownloadManager.h"
#import <YYKit/YYKit.h>
#import <SDWebImage/SDImageCache.h>
#import "AYAdmobManager.h" //admob 广告管理
#import "AYReadAleartVIew.h"
@interface AYCartoonReadViewController ()
{
    //dispatch_queue_t _queue;
    //dispatch_semaphore_t _semaphore;
}
@property (nonatomic, readwrite, strong) AYCartoonReadViewModel * viewModel; //数据源
@property (nonatomic, strong) NSMutableDictionary * heightDic; //数据源
@property (nonatomic, strong) NSMutableDictionary * imageUrlDic; //数据源
@property (nonatomic, strong) NSMutableDictionary * cellDic; //数据源
@property (nonatomic, assign) BOOL willNextSwitch; //是否将要切换章节
@property (nonatomic, assign) BOOL willPreSwitch; //是否将要切换章节
@end

@implementation AYCartoonReadViewController
-(instancetype)initWithChapterModel:(AYCartoonChapterContentModel*)chapterModel
{
    self = [super init];
    if (self)
    {
        self.cartoonDetailModel = chapterModel;
    }
    return self;
}
-(void)dealloc
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateUI];
    [self configurateData];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
}
#pragma mark - Init
- (void) configurateTableView
{
    _AYFictionDetailCellsRegisterToTable(self.tableView, 2);
   LERegisterCellForTable(AYCartoonChapterContentTableViewCell.class, self.tableView);
   // self.tableView.showsVerticalScrollIndicator =NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   // self.tableView.bounces = NO;
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void) configurateData {
    _heightDic = [NSMutableDictionary new];
    _imageUrlDic = [NSMutableDictionary new];
    _cellDic = [NSMutableDictionary new];

//    _queue = dispatch_queue_create("com.lyp.queue", DISPATCH_QUEUE_CONCURRENT);
//    _semaphore = dispatch_semaphore_create(5);
    
    self.viewModel = [AYCartoonReadViewModel viewModelWithViewController:self];
    [_viewModel setCartoonDetailModel:_cartoonDetailModel];
    [self.tableView reloadData];
}
- (void) configurateUI
{
    self.view.backgroundColor = RGB(255, 255, 255);
    [self configurateTableView];
}

#pragma mark - private -
-(void) loadImageWithModel:(AYCartoonChapterImageUrlModel*)imageModel cell:(AYCartoonChapterContentTableViewCell*)contentCell indexPath:(NSIndexPath*)indexPath
{
    @autoreleasepool {
        LEWeakSelf(contentCell)
        NSString *imageUrl = [NSString stringWithFormat:@"%@",imageModel.cartoonImageUrl];
        [contentCell.contentImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:LEImage(@"ay_defalut_image") options:kNilOptions  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            LEStrongSelf(contentCell)
            dispatch_async(dispatch_get_main_queue(), ^{
                //LEStrongSelf(contentCell)
                contentCell.progressView.loadingProgress = receivedSize*1.0f/expectedSize*1.0f;
            });
            
        }  transform:nil  completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            LEStrongSelf(contentCell)
            if (stage ==YYWebImageStageFinished )
            {
               // dispatch_semaphore_signal(self->_semaphore);
                dispatch_async(dispatch_get_main_queue(), ^{
                    contentCell.progressView.loadingProgress=0;
                    contentCell.progressView.hidden =YES;
                    NSNumber *cellheight = @((ScreenWidth* image.size.height)/ image.size.width);
                    imageModel.cartoonImageHeight = cellheight;
                    [imageModel r_saveOrUpdate];
                    [self reloadRows:indexPath];
                });
                
            }
            
        }];
    }
}
#pragma mark - network -

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AYCartoonChapterImageUrlModel *object = [self.viewModel objectForIndexPath:indexPath];
    if (indexPath.section ==0)
    {
        AYCartoonChapterContentTableViewCell *cell = LEGetCellForTable(AYCartoonChapterContentTableViewCell.class, tableView, indexPath);

        {
            UIImage *catcheImage =[[AYCartoonImageDownloadManager shared] imageInCatche:object.cartoonImageUrl];
            if(catcheImage )
            {
                cell.contentImageView.image =catcheImage;
                cell.progressView.hidden =YES;
            }
            else
            {
                cell.progressView.hidden = NO;
                cell.progressView.loadingProgress = 0;
                cell.contentImageView.image =LEImage(@"ws_register_example_company");
                [self loadImageWithModel:object cell:cell indexPath:indexPath];
            }

        }
        return cell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = _AYFictionDetailGetCellByItem(object, 2, tableView, indexPath, ^(UITableViewCell *fetchCell)
        {
            if ([fetchCell isKindOfClass:AYCartoonSwitchChapterTableViewCell.class])
            {
                AYCartoonSwitchChapterTableViewCell *cartoonSwitchChapterTableViewCell =(AYCartoonSwitchChapterTableViewCell*)fetchCell;
                LEWeakSelf(self) cartoonSwitchChapterTableViewCell.aySwitchChapterClicked = ^(BOOL nextChapter) {
                    LEStrongSelf(self)
                    if (nextChapter)
                    {
                        if([self.cartoondDelegate respondsToSelector:@selector(nextChapterInReadViewController)])
                        {
                            [self.cartoondDelegate nextChapterInReadViewController];
                        }
                    }
                    else
                    {
                        if([self.cartoondDelegate respondsToSelector:@selector(preChapterInReadViewController)])
                        {
                            [self.cartoondDelegate preChapterInReadViewController];
                        }
                    }
                };

          
            }
        });
        return cell;
    }
    return nil;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        NSObject *object = [self.viewModel objectForIndexPath:indexPath];
    if (indexPath.section ==0)
    {
        AYCartoonChapterImageUrlModel *imageUrlModel =(AYCartoonChapterImageUrlModel*) object;

        if (imageUrlModel.cartoonImageHeight) {
            double cellHeight =[imageUrlModel.cartoonImageHeight doubleValue];
            if (cellHeight>0) {
                return cellHeight;
            }
        }
        CGFloat cellHeight = (5.0f/4.0f)*ScreenWidth;
        return cellHeight;
    }
    else
    {
        CGFloat height = _AYFictionDetailCellHeightByItem(object, indexPath, 2);
        return height;
    }
  
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) scrollViewDidScroll : (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    if([self.cartoondDelegate respondsToSelector:@selector(cartoonReadScrollViewDidScroll:)])
    {
        [self.cartoondDelegate cartoonReadScrollViewDidScroll:scrollView];
    }
    
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    if (contentOffsetY<-60 && !_willPreSwitch)//向上翻页
    {
        if([self.cartoondDelegate respondsToSelector:@selector(preChapterInReadViewController)])
        {
          //  AYLog(@"read pre");
            _willPreSwitch = YES;
            [self.cartoondDelegate preChapterInReadViewController];
        }
    }
    else if (contentOffsetY>self.tableView.contentSize.height-self.tableView.height+50 && !_willNextSwitch)//向下翻页
    {
        //AYLog(@"read next");
        if([self.cartoondDelegate respondsToSelector:@selector(nextChapterInReadViewController)])
        {
            _willNextSwitch = YES;
            [self.cartoondDelegate nextChapterInReadViewController];
        }
    }
}

#pragma mark - public -
-(void)reloadRows:(NSIndexPath*)indexPath
{
    AYLog(@"reloadRows %ld",(long)indexPath.row);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    @try{
        NSArray *visableIndexPath = [self.tableView indexPathsForVisibleRows];
         NSIndexPath* loadIndexPath= indexPath;
        if ([visableIndexPath containsObject:loadIndexPath])
        {
            [self.tableView  reloadRowsAtIndexPaths:[NSArray arrayWithObjects:loadIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    @catch (NSException *exception){
        
    }
    [CATransaction commit];
}

#pragma mark - gettet and setter -
-(void)setCartoonChapterModel:(AYCartoonChapterModel *)cartoonChapterModel
{
    _cartoonChapterModel = cartoonChapterModel;
    if(self.showAd)
    {
        self.tableView.scrollEnabled =NO;
        [self showAdVideoUnlockView];
    }
    else
    {
        [self shareBuyCoinView];
    }
}
-(void)shareBuyCoinView
{
    if ([self.cartoonChapterModel.needMoney integerValue]>0 && ![self.cartoonChapterModel.unlock boolValue])
    {
        [AYChargeView showChargeViewInView:self.view fiction:NO  chapterModel:[self.cartoonChapterModel modelToFictionModel] chargeReslut:^(CYFictionChapterModel * _Nonnull chapterModel, AYChargeView * _Nonnull chargeView, BOOL suceess) {
            if(suceess)
            {
                self.tableView.scrollEnabled =YES;
                [UIView animateWithDuration:0.3 animations:^{
                    if (chargeView.tag ==AD_CHARGE_TAG) {
                        chargeView.superview.alpha =0;
                    }
                    else
                    {
                        chargeView.alpha =0;
                    }
                    [self.view viewWithTag:CHARGE_MASK_TAG].alpha = 0;
                } completion:^(BOOL finished) {
                    if (chargeView.tag ==AD_CHARGE_TAG) {
                        [chargeView.superview removeFromSuperview];
                    }
                    else
                    {
                        [chargeView removeFromSuperview];
                    }
                    [[self.view viewWithTag:CHARGE_MASK_TAG] removeFromSuperview];
                }];
                if (self.chargeResultAction) {
                    self.chargeResultAction(chapterModel, suceess);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartoonAddToRackEvents object:self.cartoonChapterModel.cartoonId];
            }
        }];
        self.tableView.scrollEnabled =NO;
    }

}

-(void)showAdVideoUnlockView
{
    NSString *tipStr =  [NSString stringWithFormat:AYLocalizedString(@"每天可免费阅读%d个章节 继续阅读需要解锁"),[AYGlobleConfig shared].fictionMaxReadSectionNum];
    [AYReadAleartVIew shareReadAleartViewWithTitle:tipStr okActionTitle:AYLocalizedString(@"看视频解锁该章节") okCancle:NO cancleActionTitle:AYLocalizedString(@"不想看广告") parentView:self.view okBlock:^(bool ok){
        if(ok)
        {
            [[AYAdmobManager shared]  showGADRewardBasedVideoAd:^(id  _Nonnull obj) {
                self.tableView.scrollEnabled =YES;
                [AYReadAleartVIew removeReadAleartView];
            } controller:self.parentViewController];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultFreeBookCoinUnlock];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self shareBuyCoinView];
        }
    }];
    [[AYAdmobManager shared]  showGADRewardBasedVideoAd:^(id  _Nonnull obj) {
        [AYReadAleartVIew removeReadAleartView];
        self.tableView.scrollEnabled =YES;
        
    } controller:self.parentViewController];
}
-(void)showUnlockTypeView:(BOOL)advetise
{
    if (advetise) {
        [AYChargeView removeChargeView];
        [self showAdVideoUnlockView];
    }
    else
    {
        [AYReadAleartVIew removeReadAleartView];
        [self shareBuyCoinView];
    }
}
@end
