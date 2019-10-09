//
//  VideoEditMenu.m
//  VideoManager
//
//  Created by liuyunpeng on 2018/10/11.
//  Copyright © 2018年 AnYue. All rights reserved.
//

#import "LEItemView.h"

@interface LEItemView()
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *iconUrl;
@property (nonatomic,assign) BOOL isBigMode;
@property (nonatomic,assign) NSInteger itemNums;
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,strong) UIImageView *iconImageView;

@end


@implementation LEItemView

- (instancetype)initWithTitle:(NSString*)itemTitle icon:(NSString*)iconUrl isBigMode:(BOOL)isBigMode  numInOneLine:(NSInteger)num
{
    self = [super init];
    if (self) {
        _title = itemTitle;
        _iconUrl = iconUrl;
        _isBigMode = isBigMode;
        _itemNums = num;
        [self configureUi];
    }
    return self;
}
-(void)configureUi
{
    UIImageView *iconImageView  = [UIImageView new];
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    iconImageView.image = [UIImage imageNamed:_iconUrl];
    [self addSubview:iconImageView];
    _iconImageView = iconImageView;
    
    UILabel *titleLable = [UILabel new];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLable setTextColor:RGB(102, 102, 102)];
    
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.font = [UIFont systemFontOfSize:(_isBigMode?DEFAUT_NORMAL_FONTSIZE:DEFAUT_SMALL_FONTSIZE)];
    [self addSubview:titleLable];
    titleLable.text = _title;
    _titleLable = titleLable;
    CGFloat imageIconWidth = _isBigMode?56:42;
    
    CGFloat itemWidth = ScreenWidth/_itemNums;
    CGFloat xDis = (itemWidth-imageIconWidth)/2.0f;
    
    NSDictionary * _metrics = @{@"xdis":@(xDis),@"iconWidth":@(imageIconWidth)};
    //布局
    NSDictionary * _binds = @{@"titleLable":titleLable, @"iconImageView":iconImageView};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[titleLable]-2-|" options:0 metrics:_metrics views:_binds]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-xdis-[iconImageView]-xdis-|" options:0 metrics:_metrics views:_binds]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[iconImageView(==iconWidth)]-4-[titleLable(==16@999)]-(>=1@999)-|" options:NSLayoutFormatAlignAllCenterX metrics:_metrics views:_binds]];
    
}

@end
