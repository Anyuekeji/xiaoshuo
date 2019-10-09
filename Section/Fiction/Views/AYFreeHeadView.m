//
//  AYFreeHeadView.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/22.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYFreeHeadView.h"
#import "LECountdownTimeView.h"

@interface AYFreeHeadView ()
@property(nonatomic,strong)LECountdownTimeView *timeView;//倒计时view

@end
@implementation AYFreeHeadView
-(instancetype)initWithFrame:(CGRect)frame  endTime:(NSInteger)endTime
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI:endTime];
    }
    return self;
}

-(void)configureUI:(long long)endTime
{
    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, (self.height-26)/2.0f, 26, 26)];
    iconImage.image = LEImage(@"Fiction_Free");
    [self addSubview:iconImage];
    
    UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(iconImage.left+iconImage.width+1, 0, 100, self.height)];
    timeLable.text = [NSString stringWithFormat:@"%@",AYLocalizedString(@"限时免费")];
    CGFloat titleWidth = LETextWidth(timeLable.text, timeLable.font);
    timeLable.width = titleWidth+2;
    timeLable.textColor= RGB(205, 85, 108);
    timeLable.textAlignment= NSTextAlignmentLeft;
    timeLable.font = [UIFont boldSystemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
    [self addSubview:timeLable];
    LECountdownTimeView *timeCountDownView = [[LECountdownTimeView alloc] initWithFrame:CGRectMake(timeLable.left+timeLable.width, 0, 200, self.height) endTime:endTime];
    [self addSubview:timeCountDownView];
    
    //arry_right
//    UILabel *moreLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:13] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentRight numberOfLines:1];
//    moreLable.frame = CGRectMake(ScreenWidth-30-100, 0, 100, self.height);
//  //  moreLable.text = AYLocalizedString(@"更多");
//    [self addSubview:moreLable];
    
    UIImageView *arrayImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-16-15, (self.height-16)/2.0f, 16, 16)];
    arrayImage.image = LEImage(@"arry_right_black");
    [self addSubview:arrayImage];
}

@end

@interface AYCommonHeadView()
@property(nonatomic,strong)UIImageView *iconImageView;
@end
@implementation AYCommonHeadView
-(instancetype)initWithFrame:(CGRect)frame  title:(NSString*)title icon:(NSString*)iconName
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI:title icon:iconName];
    }
    return self;
}

-(void)configureUI:(NSString*)title icon:(NSString*)iconName
{
    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, (self.height-26)/2.0f, 26, 26)];
    iconImage.image = LEImage(iconName);
    [self addSubview:iconImage];

    UILabel *recommendLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0xfa556c) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    recommendLable.text = AYLocalizedString(title);
    recommendLable.frame = CGRectMake(iconImage.left+iconImage.width+4, 0, self.width-30, self.height);
    [self addSubview:recommendLable];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    if (![title isEqualToString:@"热门畅销"]) {
        //arry_right
        UILabel *moreLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:13] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentRight numberOfLines:1];
        moreLable.frame = CGRectMake(ScreenWidth-15-16-100, 0, 100, self.height);
        moreLable.text =AYLocalizedString(@"更多");
        [self addSubview:moreLable];
        UIImageView *arrayImage = [[UIImageView alloc] init];
        arrayImage.frame=CGRectMake(ScreenWidth-15-14, (self.height-16)/2.0f, 16, 16);
        arrayImage.image = LEImage(@"arry_right_black");
        [self addSubview:arrayImage];
    }

}
#pragma mark - ui -

@end
@interface AYSearchHeadView()
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIImageView *iconImageview;

@end

@implementation AYSearchHeadView
- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}

-(void)configureUI
{
    self.backgroundColor = [UIColor whiteColor];
    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, (self.height-26)/2.0f, 26, 26)];
    iconImage.image = LEImage(@"task_read");
    [self addSubview:iconImage];
    _iconImageview = iconImage;
    
    _titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    _titleLable.frame = CGRectMake(iconImage.left +iconImage.width+5, 0, self.width, self.height);
    _titleLable.backgroundColor  = [UIColor clearColor];
    [self addSubview:_titleLable];
}
/**填充数据*/
-(void)filCellWithModel:(NSString*)title;
{
    if ([title isKindOfClass:[NSString class]]) {
        _titleLable.text = AYLocalizedString(title);
        _iconImageview.image =([title isEqualToString:AYLocalizedString(@"热门搜索")])?LEImage(@"Fiction_search_hot"):LEImage(@"Fiction_Search_book_hot");
    }
}
@end
