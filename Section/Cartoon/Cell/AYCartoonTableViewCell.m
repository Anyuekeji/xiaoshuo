//
//  AYCartoonTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonTableViewCell.h"
#import "AYCartoonModel.h"
#import "AYUtitle.h"

@interface AYCartoonListCollectionViewCell()
@property (nonatomic, strong) UILabel *bookNameLable; //书名
@property (nonatomic, strong) UIImageView *bookCoverImageView; //书的封面

@end

@implementation AYCartoonListCollectionViewCell
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
    
    CGFloat imageWidth = CELL_BOOK_IMAGE_WIDTH;
    CGFloat imageHeight = CELL_BOOK_IMAGE_HEIGHT;
    //布局
    NSDictionary * _binds = @{@"name":_bookNameLable, @"Cover":_bookCoverImageView};
    NSDictionary * _metrics = @{@"imgW":@(imageWidth), @"imgH":@(imageHeight)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[name(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[Cover(==imgW@999)]-0-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[Cover(==imgH)]-2-[name]-5-|" options:0 metrics:_metrics views:_binds]];
}

/**填充数据*/
-(void)filCellWithModel:(id)model
{
    if([model isKindOfClass:[AYCartoonModel class]])
    {
        
        AYCartoonModel *bookModel = (AYCartoonModel*)model;
        _bookCoverImageView.contentMode = UIViewContentModeScaleToFill;
        _bookNameLable.text = bookModel.cartoonTitle;
        LEImageSet(_bookCoverImageView, bookModel.cartoonImageUrl, @"ws_register_example_company");
    }
}
@end

