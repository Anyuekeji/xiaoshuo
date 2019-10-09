//
//  AYBookrackCollectionViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/1.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBookrackCollectionViewCell.h"
#import "AYBookModel.h"
#import "AYCartoonReadModel.h" //漫画的阅读状态
#import "AYFictionReadModel.h" //存储当前小说阅读状态
#import "UIImageView+AY.h"

@interface AYBookrackCollectionViewCell()
@property (nonatomic, strong) UILabel *bookNameLable; //书名
@property (nonatomic, strong) UILabel *bookReadStatusLable; //书架阅读状态

@property (nonatomic, strong) UIButton *selectBtn; //是否选中
@property (nonatomic, strong) UILabel *recommentFlagView; //推荐标记view
@property (nonatomic, strong) AYBookModel *bookModel; //推荐标记view
@property(nonatomic,strong)UIView *freeViewFlag; //免费标记

@end

@implementation AYBookrackCollectionViewCell
- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}
-(void)setWillDelete:(BOOL)willDelete
{
    _willDelete = willDelete;
    if (_edit) {
        _selectBtn.selected  = willDelete;
        if (willDelete) {
            UIView *maskView = [[UIView alloc] initWithFrame:self.bookCoverImageView.bounds];
            [maskView setBackgroundColor:[UIColor blackColor]];
            maskView.alpha = 0.5f;
            maskView.tag = 5269;
            [self.bookCoverImageView addSubview:maskView];
        }
        else
        {
            UIView *maskView = [self.bookCoverImageView viewWithTag:5269];
            if (maskView)
            {
                [maskView removeFromSuperview];
                maskView = nil;
            }
        }
    }
}

-(void)configureUI
{
    _bookNameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:2];
    _bookNameLable.preferredMaxLayoutWidth =CELL_WIDTH;
    _bookNameLable.textAlignment = NSTextAlignmentCenter;
    _bookNameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_bookNameLable];
    
    _bookReadStatusLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:UIColorFromRGB(0x999999) textAlignment:NSTextAlignmentLeft numberOfLines:2];
    _bookReadStatusLable.textAlignment = NSTextAlignmentCenter; _bookReadStatusLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_bookReadStatusLable];
    
    _bookCoverImageView = [UIImageView new];
    _bookCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bookCoverImageView.clipsToBounds = YES;
   _bookCoverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_bookCoverImageView];
    [_bookCoverImageView addCornorsWithValue:5.0f];
    CGFloat imageWidth = CELL_WIDTH;
    CGFloat imageHeight = imageWidth*(12.5f/10.0f);
    //布局
    NSDictionary * _binds = @{@"name":_bookNameLable,@"statue":_bookReadStatusLable, @"Cover":_bookCoverImageView};
    NSDictionary * _metrics = @{@"imgW":@(imageWidth), @"imgH":@(imageHeight)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[name(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[statue(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[Cover(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[Cover(==imgH)]-2-[name]-1-[statue]-0-|" options:0 metrics:_metrics views:_binds]];
}
-(void)addSelectBtnToCell
{
    if (!_selectBtn) {
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn = selectBtn;
        _selectBtn.userInteractionEnabled = NO;
        [selectBtn setImage:LEImage(@"book_unselect") forState:UIControlStateNormal];
        [selectBtn setImage:LEImage(@"book_select") forState:UIControlStateSelected];
        selectBtn.frame = CGRectMake(self.bounds.size.width-22-5, self.bounds.size.height-35-22-23, 22, 22);
        [self.contentView addSubview:selectBtn];
    }

}
/**填充数据*/
-(void)filCellWithModel:(id)model
{
    _willDelete = NO;
    if([model isKindOfClass:[AYBookModel class]])
    {
        UIView *maskView = [self.bookCoverImageView viewWithTag:5269];
        if (maskView) {
            [maskView removeFromSuperview];
            maskView = nil;
        }
        if(_selectBtn)
        {
            self.willDelete = NO;
        }
        AYBookModel *bookModel = (AYBookModel*)model;
        _bookModel = bookModel;
        if(!bookModel.bookTitle || !bookModel.bookImageUrl)
        {
            _bookCoverImageView.contentMode = UIViewContentModeScaleToFill;
            [_bookCoverImageView setImage:LEImage(@"book_add")];
            _bookNameLable.text = @"";
            if (_selectBtn)
            {
                [_selectBtn removeFromSuperview];
                _selectBtn = nil;
            }
        }
        else
        {
            _bookCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
            _bookNameLable.text = bookModel.bookTitle;
   
            if ([bookModel.type integerValue] == 1)//小说
            {
                AYFictionReadModel *readModel = [self localFictionReadModel];
                if (readModel) {
                    _bookReadStatusLable.text =[NSString stringWithFormat:AYLocalizedString(@"已阅读%d"),[readModel.currrenReadSectionIndex intValue]+1];
                }
                else
                {
                    _bookReadStatusLable.text =AYLocalizedString(@"未读");

                }
            }
            if ([bookModel.type integerValue] == 2)//漫画
            {
                AYCartoonReadModel *readModel = [self localCartoonReadModel];
                if (readModel) {
                    _bookReadStatusLable.text =[NSString stringWithFormat:AYLocalizedString(@"已阅读%d"),[readModel.currrenReadSectionIndex intValue]+1];
                }
                else
                {
                    _bookReadStatusLable.text =AYLocalizedString(@"未读");
                }
            }
            if(![bookModel.isgroom boolValue]) //不为nil，不是推荐的书籍
            {
                [self addRecommendFlag:NO];
            }
            else{
                [self addRecommendFlag:YES];
            }
            if ([bookModel.isfree integerValue]==4)//免费
            {
                [self.bookCoverImageView addOrRemoveFreeFlag:YES];
            }
            else
            {
                [self.bookCoverImageView addOrRemoveFreeFlag:NO];
                
            }
            LEImageSet(_bookCoverImageView, bookModel.bookImageUrl, @"ws_register_example_company");
        }
    }
}
-(void)setEdit:(BOOL)edit
{
    _edit = edit;
    if (edit)
    {
        [self addSelectBtnToCell];
    }
    else
    {
        if (_selectBtn)
        {
            [_selectBtn removeFromSuperview];
            _selectBtn = nil;
            UIView *maskView = [self.bookCoverImageView viewWithTag:5269];
            if (maskView) {
                [maskView removeFromSuperview];
                maskView = nil;
            }
        }
    }
}
-(void)addRecommendFlag:(BOOL)add
{
    if (add)
            {
                if (!_recommentFlagView) {
                    _recommentFlagView = [UILabel lableWithTextFont:[UIFont systemFontOfSize:13] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentRight numberOfLines:1];
                    _recommentFlagView.text = AYLocalizedString(@"推荐");
                    [_recommentFlagView sizeToFit];
                    _recommentFlagView.frame = CGRectMake(self.width-_recommentFlagView.width,0, _recommentFlagView.width, 15);
                    _recommentFlagView.backgroundColor =RGB(205, 85, 108);
                }
                [self.contentView addSubview:_recommentFlagView];
    }
    else
    {
        if (_recommentFlagView) {
            [_recommentFlagView removeFromSuperview];
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
//        [self.bookCoverImageView addSubview:freeFlagLable];
//        freeFlagLable.text = AYLocalizedString(@"免费");
//        _freeViewFlag = freeFlagLable;
//        _freeViewFlag.frame = CGRectMake(-30, 8, 100, 20);
//        _freeViewFlag.transform =CGAffineTransformMakeRotation (-M_PI_4);
//    }
//}
+(CGFloat)cellHeight
{
    CGFloat imageWidth = CELL_WIDTH;
    return  imageWidth*(142.0f/100.0f)+43;
}

#pragma mark - db -
//获取本地小说的阅读状态
-(AYCartoonReadModel*)localCartoonReadModel
{
    NSString *qureyStr = [NSString stringWithFormat:@"cartoonID = '%@'",self.bookModel.bookID];
    NSArray<AYCartoonReadModel*> *readModelArray = [AYCartoonReadModel r_query:qureyStr];
    if (readModelArray && readModelArray.count>0) //已阅读过
    {
        AYCartoonReadModel *readModel = [readModelArray objectAtIndex:0];
        if (readModel) {
            return readModel;
        }
    }
    return nil;
}
//获取本地小说的阅读状态
-(AYFictionReadModel*)localFictionReadModel
{
    NSString *qureyStr = [NSString stringWithFormat:@"fictionID = '%@'",self.bookModel.bookID];
    NSArray<AYFictionReadModel*> *readModelArray = [AYFictionReadModel r_query:qureyStr];
    if (readModelArray && readModelArray.count>0) //已阅读过
    {
        AYFictionReadModel *readModel = [readModelArray objectAtIndex:0];
        if (readModel) {
            return readModel;
        }
    }
    return nil;
}
@end
