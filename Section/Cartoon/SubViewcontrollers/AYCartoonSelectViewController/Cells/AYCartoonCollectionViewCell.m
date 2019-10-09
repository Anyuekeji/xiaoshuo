//
//  AYCartoonCollectionViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonCollectionViewCell.h"
#import "AYCartoonChapterModel.h"

@interface AYCartoonCollectionViewCell()
@property(nonatomic,strong)UIImageView *lockImage; //章节按钮
@property(nonatomic,strong)UILabel *chapterLable; //章节按钮

@end

@implementation AYCartoonCollectionViewCell
-(void)setSelected:(BOOL)selected
{
    if(selected)
    {
        [_chapterLable setBackgroundColor:RGB(250, 85, 108)];
        self.layer.borderWidth =0;
        [_chapterLable setTextColor:[UIColor whiteColor] ];
    }
    else
    {
        [_chapterLable setBackgroundColor:[UIColor whiteColor]];
        self.layer.borderWidth =0.3f;
        [_chapterLable setTextColor:RGB(51, 51, 51) ];

    }
}
- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}

-(void)configureUI
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *chapterLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    self.chapterLable = chapterLable;
    chapterLable.layer.borderWidth=0.5f;
    chapterLable.layer.borderColor=RGB(202, 202, 202).CGColor;
    chapterLable.layer.cornerRadius = 5.0f;
    chapterLable.frame =CGRectMake(2, 2, self.width-4, self.height-4);
    chapterLable.clipsToBounds= YES;
    [chapterLable setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:chapterLable];

    self.layer.cornerRadius = 0;
    self.layer.borderWidth = 0;
    self.layer.borderColor=[UIColor whiteColor].CGColor;
    self.clipsToBounds = YES;

    
    UIImageView *lockImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-13, 3, 9, 11)];
    lockImage.image = LEImage(@"read_lock");
    [self.contentView addSubview:lockImage];
    _lockImage = lockImage;
    
}
/**填充数据*/
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:[AYCartoonChapterModel class]])
    {
        AYCartoonChapterModel  *chapterModel = (AYCartoonChapterModel*)model;
        [_chapterLable setText:chapterModel.cartoonChapterTitle];
        if ([chapterModel.needMoney boolValue])
        {
            _lockImage.hidden = NO;
            if ([chapterModel.unlock boolValue]) {
                self.lockImage.image = LEImage(@"read_unlock");
            }
            else
            {
                self.lockImage.image = LEImage(@"read_lock");
            }
        }
        else
        {
            _lockImage.hidden = YES;
        }
    }
}
@end


@interface ALCartoonSelectHeadView()
@property (nonatomic, strong) UILabel *titleLable;
@end

@implementation ALCartoonSelectHeadView
- (instancetype) initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}

-(void)configureUI
{
    self.backgroundColor = [UIColor whiteColor];

    _titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    _titleLable.frame = CGRectMake(15, 0, self.width, self.height);
    _titleLable.backgroundColor  = [UIColor clearColor];
    [self addSubview:_titleLable];
}
/**填充数据*/
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:[NSString class]]) {
        _titleLable.text = model;
    }
}
@end
@implementation ALCartoonSelectFootView
- (instancetype) initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self configureUI];
    }
    return self;
}

-(void)configureUI
{
    self.backgroundColor = [UIColor whiteColor];
    UIImageView *arrImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-14)/2.0f, (self.height-22)/2.0f, 22, 22)];
    arrImage.image = LEImage(@"arry_right_black");
    arrImage.transform =CGAffineTransformMakeRotation(90 *M_PI / 180.0);
    [self addSubview:arrImage];
    
    static BOOL expand = NO;
    LEWeakSelf(self)
    [self addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        expand = !expand;
        arrImage.transform = CGAffineTransformIdentity;
        if (expand)
        {
            arrImage.transform=CGAffineTransformMakeRotation(-90 *M_PI / 180.0);
        }
        else
        {
            arrImage.transform=CGAffineTransformMakeRotation(90 *M_PI / 180.0);
        }
        if (self.ayClickFootAction) {
            self.ayClickFootAction(expand);
        }
    }];
}
@end
