//
//  AYBookrackViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBookrackViewController.h"
#import "AYBookrackCollectionViewCell.h"
#import "UIViewController+AYNavViewController.h"
#import "UIView+YYAdd.h"
#import "AYSignInView.h" //签到view
#import "AYFictionModel.h" //小说model
#import "AYBookModel.h" //书本model
#import "AYCartoonChapterModel.h" //漫画章节
#import "AYSignManager.h"
#import "AYCartoonModel.h"
#import "AYShareManager.h"
#import "ZWDeviceSupport.h"
#import "AYAPPUpdateModel.h" //升级modle
#import "AYBookRackManager.h" //书架管理
#import "AYFuctionReadViewController.h" //小说阅读界面
#import "LETransitionNavigationDelegate.h"

@interface AYBookrackViewController ()
@property(nonatomic,strong)NSMutableArray<AYBookModel*>  *bookList;
@property(nonatomic,strong)NSMutableArray<AYBookModel*>  *willDeleteBookList; //将要删除的小说
//@property(nonatomic,strong)NSMutableArray<AYBookModel*>  *willDeleteCartoonBookList; //将要删除的漫画
@property(nonatomic,strong)UIView  *deleteView;//删除view
@property(nonatomic,strong)UILabel  *deleteLable;//删除Lable
@property(nonatomic,assign)BOOL  edit;//是否是编辑状态
@property(nonatomic,strong)UIView  *loginTipView;//登录提示view
@property (nonatomic, strong) LETransitionNavigationDelegate *transitionDelegate;
@property(nonatomic,assign) NSInteger  currentClickIndex;//点击的book索引
@property(nonatomic,assign) CGRect firstCellRect;
@end

@implementation AYBookrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUi];
    [self configureData];
    [self loadUserBookrack:nil refresh:YES];
    [self configureNotification];
    [self checkHasNewVersion];

    if (![AYUserManager isUserLogin]) {
        [self.view addSubview:[self loginTipView]];
        self.collectionTopConstraint.constant = [self loginTipView].height+ 20.0f;
    }
    else
    {
        [[AYSignManager shared] loadAllData:^{
            
        } failure:^(NSString * _Nonnull errorString) {
            
        }];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigation];
  self.parentViewController.parentViewController.title = AYLocalizedString(@"书架");
    if (self.bookList && self.bookList.count>0)
    {
        [self.collectionView reloadData];
    }
    self.view.height = self.parentViewController.view.height-Height_TapBar;

}
-(void)viewDidAppear:(BOOL)animated
{


}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_bookList.count>=2)
    {
        [AYBookModel r_deleteAll];
        NSArray *catcheArray = [_bookList subarrayWithRange:NSMakeRange(0, _bookList.count-1)]; //去除最后一个空行
        [AYBookModel r_saveOrUpdates:catcheArray];
    }
    //self.parentViewController.parentViewController.navigationItem.rightBarButtonItem = nil;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - configure -
-(void)configureUi
{
    self.currentClickIndex= -12;
    self.view.backgroundColor = UIColorFromRGB(0xf7f7f7);
    [self.collectionView registerClass:[AYBookrackCollectionViewCell class] forCellWithReuseIdentifier:@"AYBookrackCollectionViewCell"];
    //防止添加书架cell，因为复用被图片覆盖
     [self.collectionView registerClass:[AYBookrackCollectionViewCell class] forCellWithReuseIdentifier:@"AYBookrackCollectionViewCellEmpty"];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionTopConstraint.constant = 10.0f;
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signInBtn setBackgroundImage:LEImage(@"book_signin") forState:UIControlStateNormal];
    signInBtn.frame = CGRectMake(ScreenWidth-60-30, ScreenHeight-70-60-80-[AYUtitle al_safeAreaInset:self.view].bottom-STATUS_BAR_HEIGHT-[AYUtitle al_safeAreaInset:self.view].top-(_ZWIsIPhoneXSeries()?50:0), 70, 70);
    [signInBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    signInBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    signInBtn.titleLabel.numberOfLines = 0;
    signInBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [signInBtn setTitle:AYLocalizedString(@"签到") forState:UIControlStateNormal];
    [self.view addSubview:signInBtn];
    LEWeakSelf(self)
    [signInBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if (self.edit) {
            return ;
        }
        UITabBarController *tabCon = self.tabBarController;
        tabCon.selectedIndex = 2;
    }];
    [self.view bringSubviewToFront:signInBtn];
}
-(void)configureData
{
    _bookList = [NSMutableArray new];
    _willDeleteBookList = [NSMutableArray new];
   // _willDeleteCartoonBookList = [NSMutableArray new];

}
-(void)configureNavigation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.parentViewController.parentViewController.navigationItem.rightBarButtonItem) {
            [self.parentViewController.parentViewController setRightBarButtonItem:[self barButtonItemWithTitle:(self.edit?AYLocalizedString(@"取消"):   AYLocalizedString(@"编辑")) normalColor:RGB(118, 118, 118) highlightColor:RGB(118, 118, 118) normalImage:(self.edit?nil:  LEImage(@"book_edit")) highlightImage:(self.edit?nil:LEImage(@"book_edit")) leftBarItem:NO target:self action:@selector(handleEdit)]];
        }
    });
}

-(void)configureNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSuccess:) name:kNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshBookrack) name:kNotificationAddBookRackSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //小说加入书架
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBookToBookRack:) name:kNotificationFictionAddToRackEvents object:nil];
    
    //小说漫画书架
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCartoonToBookRack:) name:kNotificationCartoonAddToRackEvents object:nil];
}
#pragma mark - network -
-(void)loadUserBookrack:(void(^)(void)) completeBlock refresh:(BOOL)refresh
{
    if (!completeBlock) {
        NSArray* catcheArray =  [AYBookModel r_allObjects];
        if (catcheArray && catcheArray.count>0) {
            [self.bookList removeAllObjects];
            //[self.bookList addObjectsFromArray:catcheArray];
            [self handelWithSeverData:(NSMutableArray*)catcheArray];
            AYBookModel *bookModel = [AYBookModel new];
            [self.bookList safe_addObject:bookModel];
            [self.collectionView reloadData];
        }
    }
    if (refresh) {
        [self showHUD];
    }
    if(![AYUserManager isUserLogin])
    {
         [ZWNetwork post:@"HTTP_Post_Bookrack_Rcommend" parameters:nil success:^(id record)
         {
             if (!completeBlock) {
                 [self hideHUD];
             }
             [self.bookList removeAllObjects];
             if ([record isKindOfClass:NSArray.class])
             {
                 NSMutableArray<AYBookModel*> *itemArray = (NSMutableArray*)[AYBookModel itemsWithArray:record];
                 [self handelWithSeverData:itemArray];
                 AYBookModel *bookModel = [AYBookModel new];
                 [self.bookList safe_addObject:bookModel];
                 [[self collectionView] reloadData];
                 [self updateAnimationFrame];
             }
             else
             {
                 AYBookModel *bookModel = [AYBookModel new];
                 [self.bookList safe_addObject:bookModel];
                 [[self collectionView] reloadData];
             }
             if (completeBlock)
             {
                 completeBlock();
             }
         } failure:^(LEServiceError type, NSError *error) {
             if (!completeBlock) {
                 [self hideHUD];
             }
             occasionalHint([error localizedDescription]);
             if (self.bookList.count<=0) {
                 AYBookModel *bookModel = [AYBookModel new];
                 [self.bookList safe_addObject:bookModel];
                 [self.collectionView reloadData];
             }
             if (completeBlock) {
                 completeBlock();
             }
         }];
    }
    else
    {
        NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
            if([AYUserManager userItem])
            {
                [params addValue:[AYUserManager userId] forKey:@"users_id"];
            }
            else
            {
                [params addValue:@"" forKey:@"users_id"];
            }
        }];
        [ZWNetwork post:@"HTTP_Post_Bookrack" parameters:para success:^(id record)
         {
             if (!completeBlock) {
                 [self hideHUD];
             }
             [self.bookList removeAllObjects];
             if ([record isKindOfClass:NSArray.class]) {
                 NSMutableArray<AYBookModel*> *itemArray = (NSMutableArray*)[AYBookModel itemsWithArray:record];
                 [self handelWithSeverData:itemArray];
                AYBookModel *bookModel = [AYBookModel new];
                [self.bookList safe_addObject:bookModel];
                [[self collectionView] reloadData];
                 [self updateAnimationFrame];

             }
             else{
                 AYBookModel *bookModel = [AYBookModel new];
                 [self.bookList safe_addObject:bookModel];
                 [[self collectionView] reloadData];
             }
             if (completeBlock) {
                 completeBlock();
             }
         } failure:^(LEServiceError type, NSError *error) {
             if (!completeBlock) {
                 [self hideHUD];
             }
             occasionalHint([error localizedDescription]);
             if (self.bookList.count<=0) {
                 AYBookModel *bookModel = [AYBookModel new];
                 [self.bookList safe_addObject:bookModel];
                 [self.collectionView reloadData];
             }
             if (completeBlock) {
                 completeBlock();
             }
         }];
    }
}
-(void)deleteBookFromRack
{
    NSMutableArray<AYBookModel*> *willServerDelete = [NSMutableArray new]; //服务器要删除的小说book
    NSMutableArray<AYBookModel*> *willCartoonServerDelete = [NSMutableArray new]; //服务器要删除漫画的book
    NSMutableArray<NSNumber*> *willRecommentDelete = [NSMutableArray new]; //本地存储推荐的书籍的bookid 列表
    
    [_willDeleteBookList enumerateObjectsUsingBlock:^(AYBookModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj.isgroom boolValue] && [obj.type intValue]==1) //不是推荐,且是小说给服务器删除
        {
            [willServerDelete safe_addObject:obj.bookID];
        }
        else if(![obj.isgroom boolValue] && [obj.type intValue]==2) //不是推荐,且是漫画给服务器删除
        {
            [willCartoonServerDelete safe_addObject:obj.bookID];
        }
        else //是推荐本地删除
        {
            [willRecommentDelete safe_addObject:[NSString stringWithFormat:@"%@_%@_%@",obj.bookID,[obj.type stringValue],([AYUserManager userId]?[AYUserManager userId]:@"")]];
            //只有通过bookid和type两个参数才能确定唯一一本书，小说type为1；
        }
    }];
    if (![AYUserManager isUserLogin]) {
        [self.bookList removeObjectsInArray:self.willDeleteBookList];
        [self.collectionView reloadData];
        [self updateRecommendLocalBooklist:willRecommentDelete];
        [self.willDeleteBookList removeAllObjects];
        self.deleteLable.text = AYLocalizedString(@"删除");
        return;
    }
    NSString *willDeleteStr = [willServerDelete componentsJoinedByString:@"."];
    NSString *willCartoonDeleteStr = [willCartoonServerDelete componentsJoinedByString:@"."];
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:willDeleteStr forKey:@"book_id"]; //删除的小说id
        [params addValue:willCartoonDeleteStr forKey:@"cartoon_id"];//删除的漫画id
    }];
    [ZWNetwork post:@"HTTP_Post_Bookrack _Delete" parameters:para success:^(id record)
     {
         [self.bookList removeObjectsInArray:self.willDeleteBookList];
         [self.collectionView reloadData];
         [self updateRecommendLocalBooklist:willRecommentDelete];
         [self.willDeleteBookList removeAllObjects];
         self.deleteLable.text = AYLocalizedString(@"删除");

     } failure:^(LEServiceError type, NSError *error) {
             [self hideHUD];
              occasionalHint([error localizedDescription]);
     }];
}
#pragma mark - LETableView Configurate
- (LERefreshControl *) topRefreshControl {
    return [ZWTopRefreshControl control];
}
//- (LERefreshControl *) bottomRefreshControl {
//    return [ZWBottomRefreshControl controlWithAdsorb];
//}
#pragma mark - LELazyLoadDelegate
- (void) leCollectionRefreshChokeAction : (void(^)(void)) completeBlock
{
    if (_edit) {
        if (completeBlock) {
            completeBlock();
        }
        return;
    }
    [self loadUserBookrack:completeBlock refresh:NO];
}

- (void) leCollectionLoadMoreChokeAction : (void(^)(void)) completeBlock
{
    if (_edit) {
        if (completeBlock) {
            completeBlock();
        }
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completeBlock) {
            completeBlock();
        }
    });
}
#pragma mark  - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _bookList.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma  - UICollectionViewDelegate -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.edit)
    {
        AYBookrackCollectionViewCell *cell  =(AYBookrackCollectionViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
        if(indexPath.row == self.bookList.count-1)
        {
            return;
        }
        
        if (cell) {
            cell.willDelete = !cell.willDelete;
            if (cell.willDelete) {
                [_willDeleteBookList safe_addObject:[_bookList safe_objectAtIndex:indexPath.row]];
            }
            else
            {
                [_willDeleteBookList safe_removeObject:[_bookList safe_objectAtIndex:indexPath.row]];
            }
            if (_willDeleteBookList.count>0) {
                _deleteLable.text = [NSString stringWithFormat:@"%@(%d)",AYLocalizedString(@"删除"),(int)_willDeleteBookList.count];
            }
            else
            {
                _deleteLable.text = AYLocalizedString(@"删除");
            }
        }
    }
    else
    {
        AYBookModel *bookModle = [self.bookList safe_objectAtIndex:indexPath.row];
        if (!bookModle.bookID && !bookModle.bookTitle)//点击了添加书到书架
        {
            UITabBarController *tab = [self tabBarController];
            if (tab) {
                [tab setSelectedIndex:1];
            }
            return;
        }
        if([bookModle.type integerValue] ==2)//漫画
        {
            AYCartoonChapterModel *cartoonChapterModel = [AYCartoonChapterModel new];
            cartoonChapterModel.cartoonId = bookModle.bookID;
            cartoonChapterModel.cartoontTitle = bookModle.bookTitle;
            AYCartoonModel *cartoonModel = [AYCartoonModel new];
            cartoonModel.cartoonTitle =bookModle.bookTitle;
        cartoonModel.cartoonImageUrl=bookModle.bookImageUrl;
            cartoonModel.cartoonID =bookModle.bookID;
            cartoonModel.cartoonIntroduce =bookModle.bookIntroduce;
            cartoonModel.cartoonImageUrl = bookModle.bookImageUrl;
            NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:cartoonChapterModel,@"chapter",cartoonModel,@"cartoon", nil];
            [ZWREventsManager sendViewControllerEvent:kEventAYCartoonReadPageViewController parameters:para];
        }
        else
        {
            self.currentClickIndex = indexPath.row;
            AYFictionModel *fictionModel = [AYFictionModel new];
            fictionModel.fictionID = bookModle.bookID;
            fictionModel.fictionTitle = bookModle.bookTitle;
            fictionModel.fictionIntroduce = bookModle.bookIntroduce;
               AYBookrackCollectionViewCell *cell  =(AYBookrackCollectionViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
           // [ZWREventsManager sendViewControllerEvent:kEventAYFuctionReadViewController parameters:fictionModel];
            AYFuctionReadViewController *readController = [[AYFuctionReadViewController alloc] initWithPara:fictionModel];
            LEWeakSelf(self)
            LEWeakSelf(readController)
            readController.updateBookOpenCover = ^{
                LEStrongSelf(self)
                LEStrongSelf(readController)
                UIImage *contentImage = [AYUtitle imageWithUIView:readController.view];
                [self.transitionDelegate setFlipImg:contentImage];
            };

            self.navigationController.delegate = (id<UINavigationControllerDelegate>)self.transitionDelegate;
            UIImage *contentImage = [AYUtitle imageWithUIView:readController.view];
            [self.transitionDelegate setFlipImg:contentImage];
            CGRect originRect = [cell convertRect:cell.bookCoverImageView.frame toView: self.view];
            
            
            [self.transitionDelegate setTransitionBeforeImgFrame:CGRectMake(originRect.origin.x, originRect.origin.y+Height_TopBar, originRect.size.width, originRect.size.height)];
            [self.transitionDelegate setTransitionImg:cell.bookCoverImageView.image?cell.bookCoverImageView.image :LEImage(@"ws_register_example_company")];
            [self.navigationController pushViewController:readController animated:YES];
        }
    }
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AYBookrackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AYBookrackCollectionViewCell" forIndexPath:indexPath];
   AYBookModel *bookModel = [_bookList safe_objectAtIndex:indexPath.row];

    if(bookModel.bookTitle && bookModel.bookImageUrl)
    {
        cell.edit =_edit;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AYBookrackCollectionViewCellEmpty" forIndexPath:indexPath];
        cell.edit = NO;
    }
     [cell filCellWithModel:bookModel];
    return cell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWidth = CELL_WIDTH;
    return CGSizeMake(imageWidth, [AYBookrackCollectionViewCell cellHeight]);
    
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);//分别为上、左、下、右
}
//这个是两行cell之间的间距（上下行cell的间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}
#pragma mark - db -
//是否已在书架
-(BOOL)bookIsAddToBookRack:(NSString*)bookId
{
    for (AYBookModel* bookModel in self.bookList) {
        if ([bookModel.bookID isEqualToString:bookId]) {
            if ([bookModel.isgroom boolValue]) {
                return NO;
            }
            return YES;
        }
    }
    return NO;
    
}
//变为不是推荐状态
-(void)changeLocalBookToUnRecommentd:(NSString*)bookId
{
    for (AYBookModel* bookModel in self.bookList) {
        if ([bookModel.bookID isEqualToString:bookId]) {
            if ([bookModel.isgroom boolValue]) {
                bookModel.isgroom =@(NO);
            }
        }
    }
}
#pragma mark - private -
-(void)updateRecommendLocalBooklist:(NSArray*)booklist
{
    NSMutableArray *willCatchArray = [NSMutableArray new];
    NSMutableArray *catcheDeleteRecommendBookIdList = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultRecommmentBookID];
    if (catcheDeleteRecommendBookIdList) {
        [willCatchArray safe_addObjectsFromArray:catcheDeleteRecommendBookIdList];
    }
    [willCatchArray safe_addObjectsFromArray:booklist];
    [[NSUserDefaults standardUserDefaults] setObject:willCatchArray forKey:kUserDefaultRecommmentBookID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)handelWithSeverData:(NSMutableArray<AYBookModel*> *)serverBookList
{
    NSMutableArray *catcheDeleteRecommendBookIdList = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultRecommmentBookID];
    if (!catcheDeleteRecommendBookIdList) {
        [self.bookList addObjectsFromArray:serverBookList];
        return;
    }
    NSMutableArray<AYBookModel*> *willShowBookList = [NSMutableArray new]; //本地保存的被删除过的推荐的bookid
    [serverBookList enumerateObjectsUsingBlock:^(AYBookModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.isgroom boolValue]) {
            [willShowBookList safe_addObject:obj]; //不是推荐的就显示
        }
        else
        {
            NSString *bookKey = [NSString stringWithFormat:@"%@_%@_%@",obj.bookID,[obj.type stringValue],([AYUserManager userId]?[AYUserManager userId]:@"")];//只有通过bookid和type 参数才能确定唯一一本书，小说type为1；
                if(![catcheDeleteRecommendBookIdList containsObject:bookKey]) //是推荐的看是否在本地保存已删除的id列表内
                {
                    [willShowBookList safe_addObject:obj];
                }
           }
    }];
    [self.bookList addObjectsFromArray:willShowBookList];
}
-(void)updateAnimationFrame
{
    if (_currentClickIndex<0) {
        return;
    }
    AYBookModel *bookModle = [self.bookList safe_objectAtIndex:_currentClickIndex];
    if (bookModle)
    {
        CGFloat imageWidth = CELL_WIDTH;
        CGFloat imageHeight = imageWidth*(142.0f/100.0f);
        //推荐阅读过的会放到最前面 所以要改变位置
        if (![bookModle.isgroom boolValue] && _currentClickIndex>0)
        {
            [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
               AYBookrackCollectionViewCell *firstCell = (AYBookrackCollectionViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            CGRect first_originRect ;
  
            first_originRect = CGRectMake(10, 10, imageWidth, imageHeight);
//            if(!firstCell)
//            {
//                CGFloat imageWidth = CELL_WIDTH;
//                CGFloat imageHeight = imageWidth*(142.0f/100.0f);
//                first_originRect = CGRectMake(10, 10, imageWidth, imageHeight);
//            }
////                CGRect first_originRect = [self.collectionView convertRect:firstCell.frame toView:self.view];
//            else
//            {
//                            first_originRect = [firstCell convertRect:firstCell.bookCoverImageView.frame toView: self.view];
//            }
//
//               // CGRect first_originRect = self.firstCellRect;
            [self.transitionDelegate setTransitionBeforeImgFrame:CGRectMake(first_originRect.origin.x, first_originRect.origin.y+Height_TopBar, first_originRect.size.width, first_originRect.size.height)];
        }
        else
        {
            
              AYBookrackCollectionViewCell *after_cell = (AYBookrackCollectionViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentClickIndex inSection:0]];
                CGRect after_originRect = [self.collectionView convertRect:after_cell.frame toView: self.view];
                [self.transitionDelegate setTransitionBeforeImgFrame:CGRectMake(after_originRect.origin.x, after_originRect.origin.y+Height_TopBar, imageWidth, imageHeight)];
        }

        _currentClickIndex =-12;
    }

}
#pragma mark - ui -
-(void)creatUpdateAlertController:(AYAPPUpdateModel*)updateModel
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:(updateModel.upgrade_point.length>0?updateModel.upgrade_point:AYLocalizedString(@"发现新版本，是否更新？")) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:AYLocalizedString(@"更新") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  if ([updateModel.types integerValue]==2)
                                  {
                                      //强制更新不让消失
                                      [self creatUpdateAlertController:updateModel];

                                  }
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:(updateModel.apk_url?updateModel.apk_url:@"https://itunes.apple.com/cn/app/id1440719422?mt=8")]];
                              }];
    [alert addAction:action1];
    if ([updateModel.types integerValue]!=2) {
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:AYLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
        [alert addAction:action2];
    }

    
    [self presentViewController:alert animated:YES completion:nil];
    
}
-(void)creatDeleteAlertController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:AYLocalizedString(@"确认删除所选中的作品，删除后不能恢复") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:AYLocalizedString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  [self deleteBookFromRack];
                              }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:AYLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark - event handle -
-(void)handleEdit
{
    _edit = !_edit;

    [self.collectionView reloadData];
    UIBarButtonItem *rightBarItem = self.parentViewController.parentViewController.navigationItem.rightBarButtonItem;
    UIButton *rightBtn = (UIButton*)rightBarItem.customView;
    rightBtn.selected = !rightBtn.selected;
    if(_edit)
    {
        [self.parentViewController.view addSubview:[self deleteView]];
        self.deleteView.alpha = 0.2f;
        [UIView animateWithDuration:0.1f animations:^{
            self.deleteView.alpha = 1.0f;
            [[self deleteView] setTop:ScreenHeight-44-50-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0)-STATUS_BAR_HEIGHT-[AYUtitle al_safeAreaInset:self.view].top-[AYUtitle al_safeAreaInset:self.view].bottom];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [rightBtn setTitle:AYLocalizedString(@"取消") forState:UIControlStateNormal];
            [rightBtn setImage:nil forState:UIControlStateNormal];
            [rightBtn sizeToFit];
        });

    }
    else
    {
        [UIView animateWithDuration:0.1f animations:^{
            self.deleteView.alpha = 0;
            [[self deleteView] setTop:ScreenHeight-64];
        } completion:^(BOOL finished) {
            if (self.deleteView) {
                [self.deleteView removeFromSuperview];
                  self.deleteView = nil;
            }
        }];
        [rightBtn setTitle:AYLocalizedString(@"编辑") forState:UIControlStateNormal];
        [rightBtn setImage:LEImage(@"book_edit") forState:UIControlStateNormal];
        [rightBtn sizeToFit];
        //删除已选的书
        [_willDeleteBookList removeAllObjects];
    }
}
-(void)handleLoginSuccess:(NSNotification*)notify
{
    if (_loginTipView) {
        [self loadUserBookrack:nil refresh:NO];
        [[self loginTipView] removeFromSuperview];
        self.collectionTopConstraint.constant = 10.0f;
    }
}

-(void)handleRefreshBookrack
{
    [self loadUserBookrack:nil refresh:NO];

   // [self.collectionView launchRefreshing];
}
-(void)applicationBecomeActive
{
    [[AYSignManager shared] loadAllData:^{
        
    } failure:^(NSString * _Nonnull errorString) {
        
    }];
}

#pragma mark - network -

//小说加入书架
-(void)addBookToBookRack:(NSNotification*)notify
{
    NSString *bookId = notify.object;
    if ([self bookIsAddToBookRack:bookId]) {
        occasionalHint(AYLocalizedString(@"已在书架"));
        return;
    }
    if (![AYUserManager isUserLogin]) {
        [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
            [self addBookToServer:YES bookId:bookId];

        }];
    }
    else
    {
        [self addBookToServer:YES bookId:bookId];

    }
}

//漫画加入书架
-(void)addCartoonToBookRack:(NSNotification*)notify
{

    NSString *bookId = notify.object;
    if ([self bookIsAddToBookRack:bookId]) {
        occasionalHint(AYLocalizedString(@"已在书架"));
        return;
    }
    if (![AYUserManager isUserLogin]) {
        [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
            [self addBookToServer:NO bookId:bookId];

        }];
    }
    else
    {
      [self addBookToServer:NO bookId:bookId];
    }

}

-(void)addBookToServer:(BOOL)fiction  bookId:(NSString*)bookId
{
    [AYBookRackManager addBookToBookRackWithBookID:bookId fiction:fiction compete:^{
            NSString *result = AYLocalizedString(@"加入书架成功");
        occasionalHint(result);
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);

    }];

}

-(void)checkHasNewVersion
{
    [ZWNetwork post:@"HTTP_Post_Update_APP" parameters:nil success:^(id record)
     {
         if (record &&[record isKindOfClass:NSDictionary.class]) {
             AYAPPUpdateModel *updateModel = [AYAPPUpdateModel itemWithDictionary:record];
             if ([updateModel.types integerValue] ==1 || [updateModel.types integerValue] ==2)//升级
             {
                 [self creatUpdateAlertController:updateModel];
             }
     
         }
     } failure:^(LEServiceError type, NSError *error) {
         
     }];
}
#pragma mark - getter and setter -
//-(UITabBarController*)tabBarController
//{
//    UITabBarController *tab = nil;
//    UIViewController *nextViewController = self.parentViewController;
//    while (nextViewController)
//    {
//        if ([nextViewController isKindOfClass:UITabBarController.class]) {
//            tab = (UITabBarController*)nextViewController;
//            return tab;
//        }
//        nextViewController = nextViewController.parentViewController;
//    }
//    return nil;
//}
- (LETransitionNavigationDelegate *)transitionDelegate {
    if (_transitionDelegate == nil) {
        _transitionDelegate = [[LETransitionNavigationDelegate alloc] init];
    }
    return _transitionDelegate;
}
-(UIView*)deleteView
{
    if (!_deleteView)
    {
        _deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight-44, SCREEN_WIDTH, 50)];
        _deleteView.backgroundColor = [UIColor whiteColor];
        _deleteView.layer.shadowColor = [UIColor grayColor].CGColor;
        _deleteView.layer.shadowOffset = CGSizeMake(0,0);
        _deleteView.layer.shadowOpacity = 0.5;
        _deleteView.layer.shadowRadius = 1;
        // 单边阴影 顶边
        float shadowPathWidth = _deleteView.layer.shadowRadius;
        CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, _deleteView.bounds.size.width, shadowPathWidth);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
        _deleteView.layer.shadowPath = path.CGPath;
        
        UIImageView *deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake((_deleteView.bounds.size.width-15)/2, 9, 12, 12)];
        deleteImage.image = LEImage(@"book_delete");
        [_deleteView addSubview:deleteImage];
        UILabel *deleteLable  = [UILabel lableWithTextFont:[UIFont systemFontOfSize:12] textColor:[UIColor redColor] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        deleteLable.text =AYLocalizedString(@"删除");
        deleteLable.frame = CGRectMake(0, 26, SCREEN_WIDTH, 20);
        [_deleteView addSubview:deleteLable];
        _deleteLable = deleteLable;
        LEWeakSelf(self)
        [_deleteView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            LEStrongSelf(self)
            [self creatDeleteAlertController];
       
        }];
    }
    return _deleteView;
}

-(UIView*)loginTipView
{
    if (!_loginTipView)
    {
        _loginTipView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 66)];
        _loginTipView.backgroundColor = [UIColor whiteColor];
        UILabel *tipLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:UIColorFromRGB(0x999999) textAlignment:NSTextAlignmentLeft numberOfLines:2];
        tipLable.frame = CGRectMake(15, 0, ScreenWidth - 100, _loginTipView.bounds.size.height);
        tipLable.text = AYLocalizedString(@"登录可查看书架中的作品哦~");
        [_loginTipView addSubview:tipLable];
        
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.frame = CGRectMake(ScreenWidth-15-76, (_loginTipView.bounds.size.height-36)/2, 76, 30);
        loginBtn.layer.cornerRadius = 14;
        [loginBtn setBackgroundColor:UIColorFromRGB(0xfa556c)];
        [loginBtn setTitle:AYLocalizedString(@"登录") forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginBtn.titleLabel.font = [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
        [_loginTipView addSubview:loginBtn];
        
        LEWeakSelf(self)
        [loginBtn addAction:^(UIButton *btn) {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    LEStrongSelf(self)
                    [self loadUserBookrack:nil refresh:NO];
                    [[self loginTipView] removeFromSuperview];
                    self.collectionTopConstraint.constant = 10.0f;
                });

            }];
        }];
    }
    return _loginTipView;
}
@end
