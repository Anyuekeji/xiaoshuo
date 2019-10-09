//
//  AYTaskTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/8.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYTaskTableViewCell.h"
#import "UIImage+YYAdd.h"
#import "AYBookModel.h" //书本model
#import "AYTaskDayItem.h" //书本model
#import "UIImageView+AY.h"
#import "AYFictionModel.h"

@interface AYTaskTableViewCell()
@property(nonatomic,strong)UIImageView *taskImageView;//icon图片
@property(nonatomic,strong)UILabel *taskTitleLable; //小说标题
@property(nonatomic,strong)UILabel *taskIntroduceLable; //小说简介
@property(nonatomic,strong)UIButton *taskGetBtn; //领取按钮

@end
@implementation AYTaskTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
    [self bottomLineRightMoveWithValue:20];
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 5.0f;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:imageView];
    _taskImageView = imageView;
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_BIG_FONTSIZE] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:titleLable];
    _taskTitleLable = titleLable;
    UILabel *introduceLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:UIColorFromRGB(0xff5067) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    introduceLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:introduceLable];
    _taskIntroduceLable = introduceLable;
    
    
    UIButton *getBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    getBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [getBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xff6666)] forState:UIControlStateNormal];
    [getBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xffffff)] forState:UIControlStateSelected];
    [getBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getBtn setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateSelected];
    [getBtn setTitle:AYLocalizedString(@"领取") forState:UIControlStateNormal];
    [getBtn setTitle:AYLocalizedString(@"明日再来") forState:UIControlStateSelected];
    getBtn.userInteractionEnabled= NO;
    getBtn.layer.cornerRadius = 13.0f;
    getBtn.clipsToBounds = YES;
    getBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    getBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.contentView addSubview:getBtn];
    _taskGetBtn = getBtn;
    [self layoutUI];
}
-(void)layoutUI
{
    NSDictionary * _binds = @{@"taskImageView":self.taskImageView, @"taskGetBtn":self.taskGetBtn, @"taskTitleLable":self.taskTitleLable, @"taskIntroduceLable":self.taskIntroduceLable};
    
    
    
    CGFloat taskImgWidth = 26;
    CGFloat taskImgHeight =26;
    
    CGFloat introduceOriginx =20*2+taskImgWidth;
    
    self.taskIntroduceLable.preferredMaxLayoutWidth= ScreenWidth-introduceOriginx-112;
    self.taskTitleLable.preferredMaxLayoutWidth= ScreenWidth-introduceOriginx-112;
    
    NSDictionary * _metrics = @{@"imgW":@(taskImgWidth),@"imgH":@(taskImgHeight),@"originX":@(introduceOriginx)};
    
    // [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[taskImageView(==imgH@999)]-25-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.taskImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.taskImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:taskImgWidth]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[taskImageView(==imgW)]-20-[taskTitleLable]-10-[taskGetBtn(==82@999)]-20-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[taskIntroduceLable]" options:NSLayoutFormatAlignAllCenterY metrics:_metrics views:_binds]];
    
    
    if (isIPhone4 || isIPhone5)
    {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==11@999)-[taskTitleLable]-(==10@999)-[taskIntroduceLable]-11@999-|" options:0 metrics:_metrics views:_binds]];
    }
    else
    {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==18@999)-[taskTitleLable]-(==10@999)-[taskIntroduceLable]-18@999-|" options:0 metrics:_metrics views:_binds]];
    }
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.taskGetBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.taskGetBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:27.0f]];
}
-(void)setIntroduceLableText:(UIImage*)attachmentImage text:(NSString*)introduceText
{
    NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = attachmentImage;
    backAttachment.bounds = CGRectMake(0, -2, 14, 14);
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:introduceText];
    NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    [orginalAttributString appendAttributedString:newAttributString];
    self.taskIntroduceLable.attributedText = orginalAttributString;
}
-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYTaskDayItem.class])
    {
        AYTaskDayItem *taskItem =(AYTaskDayItem*)model;
        self.taskTitleLable.text = taskItem.itmeTitle;
        if ([taskItem.itmeImage isEqualToString:@"task_invite"]) {
            
            NSString* loginRewardNum  = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultInvitaLoginReward];
            self.taskIntroduceLable.text = [NSString stringWithFormat:taskItem.itmeIntroduce,loginRewardNum?loginRewardNum:@"500"];
            
        }
        else
        {
            self.taskIntroduceLable.text = taskItem.itmeIntroduce;
        }
        
        [self.taskGetBtn setTitle:taskItem.itemAction forState:UIControlStateNormal];
        if (([taskItem.itmeImage isEqualToString:@"task_adverse"] || [taskItem.itmeImage isEqualToString:@"task_charge_friend"]) && (isIPhone4 || isIPhone5)) {
            self.taskTitleLable.font = [UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE];
        }
        else
        {
            self.taskTitleLable.font = [UIFont systemFontOfSize:DEFAUT_BIG_FONTSIZE];
            
        }
        if ([taskItem.itmeImage isEqualToString:@"task_adverse"] && [taskItem.itmeIntroduce containsString:AYLocalizedString(@"今日剩余")])//显示今日广告剩余次数不显示金币icon
        {
        }
        else
        {
            [self setIntroduceLableText:taskItem.itemFinish?LEImage(@"wujiaoxin"):LEImage(@"wujiaoxin_select") text:self.taskIntroduceLable.text];
        }
        if(taskItem.itemFinish)
        {
            if (taskItem.advertiseLoading) {
                [self.taskGetBtn setTitle:AYLocalizedString(@"努力加载中") forState:UIControlStateNormal];
                
            }
            else
            {
                self.taskGetBtn.selected = YES;
            }
            self.taskGetBtn.layer.borderWidth = 1.0f;
            self.taskGetBtn.layer.borderColor= UIColorFromRGB(0xE8E8E8).CGColor;
            self.taskImageView.image = LEImage(taskItem.itemFinishImage);
            self.taskTitleLable.textColor= UIColorFromRGB(0x999999);
            self.taskIntroduceLable.textColor =UIColorFromRGB(0x999999);
            
        }
        else
        {
            self.taskGetBtn.selected = NO;
            self.taskGetBtn.layer.borderWidth = 0.0f;
            self.taskImageView.image = LEImage(taskItem.itmeImage);
            self.taskTitleLable.textColor= UIColorFromRGB(0x333333);
            self.taskIntroduceLable.textColor =UIColorFromRGB(0xff5067);
        }
    }
}
//+(CGFloat)cellHeight
//{
//    return TASK_CELL_HEIGHT;
//}
@end

@implementation AYTaskTableViewEmptyCell
-(void)setUp
{
    [self configureUI];
}
-(void)configureUI
{
    self.contentView.backgroundColor = UIColorFromRGB(0xf7f7f7);
}
+(CGFloat)cellHeight
{
    return 4.0f;
}
@end

#import "AYShareManager.h"

@interface AYTaskShareCell()
@property(nonatomic,strong)UIImageView *taskImageView;//小说图片
@property(nonatomic,strong)UILabel *taskTitleLable; //小说标题
@property(nonatomic,strong)UIButton *shareBtn; //分享按钮
@property(nonatomic,strong)id bookModel; //分享按钮

@end
@implementation AYTaskShareCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
    [self bottomLineRightMoveWithValue:20];
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
 imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:imageView];
    _taskImageView = imageView;
    
    
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:titleLable];
    _taskTitleLable = titleLable;
    
    UIButton *getBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    getBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [getBtn setTitleColor:UIColorFromRGB(0xfa556c) forState:UIControlStateNormal];
    [getBtn setTitleColor:UIColorFromRGB(0xfa556c) forState:UIControlStateSelected];
    [getBtn setTitle:AYLocalizedString(@"分享") forState:UIControlStateNormal];
    getBtn.layer.cornerRadius = 11.6f;
    getBtn.clipsToBounds = YES;
    getBtn.titleLabel.font = [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
    getBtn.layer.borderWidth = 1.0f;
    getBtn.layer.borderColor =UIColorFromRGB(0xfa556c).CGColor;
    [self.contentView addSubview:getBtn];
    _shareBtn = getBtn;
    LEWeakSelf(self)
    [getBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if ([self.bookModel isKindOfClass:AYBookModel.class]) {
            [AYShareManager ShareBookWith:self.bookModel parentView:[self getParentViewController].view];

        }
        if ([self.bookModel isKindOfClass:AYFictionModel.class]) {
            [AYShareManager ShareFictionWith:self.bookModel parentView:[AYUtitle getAppDelegate].window];
            
        }
    }];
    [self layoutUI];
}
-(void)layoutUI
{
    NSDictionary * _binds = @{@"taskImageView":self.taskImageView, @"shareBtn":self.shareBtn, @"taskTitleLable":self.taskTitleLable};
    
    
    CGFloat fictionImgWidth = CELL_BOOK_IMAGE_WIDTH;
    CGFloat fictionImgHeight =CELL_BOOK_IMAGE_HEIGHT;
    
    
    NSDictionary * _metrics = @{@"imgW":@(fictionImgWidth),@"imgH":@(fictionImgHeight)};
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-13-[taskImageView(==imgH@999)]-13-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[taskImageView(==imgW)]-20-[taskTitleLable]-10-[shareBtn(==65@999)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:_metrics views:_binds]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[shareBtn(==30@999)]" options:0 metrics:_metrics views:_binds]];
}
#pragma mark - private methods -
-(UIViewController*)getParentViewController
{
    UIResponder *nextResponser = self.nextResponder;
    while (nextResponser) {
        if ([nextResponser isKindOfClass:UIViewController.class]) {
            return (UIViewController*)nextResponser;
        }
        nextResponser = nextResponser.nextResponder;
    }
    return nil;
}
-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYBookModel.class])
    {
        AYBookModel *bookModel =(AYBookModel*)model;
        _bookModel = bookModel;
        LEImageSet(self.taskImageView, bookModel.bookImageUrl, @"ws_register_example_company");
        self.taskTitleLable.text = bookModel.bookTitle;
        if ([bookModel.isfree integerValue]==4)//免费
        {
            [self.taskImageView addOrRemoveFreeFlag:YES];
        }
        else
        {
            [self.taskImageView addOrRemoveFreeFlag:NO];

        }
    }
    if ([model isKindOfClass:AYFictionModel.class])
    {
        AYFictionModel *bookModel =(AYFictionModel*)model;
        _bookModel = bookModel;
        LEImageSet(self.taskImageView, bookModel.fictionImageUrl, @"ws_register_example_company");
        self.taskTitleLable.text = bookModel.fictionTitle;
        if ([bookModel.isfree integerValue]==4)//免费
        {
            [self.taskImageView addOrRemoveFreeFlag:YES];
        }
        else
        {
            [self.taskImageView addOrRemoveFreeFlag:NO];
            
        }
    }
}

@end
