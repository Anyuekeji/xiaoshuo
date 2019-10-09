//
//  CYReadMenuView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "CYReadMenuView.h"
#import "CYFictionChapterModel.h"
#import "AYFictionModel.h"
#import "AYFictionCatlogManager.h" //目录管理


@interface CYReadMenuView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *chapterTableview;
@property(nonatomic,strong) AYFictionModel *fictionModel;
@property(nonatomic,strong)NSMutableArray<CYFictionChapterModel*>  *chapterArray;// 小说章节数据//回调
@property(nonatomic,assign)NSInteger  currentChapterindex;// 当前阅读的章节

@end

@implementation CYReadMenuView

+(void)showMenuViewInView:(UIView*)parentView fictionModel:(AYFictionModel*)fictinModel  currentChapterIndex:(NSInteger)currentChapterIndex menuList:(NSArray<CYFictionChapterModel*>*)menuList chapterSelect:(void(^)(CYFictionChapterModel * chapterModel,NSInteger chapterIndex)) chatperSelect
{
    UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
    [shaodowView setBackgroundColor:[UIColor clearColor]];
    [parentView addSubview:shaodowView];
    
    CYReadMenuView* menuView = [[CYReadMenuView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth*0.7, ScreenHeight) fictionModel:fictinModel currentChapterIndex:currentChapterIndex  menuList:menuList];
    [parentView addSubview:menuView];

    menuView.transform = CGAffineTransformMakeTranslation(-ScreenWidth*0.8,0);

    LEWeakSelf(menuView)
    LEWeakSelf(shaodowView)
    
    [shaodowView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(menuView)
        LEStrongSelf(shaodowView)
        
        [UIView animateWithDuration:0.5 animations:^{
            menuView.transform = CGAffineTransformMakeTranslation(-ScreenWidth*0.8,0);
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [menuView removeFromSuperview];
            }
        }];
    }];
    menuView.menuViewAction = ^(CYFictionChapterModel * chapterModel,NSInteger chapterIndex) {
        LEStrongSelf(menuView)
        
        if (chatperSelect) {
            chatperSelect(chapterModel,chapterIndex);
        }
        [UIView animateWithDuration:0.3 animations:^{
            menuView.transform = CGAffineTransformMakeTranslation(-ScreenWidth*0.8,0);
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [menuView removeFromSuperview];
            }
        }];
    };

    [UIView animateWithDuration:0.5f animations:^{
        menuView.transform = CGAffineTransformMakeTranslation(0,0);
    }];
}

-(instancetype)initWithFrame:(CGRect)frame fictionModel:(AYFictionModel*)fictinModel currentChapterIndex:(NSInteger)currentChapterIndex menuList:(NSArray<CYFictionChapterModel*>*)menuList
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI:fictinModel];
        self.fictionModel = fictinModel;
        self.chapterArray = [NSMutableArray new];
        _currentChapterindex = currentChapterIndex;
        //[self.chapterArray safe_addObjectsFromArray:menuList];
        [self localCatalog];
    }
    return self;
}

-(void)configureUI:(AYFictionModel*)fictionModel
{
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0,(_ZWIsIPhoneXSeries()?STATUS_BAR_HEIGHT-10:0), self.bounds.size.width, 82)];
    [self addSubview:headView];
    
    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:18] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:2];
    nameLable.frame = CGRectMake(15, 21,self.width-15-2,nameLable.height);
    nameLable.preferredMaxLayoutWidth =self.bounds.size.width;
    nameLable.text = fictionModel.fictionTitle;
    [nameLable sizeToFit];

    [headView addSubview:nameLable];
    
    UILabel *chaperLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE] textColor:RGB(153,153 ,153) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    chaperLable.frame = CGRectMake(15, nameLable.height+nameLable.top+5, ScreenWidth,11);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        chaperLable.text = [NSString stringWithFormat:AYLocalizedString(@"共%d章"),self.chapterArray.count];

    });
    headView.height = chaperLable.top+chaperLable.height+8;
    [headView addSubview:chaperLable];
    
    UITableView *chapterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,headView.top+ headView.bounds.size.height+5, self.bounds.size.width, ScreenHeight-headView.bounds.size.height-headView.top)];
    chapterTableView.delegate = self;
    chapterTableView.dataSource = self;
    chapterTableView.rowHeight = 45;
    [self addSubview:chapterTableView];
    _chapterTableview = chapterTableView;
    chapterTableView.backgroundColor = [UIColor whiteColor];
    
    self.chapterTableview.showsVerticalScrollIndicator =NO;
    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.chapterTableview setTableFooterView:footView];
    
    //设置阴影
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = 1;

    // 单边阴影 底边边
    float shadowPathWidth = self.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(self.bounds.size.width+shadowPathWidth/2.0, 0,shadowPathWidth+3,self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    self.layer.shadowPath = path.CGPath;

}
#pragma mark  - delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CYFictionChapterModel *model = [self.chapterArray safe_objectAtIndex:indexPath.row];
    if (_menuViewAction) {
        _menuViewAction(model,indexPath.row);
    }
    //隐藏view
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(-self.width*0.9, 0);
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chapterArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifer = @"mentCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer];
    }
    CYFictionChapterModel *chapterModle = [_chapterArray safe_objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
    if (_currentChapterindex  == indexPath.row) {
        cell.textLabel.textColor = RGB(250, 85, 108);
    }
    else
    {
        cell.textLabel.textColor = RGB(51, 51, 51);

    }
    cell.textLabel.text = [NSString stringWithFormat:@" %@",chapterModle.fictionSectionTitle];
   if ([chapterModle.needMoney integerValue]>0)
   {
        UIButton *lockBtn = (UIButton*)cell.accessoryView;
        if (!lockBtn) {
            lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            lockBtn.frame = CGRectMake(0, 0, 18, 21);
            cell.accessoryView = lockBtn;
        }
        if (![chapterModle.unlock boolValue])
        {
            [lockBtn setImage:LEImage(@"read_lock") forState:UIControlStateNormal];
            [lockBtn setImage:LEImage(@"read_lock") forState:UIControlStateHighlighted];
        }
        else
        {
            [lockBtn setImage:LEImage(@"read_unlock") forState:UIControlStateNormal];
            [lockBtn setImage:LEImage(@"read_unlock") forState:UIControlStateHighlighted];
        }
    }
    else
    {
        cell.accessoryView = nil;
    }
    
    return cell;
}
#pragma mark - ui  -

//让当前章节在中间
-(void)changeScrollviewContentOffset
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //当前阅读章节到中间
       // NSInteger centerIndex = (self.height /45)/2;
        if (self.chapterTableview.contentSize.height>self.chapterTableview.height && self.currentChapterindex>3) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.chapterTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentChapterindex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.chapterTableview.contentOffset.y> (self.chapterTableview.contentSize.height-self.chapterTableview.height-10)) {
                        return;
                    }
                       self.chapterTableview.contentOffset  = CGPointMake(self.chapterTableview.contentOffset.x, self.chapterTableview.contentOffset.y-4*35);
                });
             
            });
        }
    });
}
#pragma mark - network  -

-(void)localCatalog
{
    [[AYFictionCatlogManager shared] fetchFictionCatlogWithFictionId:self.fictionModel.fictionID refresh:NO success:^(NSArray<CYFictionChapterModel *> * _Nonnull fictionCatlogArray) {
        if (fictionCatlogArray) {
            [self.chapterArray addObjectsFromArray:fictionCatlogArray];
            [self.chapterTableview reloadData];
            [self changeScrollviewContentOffset];
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];

}
#pragma mark  - setter or getter -

@end
