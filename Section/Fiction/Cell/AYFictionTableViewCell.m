//
//  AYFictionTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionTableViewCell.h"
#import "AYFictionModel.h"
#import "AYUtitle.h"
#import "AYBookModel.h" //书本model
#import "AYCartoonModel.h"
#import "UIImageView+AY.h"
#import "AYADSkipManager.h" //banner跳转管理
#import "UIView+AY.h"

@interface AYFictionTableViewCell()
@property(nonatomic,strong)UIImageView *fictionImageView;//小说图片
@property(nonatomic,strong)UIImageView *coinImageView;
@property(nonatomic,strong)UILabel *fictionTitleLable; //小说标题
@property(nonatomic,strong)UILabel *fictionIntroduceLable; //小说简介
@property(nonatomic,strong)UILabel *coinNumLable; //小说金币
@property(nonatomic,strong)UILabel *authorLable; //作者
@property(nonatomic,strong)UIView *containView; //包含视图
@property(nonatomic,strong)UIView *freeViewFlag; //免费标记

@end

@implementation AYFictionTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutUI];

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)configureUI
{
    [self bottomLineRightMoveWithValue:15];
    self.contentView.backgroundColor  =[UIColor whiteColor];
    
    UIView *containView  = [UIView new];
    containView.translatesAutoresizingMaskIntoConstraints = NO;
    containView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containView];
    _containView = containView;
    
    NSDictionary * _binds = @{@"containView":containView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containView]-1-|" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containView]-0-|" options:0 metrics:nil views:_binds]];
    
    UIImageView *fictionImageView = [UIImageView new];
    fictionImageView.contentMode = UIViewContentModeScaleAspectFill;
    fictionImageView.clipsToBounds = YES; fictionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containView addSubview:fictionImageView];
    _fictionImageView = fictionImageView;
    [_fictionImageView addCornorsWithValue:5.0f];

    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containView addSubview:titleLable];
    _fictionTitleLable = titleLable;
    
    UILabel *introduceLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(102, 102, 102) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    introduceLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containView addSubview:introduceLable];
    _fictionIntroduceLable = introduceLable;
    
    UILabel *authorLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:UIColorFromRGB(0xff6666) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    authorLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containView addSubview:authorLable];
    _authorLable = authorLable;
    
    UIImageView* coinImageView= [UIImageView new];
    coinImageView.translatesAutoresizingMaskIntoConstraints = NO;
    coinImageView.image = LEImage(@"wujiaoxin_select");
    [self.containView addSubview:coinImageView];
    _coinImageView = coinImageView;
    
    UILabel *coinNumLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentRight numberOfLines:1];
    coinNumLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containView addSubview:coinNumLable];
    _coinNumLable = coinNumLable;
    
}

-(void)layoutUI
{
    
    if([self isKindOfClass:AYFreeBookTableViewCell.class] || [self isKindOfClass:AYCartoonTableViewCell.class])
    {
        return;
    }
    
    NSDictionary * _binds = @{@"fictionImageView":self.fictionImageView, @"fictionTitleLable":self.fictionTitleLable, @"fictionIntroduceLable":self.fictionIntroduceLable, @"authorLable":self.authorLable, @"coinImageView":self.coinImageView, @"coinNumLable":self.coinNumLable};
    
    CGFloat fictionImgWidth = CELL_BOOK_IMAGE_WIDTH;
    CGFloat fictionImgHeight =CELL_BOOK_IMAGE_HEIGHT;
    
    CGFloat introduceOriginx =15*2+fictionImgWidth;
    
   _fictionIntroduceLable.preferredMaxLayoutWidth = ScreenWidth-introduceOriginx-15;

    NSDictionary * _metrics = @{@"imgW":@(fictionImgWidth),@"imgH":@(fictionImgHeight),@"originX":@(introduceOriginx)};
    
 
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[fictionImageView(==imgH@999)]-15-|" options:0 metrics:_metrics views:_binds]];
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[fictionImageView(==imgW)]-15-[fictionIntroduceLable]-15-|" options:0 metrics:_metrics views:_binds]];
    
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionTitleLable]-15-|" options:NSLayoutFormatAlignAllBottom metrics:_metrics views:_binds]];
    
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[authorLable]-(>=20@999)-[coinNumLable]-3-[coinImageView(==13)]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:_metrics views:_binds]];
    
//    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20@999)-[fictionTitleLable(==25@999)]-(==8@999)-[fictionIntroduceLable]-(==10@999)-[authorLable(==15@999)]-18@999-|" options:0 metrics:_metrics views:_binds]];
    
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==17@999)-[fictionTitleLable(==25@999)]-(==8@999)-[fictionIntroduceLable]-(==10@999)-[authorLable(==15@999)]-17@999-|" options:0 metrics:_metrics views:_binds]];

}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYFictionModel.class])
    {
        AYFictionModel *fictionModel =(AYFictionModel*)model;
        LEImageSet(_fictionImageView, fictionModel.fictionImageUrl, @"ws_register_example_company");
        _fictionTitleLable.text = fictionModel.fictionTitle;
        _fictionIntroduceLable.text = fictionModel.fictionIntroduce;
        _authorLable.text = fictionModel.fictionAuthor;
        _coinNumLable.text =[fictionModel.is_virtual boolValue]?fictionModel.virtual_coin:fictionModel.fictionCoinNum;
        if([fictionModel.isfree integerValue]==4)
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.fictionImageView addOrRemoveFreeFlag:NO];

        }

    }
    if ([model isKindOfClass:AYCartoonModel.class])
    {
        AYCartoonModel *bookModel =(AYCartoonModel*)model;
        LEImageSet(self.fictionImageView, bookModel.cartoonImageUrl, @"ws_register_example_company");
        self.fictionTitleLable.text = bookModel.cartoonTitle;
        self.fictionIntroduceLable.text = bookModel.cartoonIntroduce;
        self.authorLable.text = bookModel.cartoonAuthor;
        _authorLable.text = bookModel.cartoonAuthor;
        _coinNumLable.text =[bookModel.is_virtual boolValue]?bookModel.virtual_coin:bookModel.cartoonCoinNum;
        if([bookModel.isfree integerValue] ==4)
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.fictionImageView addOrRemoveFreeFlag:NO];
            
        }
    }
    else if ([model isKindOfClass:AYBookModel.class])
    {
        AYBookModel *bookModel =(AYBookModel*)model;
        LEImageSet(self.fictionImageView, bookModel.bookImageUrl, @"ws_register_example_company");
        self.fictionTitleLable.text = bookModel.bookTitle;
        self.fictionIntroduceLable.text = bookModel.bookIntroduce;
        self.authorLable.text = bookModel.bookAuthor;
        _authorLable.text = bookModel.bookAuthor;
      //  _coinNumLable.text =bookModel.bo;
        if([bookModel.isfree integerValue]==4)
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.fictionImageView addOrRemoveFreeFlag:NO];
            
        }
    }
}
//-(void)addOrRemoveFreeFlag:(BOOL)add
//{
//    if (_freeViewFlag) {
//        [_freeViewFlag removeFromSuperview];
//    }
//    if (add)
//    {
//        UILabel *freeFlagLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:10] textColor:RGB(255, 255, 255) textAlignment:NSTextAlignmentCenter numberOfLines:1];
//        freeFlagLable.backgroundColor =RGB(255, 59, 98);
//        [self.fictionImageView addSubview:freeFlagLable];
//        freeFlagLable.text = AYLocalizedString(@"免费");
//        _freeViewFlag = freeFlagLable;
//        _freeViewFlag.frame = CGRectMake(-30, 8, 100, 20);
//        _freeViewFlag.transform =CGAffineTransformMakeRotation (-M_PI_4);
//    }
//}
@end

//一行三个cell
@interface AYFreeBookTableViewCell()

@property(nonatomic,strong)UIButton *bookTypeFlagBtn; //书籍类型，小说或者漫画

@end

@implementation AYFreeBookTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutFreeUI];

}
-(void)configureUI
{
    [super configureUI];
    [self.coinNumLable removeFromSuperview];
    [self.coinImageView removeFromSuperview];
    
    self.authorLable.textColor = RGB(250, 85, 108);
    
    self.bookTypeFlagBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:10] textColor:[UIColor whiteColor] title:AYLocalizedString(@"漫画") image:nil];
  self.bookTypeFlagBtn.translatesAutoresizingMaskIntoConstraints =NO;
    // 加载图片
    UIImage *image = [UIImage imageNamed:@"free_Cartoon"];
    // 设置端盖的值
    CGFloat top = 5;
    CGFloat left = 10;
    CGFloat bottom = 5;
    CGFloat right = 10;
    // 设置端盖的值
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    // 设置拉伸的模式
    UIImageResizingMode mode = UIImageResizingModeStretch;
    // 拉伸图片
    UIImage *newImage = [image resizableImageWithCapInsets:edgeInsets resizingMode:mode];
    [self.bookTypeFlagBtn setBackgroundImage:newImage forState:UIControlStateNormal];
    [self.containView addSubview:self.bookTypeFlagBtn];
    
    self.bookTypeFlagBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 9, 10, 0);

}
-(void)layoutFreeUI
{
    
    [self.containView removeConstraints:self.containView.constraints];
    NSDictionary * _binds = @{@"fictionImageView":self.fictionImageView, @"fictionTitleLable":self.fictionTitleLable, @"fictionIntroduceLable":self.fictionIntroduceLable, @"authorLable":self.authorLable, @"bookTypeFlagBtn":self.bookTypeFlagBtn};
    
    CGFloat fictionImgWidth = CELL_BOOK_IMAGE_WIDTH;
    CGFloat fictionImgHeight =CELL_BOOK_IMAGE_HEIGHT;
    
    CGFloat introduceOriginx =15*2+fictionImgWidth;
    
    self.fictionIntroduceLable.preferredMaxLayoutWidth = ScreenWidth-introduceOriginx-15;
    
    NSDictionary * _metrics = @{@"imgW":@(fictionImgWidth),@"imgH":@(fictionImgHeight),@"originX":@(introduceOriginx)};
    
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[fictionImageView(==imgH@999)]-15-|" options:0 metrics:_metrics views:_binds]];
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[fictionImageView(==imgW)]-15-[fictionIntroduceLable]-15-|" options:0 metrics:_metrics views:_binds]];
    
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionTitleLable]-15-|" options:NSLayoutFormatAlignAllBottom metrics:_metrics views:_binds]];
    
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[authorLable]-(>=20@999)-[bookTypeFlagBtn(==60@999)]-15-|" options:0 metrics:_metrics views:_binds]];
    
   [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[bookTypeFlagBtn(==30@999)]" options:0 metrics:_metrics views:_binds]];

    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20@999)-[fictionTitleLable(==25@999)]-(==8@999)-[authorLable(==15@999)]-(==8@999)-[fictionIntroduceLable]-15@999-|" options:0 metrics:_metrics views:_binds]];
    
}

-(void)fillCellWithModel:(id)model freeFlag:(BOOL)freeFlag
{
    if ([model isKindOfClass:AYBookModel.class])
    {
        AYBookModel *bookModel =(AYBookModel*)model;
        LEImageSet(self.fictionImageView, bookModel.bookImageUrl, @"ws_register_example_company");
        self.fictionTitleLable.text = bookModel.bookTitle;
        self.fictionIntroduceLable.text = bookModel.bookIntroduce;
        self.authorLable.text = bookModel.bookAuthor?bookModel.bookAuthor:@"author";
        [self.bookTypeFlagBtn setTitle:([bookModel.type integerValue]==1)?AYLocalizedString(@"小说"):AYLocalizedString(@"漫画") forState:UIControlStateNormal];
        [self.bookTypeFlagBtn setBackgroundImage:([bookModel.type integerValue]==1)?LEImage(@"free_Fiction"):LEImage(@"free_Cartoon") forState:UIControlStateNormal];
        if ([bookModel.isfree integerValue]==4)
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
              }
        else
        {
            [self.fictionImageView addOrRemoveFreeFlag:NO];
        }
        
    }
}

@end

//漫画cell
@interface AYCartoonTableViewCell()

@end

@implementation AYCartoonTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    [super configureUI];
    self.authorLable.textColor = RGB(250, 85, 108);
    [self.coinNumLable removeFromSuperview];
    [self.coinImageView removeFromSuperview];
    [self layoutCartoonUI];
}
-(void)layoutCartoonUI
{
    NSDictionary * _binds = @{@"fictionImageView":self.fictionImageView, @"fictionTitleLable":self.fictionTitleLable, @"fictionIntroduceLable":self.fictionIntroduceLable, @"authorLable":self.authorLable};
    CGFloat fictionImgWidth = CELL_BOOK_IMAGE_WIDTH;
    CGFloat fictionImgHeight =CELL_BOOK_IMAGE_HEIGHT;
    CGFloat introduceOriginx =15*2+fictionImgWidth;
    
    self.fictionIntroduceLable.preferredMaxLayoutWidth = ScreenWidth-introduceOriginx-15;
    NSDictionary * _metrics = @{@"imgW":@(fictionImgWidth),@"imgH":@(fictionImgHeight),@"originX":@(introduceOriginx)};
    
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[fictionImageView(==imgH@999)]-15-|" options:0 metrics:_metrics views:_binds]];
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[fictionImageView(==imgW)]-15-[fictionIntroduceLable]-15-|" options:0 metrics:_metrics views:_binds]];
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionTitleLable]-15-|" options:NSLayoutFormatAlignAllBottom metrics:_metrics views:_binds]];
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[authorLable]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:_metrics views:_binds]];
    [self.containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20@999)-[fictionTitleLable(==25@999)]-(==8@999)-[fictionIntroduceLable]-(==10@999)-[authorLable(==15@999)]-18@999-|" options:0 metrics:_metrics views:_binds]];
    
}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYCartoonModel.class])
    {
        AYCartoonModel *bookModel =(AYCartoonModel*)model;
        LEImageSet(self.fictionImageView, bookModel.cartoonImageUrl, @"ws_register_example_company");
        self.fictionTitleLable.text = bookModel.cartoonTitle;
        self.fictionIntroduceLable.text = bookModel.cartoonIntroduce;
        self.authorLable.text = bookModel.cartoonAuthor;
        
        if([bookModel.isfree integerValue]==4)
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.fictionImageView addOrRemoveFreeFlag:NO];
            
        }
    }
    else if ([model isKindOfClass:AYBookModel.class])
    {
        AYBookModel *bookModel =(AYBookModel*)model;
        LEImageSet(self.fictionImageView, bookModel.bookImageUrl, @"ws_register_example_company");
        self.fictionTitleLable.text = bookModel.bookTitle;
        self.fictionIntroduceLable.text = bookModel.bookIntroduce;
        self.authorLable.text = bookModel.bookAuthor;
        
        if([bookModel.isfree integerValue]==4)
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.fictionImageView addOrRemoveFreeFlag:NO];
            
        }
    }
    else if ([model isKindOfClass:AYFictionModel.class])
    {
        AYFictionModel *bookModel =(AYFictionModel*)model;
        LEImageSet(self.fictionImageView, bookModel.fictionImageUrl, @"ws_register_example_company");
        self.fictionTitleLable.text = bookModel.fictionTitle;
        self.fictionIntroduceLable.text = bookModel.fictionIntroduce;
        self.authorLable.text = bookModel.fictionAuthor;
        if([bookModel.isfree integerValue]==4)
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.fictionImageView addOrRemoveFreeFlag:NO];
            
        }
    }
}

@end

//推荐头部cell
@interface AYFictionRecomendHeadTableViewCell()
@property(nonatomic,strong)UIImageView *fictionImageView;//小说图片
@property(nonatomic,strong)UILabel *fictionTitleLable; //小说标题
@property(nonatomic,strong)UILabel *fictionIntroduceLable; //小说简介
@property(nonatomic,strong)UILabel *statusLable; //小说状态（完结或连载中）
@property(nonatomic,strong)UILabel *percentLable; //评分（多少分）

@end


@implementation AYFictionRecomendHeadTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    UIImageView *fictionImageView = [UIImageView new];
    fictionImageView.contentMode = UIViewContentModeScaleAspectFill;
    fictionImageView.clipsToBounds = YES; fictionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:fictionImageView];
    _fictionImageView = fictionImageView;
    [_fictionImageView addCornorsWithValue:5.0f];
    
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:titleLable];
    _fictionTitleLable = titleLable;
    UILabel *introduceLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(102, 102, 102) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    introduceLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:introduceLable];
    _fictionIntroduceLable = introduceLable;
    
    UILabel *statusLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:RGB(250, 85, 108) textAlignment:NSTextAlignmentLeft numberOfLines:1];
 statusLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:statusLable];
    _statusLable = statusLable;
    
//    UILabel *coinNumLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentRight numberOfLines:1];
//    coinNumLable.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.contentView addSubview:coinNumLable];
//    _percentLable = coinNumLable;
    
    [self layoutUI];
}

-(void)layoutUI
{
    
    NSDictionary * _binds = @{@"fictionImageView":self.fictionImageView, @"fictionTitleLable":self.fictionTitleLable, @"fictionIntroduceLable":self.fictionIntroduceLable, @"statusLable":self.statusLable};
    
    CGFloat fictionImgWidth = CELL_BOOK_IMAGE_WIDTH;
    CGFloat fictionImgHeight =CELL_BOOK_IMAGE_HEIGHT;
    
    CGFloat introduceOriginx =15*2+fictionImgWidth;
    
    _fictionIntroduceLable.preferredMaxLayoutWidth = ScreenWidth-introduceOriginx-15;
    
    NSDictionary * _metrics = @{@"imgW":@(fictionImgWidth),@"imgH":@(fictionImgHeight),@"originX":@(introduceOriginx)};
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[fictionImageView(==imgH@999)]-15-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[fictionImageView(==imgW)]-15-[fictionIntroduceLable]-15-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionTitleLable]-15-|" options:NSLayoutFormatAlignAllBottom metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[statusLable]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==10@999)-[fictionTitleLable(==25@999)]-(==9@999)-[statusLable(==10)]-(==8)-[fictionIntroduceLable]-10@999-|" options:0 metrics:_metrics views:_binds]];
    
}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYFictionModel.class])
    {
        AYFictionModel *fictionModel =(AYFictionModel*)model;
        LEImageSet(_fictionImageView, fictionModel.fictionImageUrl, @"ws_register_example_company");
        _fictionTitleLable.text = fictionModel.fictionTitle;
        _fictionIntroduceLable.text = fictionModel.fictionIntroduce;
        _statusLable.text = ([fictionModel.fiction_update_status integerValue]==1?AYLocalizedString(@"已完结"):AYLocalizedString(@"连载中"));;
        if(![fictionModel.isfree integerValue])
        {
            [self.fictionImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.fictionImageView addOrRemoveFreeFlag:NO];
        }
        
    }
}
//-(void)addOrRemoveFreeFlag:(BOOL)add
//{
//     if (add)
//    {
//        UILabel *freeFlagLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:10] textColor:RGB(255, 255, 255) textAlignment:NSTextAlignmentCenter numberOfLines:1];
//        freeFlagLable.backgroundColor =RGB(205, 85, 108);
//        [self.contentView addSubview:freeFlagLable];
//        freeFlagLable.text = AYLocalizedString(@"免费");
//        freeFlagLable.frame =CGRectMake(ScreenWidth-70, 8, 100, 20);
//        freeFlagLable.transform =CGAffineTransformMakeRotation (M_PI_4);
//    }
//}
@end


//一行三个cell
@interface AYFictionThreeTableViewCell()<UICollectionViewDelegate, UICollectionViewDataSource>


@property (strong, nonatomic) NSMutableArray *fictionArray;

@end

@implementation AYFictionThreeTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    self.contentView.backgroundColor = UIColorFromRGB(0xf7f7f7);
    UIView *containView  = [UIView new];
   containView.translatesAutoresizingMaskIntoConstraints = NO;
    containView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containView];
    NSDictionary * _binds = @{@"containView":containView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containView]-5@999-|" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containView]-0-|" options:0 metrics:nil views:_binds]];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 15.0f;
    layout.minimumLineSpacing = 10.0f;
    CGFloat imageWidth =((isIPhone4|| isIPhone5)? CELL_BOOK_IMAGE_WIDTH-8:CELL_BOOK_IMAGE_WIDTH);
    CGFloat cellHeight = CELL_BOOK_IMAGE_HEIGHT+50;
    layout.itemSize = CGSizeMake(imageWidth, cellHeight);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 10, ScreenWidth-30,cellHeight) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [containView addSubview:self.collectionView];
    _fictionArray = [NSMutableArray new];
    [self.collectionView registerClass:AYFictionCollectionViewCell.class forCellWithReuseIdentifier:@"AYFictionCollectionViewCell"];
}
-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:NSArray.class])
    {
        [_fictionArray removeAllObjects];
        [_fictionArray addObjectsFromArray:model];
        [_collectionView reloadData];
    }
}

+(CGFloat)cellHeight
{
    return  CELL_BOOK_IMAGE_HEIGHT+63;
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fictionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AYFictionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AYFictionCollectionViewCell" forIndexPath:indexPath];
    id model = [self.fictionArray safe_objectAtIndex:indexPath.row];
    [cell filCellWithModel:model];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AYFictionModel *model = [self.fictionArray safe_objectAtIndex:indexPath.row];
    if ([model isKindOfClass:AYFictionModel.class]) {
        [ZWREventsManager sendViewControllerEvent:kEventAYFictionDetailViewController parameters:model];
    }
    else if ([model isKindOfClass:AYCartoonModel.class])
    {
        [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYNewCartoonDetailViewController parameters:model];
    }
    else if ([model isKindOfClass:AYBookModel.class])
    {
        AYBookModel *bookModel = (AYBookModel*)model;
        bookModel.bookDestinationType= @(1);
        [AYADSkipManager adSkipWithModel:bookModel];
    }

}
@end

#import "LECollectionViewFlowLayout.h"


//一行三个cell
@interface AYFictionHorizontalScrollAnimateTableViewCell()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UILabel *titleLable; //标题lable
@property (strong, nonatomic) UILabel *introduceLable;//简介lable
@property (assign,nonatomic) NSInteger m_currentIndex;
@property (assign,nonatomic) CGFloat m_dragStartX;
@property (assign,nonatomic) CGFloat m_dragEndX;
@property (strong, nonatomic) NSMutableArray *fictionArray;
@property (strong, nonatomic) UIButton *nextBtn;
@property (strong, nonatomic) UIButton *beforeBtn;
@property (strong, nonatomic) UICollectionViewCell *oldSelectCollectionCell;

@end

@implementation AYFictionHorizontalScrollAnimateTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    self.contentView.backgroundColor = UIColorFromRGB(0xf7f7f7);
    
    UIView *containView  = [UIView new];
    containView.translatesAutoresizingMaskIntoConstraints = NO;
    containView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containView];
    
    NSDictionary * _binds = @{@"containView":containView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containView]-3-|" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containView]-0-|" options:0 metrics:nil views:_binds]];
    LECollectionViewFlowLayout *layout = [[LECollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 10.0f;
    layout.minimumLineSpacing = 10.0f;
    CGFloat imageWidth = CELL_HORZON_BOOK_IMAGE_WIDTH;
    CGFloat imageHeight = CELL_HORZON_BOOK_IMAGE_HEIGHT;
    layout.itemSize = CGSizeMake(imageWidth, imageHeight+30);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(16,0, ScreenWidth-32,imageHeight+30) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [containView addSubview:self.collectionView];
    _fictionArray = [NSMutableArray new];
    [self.collectionView registerClass:AYFictionHorizontalScrollCollectionViewCell.class forCellWithReuseIdentifier:@"AYFictionHorizontalScrollCollectionViewCell"];

    self.collectionView.pagingEnabled = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;

    self.collectionView.collectionViewLayout = layout;
    _titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    _titleLable.backgroundColor = [UIColor whiteColor];
    _titleLable.frame = CGRectMake(15, self.collectionView.top+self.collectionView.height, ScreenWidth-30, 24);
    [containView addSubview:_titleLable];
    
    _introduceLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentCenter numberOfLines:0];
    _introduceLable.backgroundColor = [UIColor whiteColor];
    _introduceLable.frame = CGRectMake(15, self.titleLable.top+self.titleLable.height+6, ScreenWidth-30, 73);
    [containView addSubview:_introduceLable];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:11] textColor:UIColorFromRGB(0x666666) title:nil image:nil];
    [nextBtn setBackgroundImage:LEImage(@"arry_right") forState:UIControlStateNormal];
    CGFloat cellHeight = self.collectionView.height;
    nextBtn.frame =CGRectMake(ScreenWidth-12, (cellHeight-14)/2.0f, 8, 14);
    [containView addSubview:nextBtn];
    LEWeakSelf(self)
    [nextBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        self.m_currentIndex +=1;
        [self changeCollectionViewContentOffset:YES];
    }];
    self.nextBtn = nextBtn;
    
    UIButton *beforeBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:11] textColor:UIColorFromRGB(0x666666) title:nil image:nil];
    [beforeBtn setBackgroundImage:LEImage(@"arry_right") forState:UIControlStateNormal];
    beforeBtn.transform = CGAffineTransformMakeRotation(-M_PI);
    beforeBtn.frame =CGRectMake(4, (cellHeight-14)/2.0f, 8, 14);
    [containView addSubview:beforeBtn];
    [beforeBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        self.m_currentIndex -=1;
        [self changeCollectionViewContentOffset:YES];
    }];
    self.beforeBtn = beforeBtn;
    
}
//配置cell居中
- (void)fixCellToCenter {
    //最小滚动距离
    float dragMiniDistance =20;
    if (self.m_dragStartX -  self.m_dragEndX >= dragMiniDistance) {
        self.m_currentIndex -= 1;//向右
    }else if(self.m_dragEndX -  self.m_dragStartX >= dragMiniDistance){
        self.m_currentIndex += 1;//向左
    }
   
    [self changeCollectionViewContentOffset:YES];
}
-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:NSArray.class])
    {
        [self.fictionArray removeAllObjects];
        [self.fictionArray addObjectsFromArray:model];
        [self.collectionView reloadData];
        if (self.m_currentIndex<=0) {
            self.m_currentIndex =2;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self changeCollectionViewContentOffset:NO];
            });
        }

    }
}
-(void)changeCollectionViewContentOffset:(BOOL)animate
{
    NSInteger maxIndex = self.fictionArray.count - 1;
    
    self.m_currentIndex = self.m_currentIndex <= 0 ? 0 : self.m_currentIndex;
    
    self.m_currentIndex = self.m_currentIndex >= maxIndex ? maxIndex : self.m_currentIndex;
    
//    if (_m_currentIndex==0)
//    {
//        self.beforeBtn.alpha =0;
//    }
//    else if (_m_currentIndex==maxIndex)
//    {
//        self.nextBtn.alpha =0;
//    }
//    else
//    {
//        self.nextBtn.alpha =1;
//        self.beforeBtn.alpha =1;
//    }
    self.nextBtn.alpha =1;
    self.beforeBtn.alpha =1;
    if (self.m_currentIndex>=0)
    {
        [self.collectionView  scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.m_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animate];
        AYFictionModel *fictionModel =[self.fictionArray safe_objectAtIndex:self.m_currentIndex];
        if (fictionModel.fictionTitle && fictionModel.fictionIntroduce) {
            self.titleLable.text = fictionModel.fictionTitle;
            self.introduceLable.text = fictionModel.fictionIntroduce;
            
            if (self.oldSelectCollectionCell) {
                [self.oldSelectCollectionCell addOrRemoveShowdow:NO];
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.m_currentIndex inSection:0]];
            [cell addOrRemoveShowdow:YES];
            self.oldSelectCollectionCell = cell;
        }

    }
    

}
#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fictionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AYFictionHorizontalScrollCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AYFictionHorizontalScrollCollectionViewCell" forIndexPath:indexPath];
    AYFictionModel *model = [self.fictionArray safe_objectAtIndex:indexPath.row];
    [cell filCellWithModel:model];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AYFictionModel *model = [self.fictionArray safe_objectAtIndex:indexPath.row];
    [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYFictionDetailViewController parameters:model];
    
}
#pragma mark - UIScrollViewDelegate

//手指拖动开始
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.m_dragStartX = scrollView.contentOffset.x;
}

//手指拖动停止
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.m_dragEndX = scrollView.contentOffset.x;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fixCellToCenter];
    });
}

+(CGFloat)cellHeight
{
    return  CELL_HORZON_BOOK_IMAGE_HEIGHT+147;
}
@end
@interface AYFictionCollectionViewCell()
@property (nonatomic, strong) UILabel *bookNameLable; //书名
@property (nonatomic, strong) UIImageView *bookCoverImageView; //书的封面

@end

@implementation AYFictionCollectionViewCell
- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    _bookNameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:2];
    _bookNameLable.preferredMaxLayoutWidth =CELL_BOOK_IMAGE_WIDTH;
    _bookNameLable.textAlignment = NSTextAlignmentCenter;
    _bookNameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_bookNameLable];
    
    _bookCoverImageView = [UIImageView new];
    _bookCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bookCoverImageView.clipsToBounds = YES;
    _bookCoverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_bookCoverImageView];
    [_bookCoverImageView addCornorsWithValue:5.0f];

    CGFloat imageWidth = CELL_BOOK_IMAGE_WIDTH;
    CGFloat imageHeight = CELL_BOOK_IMAGE_HEIGHT;
    //布局
    NSDictionary * _binds = @{@"name":_bookNameLable, @"Cover":_bookCoverImageView};
    NSDictionary * _metrics = @{@"imgW":@(imageWidth), @"imgH":@(imageHeight)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[name(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[Cover(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[Cover(==imgH@999)]-2-[name]-5@999-|" options:0 metrics:_metrics views:_binds]];
}

/**填充数据*/
-(void)filCellWithModel:(id)model
{
    if([model isKindOfClass:[AYFictionModel class]])
    {
            AYFictionModel *bookModel = (AYFictionModel*)model;
            _bookNameLable.text = bookModel.fictionTitle;
            LEImageSet(_bookCoverImageView, bookModel.fictionImageUrl, @"ws_register_example_company");
        if([bookModel.isfree integerValue]==4)
        {
            [self.bookCoverImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.bookCoverImageView addOrRemoveFreeFlag:NO];
            
        }
    }
    else if([model isKindOfClass:[AYBookModel class]])
    {
        AYBookModel *bookModel = (AYBookModel*)model;
        LEImageSet(_bookCoverImageView, bookModel.bookImageUrl, @"ws_register_example_company");
        _bookNameLable.text = bookModel.bookTitle;
        if([bookModel.isfree integerValue]==4)
        {
            [self.bookCoverImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.bookCoverImageView addOrRemoveFreeFlag:NO];
            
        }
    }
    else if([model isKindOfClass:[AYCartoonModel class]])
    {
        AYCartoonModel *cartoonModel = (AYCartoonModel*)model;
        LEImageSet(_bookCoverImageView, cartoonModel.cartoonImageUrl, @"ws_register_example_company");
        _bookNameLable.text = cartoonModel.cartoonTitle;
        if([cartoonModel.isfree integerValue]==4)
        {
            [self.bookCoverImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.bookCoverImageView addOrRemoveFreeFlag:NO];
            
        }
    }
}

@end

@interface AYFictionHorizontalScrollCollectionViewCell()
@property (nonatomic, strong) UIImageView *bookCoverImageView; //书的封面

@end

@implementation AYFictionHorizontalScrollCollectionViewCell
- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    _bookCoverImageView = [UIImageView new];
    _bookCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bookCoverImageView.clipsToBounds = YES;
 _bookCoverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_bookCoverImageView];
    [_bookCoverImageView addCornorsWithValue:5.0f];
    CGFloat imageWidth = self.bounds.size.width;
    CGFloat imageHeight = self.bounds.size.height;
    //布局
    NSDictionary * _binds = @{@"Cover":_bookCoverImageView};
    NSDictionary * _metrics = @{@"imgW":@(imageWidth), @"imgH":@(imageHeight)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[Cover(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[Cover(==imgH)]-0-|" options:0 metrics:_metrics views:_binds]];
}

/**填充数据*/
-(void)filCellWithModel:(id)model
{
    if([model isKindOfClass:[AYFictionModel class]])
    {
        AYFictionModel *bookModel = (AYFictionModel*)model;
        if (bookModel.fictionImageUrl) {
            LEImageSet(_bookCoverImageView, bookModel.fictionImageUrl, @"ws_register_example_company");
            _bookCoverImageView.alpha = 1;
        }
        else
        {
            _bookCoverImageView.alpha = 0;
        }
        if([bookModel.isfree integerValue]==4)
        {
            [self.bookCoverImageView addOrRemoveFreeFlag:YES];
        }
        else{
            [self.bookCoverImageView addOrRemoveFreeFlag:NO];
            
        }
    }
}
@end


@interface AYHotSearchTableViewCell()
@property (nonatomic, strong) UILabel *rankingLable; //排名labeel
@property (nonatomic, strong) UILabel *hotSearchTextLable; //热搜label

@end

@implementation AYHotSearchTableViewCell
- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    _rankingLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:UIColorFromRGB(0xFFFFFF) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    _rankingLable.translatesAutoresizingMaskIntoConstraints = NO;
    _rankingLable.backgroundColor = RGB(196, 198, 209);
    _rankingLable.layer.cornerRadius=4.0f;
    _rankingLable.clipsToBounds = YES;
    [self.contentView addSubview:_rankingLable];
    
    _hotSearchTextLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x999999) textAlignment:NSTextAlignmentLeft numberOfLines:1];
 _hotSearchTextLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_hotSearchTextLable];
    CGFloat rankWidth = 16;
    CGFloat rankHeight = 16;
    //布局
    NSDictionary * _binds = @{@"rankingLable":_rankingLable,@"searchTextLable":_hotSearchTextLable};
    NSDictionary * _metrics = @{@"rankW":@(rankWidth), @"rankH":@(rankHeight)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rankingLable(==rankW@999)]-5@999-[searchTextLable]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rankingLable(==rankH)]" options:0 metrics:_metrics views:_binds]];
}
/**填充数据*/
-(void)filCellWithModel:(id)model row:(NSInteger)row
{
    if([model isKindOfClass:[AYBookModel class]])
    {
        AYBookModel *bookModel = (AYBookModel*)model;
        _rankingLable.text = [NSString stringWithFormat:@"%d",(int)(row+1)];
        _hotSearchTextLable.text = bookModel.bookTitle;
        if(row ==0)
        {
            _rankingLable.backgroundColor = RGB(254, 70, 25);
        }
        else if(row ==1)
        {
            _rankingLable.backgroundColor = RGB(254, 107, 1);
        }
        else if(row ==2)
        {
            _rankingLable.backgroundColor = RGB(254, 187, 0);
        }
        else
        {
            _rankingLable.backgroundColor = RGB(196, 198, 209);

        }
    }
}
@end
