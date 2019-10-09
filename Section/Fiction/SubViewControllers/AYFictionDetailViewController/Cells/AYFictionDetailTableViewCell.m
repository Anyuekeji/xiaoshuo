//
//  AYFictionDetailTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionDetailTableViewCell.h"
#import "AYFictionDetailModel.h"
#import "AYCartoonDetailTableViewCell.h" //漫画cell
#import "AYCartoonDetailModel.h"
#import "AYCartoonChapterContentModel.h" //章节内容model
#import "AYCommentTableViewCell.h"
#import "UIImageView+AY.h"

@implementation AYFictionDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

//书架介绍
@interface AYFictionDetailHeadTableViewCell()
@property(nonatomic,strong)UIImageView *fictionImageView;//小说图片
@property(nonatomic,strong)UIImageView *coinImageView;
@property(nonatomic,strong)UILabel *fictionTitleLable; //小说标题
@property(nonatomic,strong)UILabel *fictionIntroduceLable; //小说简介
@property(nonatomic,strong)UIView *fictionLevelAndGrade; //小说几星和评分
@property(nonatomic,strong)UILabel *fictionSectionLable; //小说章节
@property(nonatomic,strong)UILabel *fictionGradeLable; //小说分数l
@property(nonatomic,strong)AYFictionDetailModel *detailModel; //小说分数l

@end

@implementation AYFictionDetailHeadTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *fictionImageView = [UIImageView new];
    fictionImageView.contentMode = UIViewContentModeScaleAspectFill;
    fictionImageView.clipsToBounds = YES; fictionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:fictionImageView];
    _fictionImageView = fictionImageView;
    [_fictionImageView addCornorsWithValue:5.0f];

    LEWeakSelf(self)
    [fictionImageView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        //进入小说阅读
        LEStrongSelf(self)
        [ZWREventsManager sendViewControllerEvent:kEventAYFuctionReadViewController parameters:self.detailModel];
    }];
    
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:2];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
   // titleLable.preferredMaxLayoutWidth =
    [self.contentView addSubview:titleLable];
    _fictionTitleLable = titleLable;
    
    UILabel *introduceLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(53, 53, 53) textAlignment:NSTextAlignmentLeft numberOfLines:2];
    introduceLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:introduceLable];
    _fictionIntroduceLable = introduceLable;
    
    UILabel *sectionLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE] textColor:UIColorFromRGB(0xfa556c) textAlignment:NSTextAlignmentLeft numberOfLines:1];
   sectionLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:sectionLable];
    _fictionSectionLable = sectionLable;
    
    UIView *levelView = [UIView new];
    levelView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:levelView];
    _fictionLevelAndGrade = levelView;
    for (int i=0; i<5; i++)
    {
        UIImageView* starView = [[UIImageView alloc] initWithImage:LEImage(@"stat_shadow")];
        starView.frame = CGRectMake(i*(12+5), 0, 12, 12);
        starView.tag = 1324+i;
        [levelView addSubview:starView];
    }
//    UILabel *gradeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentLeft numberOfLines:1];
//    gradeLable.frame = CGRectMake(5*(12+5), 1, 40, 12);
//    [levelView addSubview:gradeLable];
//    _fictionGradeLable = gradeLable;
    [self layoutUI];
}

-(void)layoutUI
{
    NSDictionary * _binds = @{@"fictionImageView":self.fictionImageView, @"fictionTitleLable":self.fictionTitleLable, @"fictionIntroduceLable":self.fictionIntroduceLable, @"fictionSectionLable":self.fictionSectionLable, @"fictionLevelAndGrade":self.fictionLevelAndGrade};
    
    //CGFloat fictionImgWidth =CELL_BOOK_IMAGE_HEIGHT;
   // CGFloat fictionImgWidth = ScreenWidth*75.0f/375.0f;
   // CGFloat fictionImgHeight =CELL_BOOK_IMAGE_HEIGHT;
    
    CGFloat introduceOriginx =15*2+CELL_BOOK_IMAGE_WIDTH;
    
    //_fictionIntroduceLable.preferredMaxLayoutWidth = ScreenWidth-introduceOriginx-15;
  ///  _fictionSectionLable.preferredMaxLayoutWidth = ScreenWidth-introduceOriginx-15;
    NSDictionary * _metrics = @{@"imgW":@(CELL_BOOK_IMAGE_WIDTH),@"imgH":@(CELL_BOOK_IMAGE_HEIGHT),@"originX":@(introduceOriginx)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[fictionImageView(==imgH@999)]-15-|" options:0 metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[fictionImageView(==imgW)]" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionTitleLable]-15-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionSectionLable]-15-|" options:0 metrics:_metrics views:_binds]];
    
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionIntroduceLable]-15-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-originX-[fictionLevelAndGrade]-15-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(18@999)-[fictionTitleLable]-(<=10@999)-[fictionIntroduceLable(==20)]-(<=14@999)-[fictionSectionLable(==13@999)]-(<=14@999)-[fictionLevelAndGrade(==13@999)]-(18@999)-|" options:0 metrics:_metrics views:_binds]];
}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYFictionDetailModel.class])
    {
        AYFictionDetailModel *fictionModel =(AYFictionDetailModel*)model;
        self.detailModel = fictionModel;
        LEImageSet(_fictionImageView, fictionModel.fictionImageUrl, @"ws_register_example_company");
         if([fictionModel.isfree integerValue]==4 )
         {
            [_fictionImageView addOrRemoveFreeFlag:YES];
         }
        if(self.ayGetFictionHeadImageView)
        {
            self.ayGetFictionHeadImageView(_fictionImageView);
        }
        _fictionTitleLable.text = fictionModel.fictionTitle;
        if([fictionModel.fiction_update_status integerValue]==1)
        {
            _fictionIntroduceLable.text = [NSString stringWithFormat:@"%@",fictionModel.fictionAuthor];
            _fictionSectionLable.text = AYLocalizedString(@"已完结");

        }
        else
        {
            _fictionIntroduceLable.text = [NSString stringWithFormat:@"%@ | %@",fictionModel.fictionAuthor,AYLocalizedString(@"连载中")];
            _fictionSectionLable.text = [NSString stringWithFormat:AYLocalizedString(@"最新：已更新%d章节"),[fictionModel.fiction_update_section integerValue]];

        }
        _fictionGradeLable.text = fictionModel.fictionGrade;
        int statNum = [fictionModel.fictionGrade intValue];
        for (int i=0; i<statNum; i++)
        {
            UIImageView *statImageView = [_fictionLevelAndGrade viewWithTag:1324+i];
            if (statImageView) {
                statImageView.image = LEImage(@"stat_light");
            }
        }
    }
    if ([model isKindOfClass:AYCartoonDetailModel.class])
    {
        AYCartoonDetailModel *fictionModel =(AYCartoonDetailModel*)model;
        LEImageSet(_fictionImageView, fictionModel.cartoonImageUrl, @"ws_register_example_company");
        _fictionTitleLable.text = fictionModel.cartoonTitle;
        _fictionIntroduceLable.text = fictionModel.cartoonAuthor;
        _fictionSectionLable.text = [NSString stringWithFormat:AYLocalizedString(@"共%d章"),[fictionModel.cartoonSumSection intValue]];
        _fictionGradeLable.text = fictionModel.cartoonGrade;
        int statNum = [fictionModel.cartoonStarNum intValue];
        for (int i=0; i<statNum; i++)
        {
            UIImageView *statImageView = [_fictionLevelAndGrade viewWithTag:1324+i];
            if (statImageView) {
                statImageView.image = LEImage(@"stat_light");
            }
        }
    }
}
@end

#import "AYCoinSelectView.h" //打赏金币选择
#import "AYCartoonContainViewController.h"

//打赏
@interface AYFictionDetailRewardTableViewCell()
@property(nonatomic,strong)UIView *userContainView;
@property(nonatomic,strong)UILabel *userNumLable; //小说标题
@property(nonatomic,strong)UIButton *rewardBtn; //小说简介

@property(nonatomic,strong)NSObject *model; //数据
@property(nonatomic,strong)UIScrollView *rewardScrollview; //打赏列表

@end

#define INTRODUCE_HEIGHT_DEFAULT  60

@implementation AYFictionDetailRewardTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
    UIView *containView = [UIView new];
    containView.layer.cornerRadius = 2.0f;
    containView.backgroundColor = RGB(255, 255, 255);
    containView.frame = CGRectMake(15, 0,ScreenWidth-30, 102);
    [self.contentView addSubview:containView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, containView.bounds.size.width-0, 1)];
    lineView.backgroundColor = RGB(247, 210, 202);
    [containView addSubview:lineView];
    
    UILabel *rewardLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(245, 109, 82) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    rewardLable.text = AYLocalizedString(@"打赏");
    rewardLable.backgroundColor = containView.backgroundColor;
    [rewardLable sizeToFit];
    CGFloat rewardWidth= LETextWidth(AYLocalizedString(@"打赏"), rewardLable.font);
    rewardLable.frame = CGRectMake((containView.bounds.size.width-rewardWidth)/2.0f, 11, rewardWidth, 11);

    [containView addSubview:rewardLable];

    _rewardScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(10, rewardLable.frame.origin.y+rewardLable.height+15, containView.width-20, 24)];
    [containView addSubview:_rewardScrollview];
    
    rewardWidth= LETextWidth(AYLocalizedString(@"打赏"), [UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE]);
    CGFloat originX= (containView.bounds.size.width-rewardWidth-50-14-25)/2.0f;
    UIImageView *coinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, _rewardScrollview.frame.origin.y+_rewardScrollview.height+11, 15, 15)];
    coinImageView.image = LEImage(@"wujiaoxin_select");
    [containView addSubview:coinImageView];
    
    _userNumLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:RGB(250, 85, 108) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    _userNumLable.frame = CGRectMake(coinImageView.frame.origin.x+14+3, coinImageView.frame.origin.y, 50, 14);
    [containView addSubview:_userNumLable];
    UIButton *rewardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rewardBtn setTitle:AYLocalizedString(@"打赏") forState:UIControlStateNormal];
    rewardBtn.backgroundColor = RGB(250, 85, 108);
    rewardBtn.frame = CGRectMake(_userNumLable.frame.origin.x+40+15, _userNumLable.frame.origin.y-4, rewardWidth+2, 20);
    [rewardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rewardBtn.layer.cornerRadius = 10;
    rewardBtn.clipsToBounds = YES;
    rewardBtn.titleLabel.font = [UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE];
    [containView addSubview:rewardBtn];
    LEWeakSelf(self)
    [rewardBtn addAction:^(UIButton *btn) {
        if ([self.model isKindOfClass:AYFictionDetailModel.class])
        {
            [AYCoinSelectView showCoinSelectViewInView:self.superview.superview.superview model:self.model success:^(NSString *rewardNum){
                LEStrongSelf(self)
                [self addRewarderToList:NO num:rewardNum];
            }];
        }
        else if ([self.model isKindOfClass:AYCartoonDetailModel.class])
        {
            
            [AYCoinSelectView showCoinSelectViewInView:self.superview.superview.superview model:self.model success:^(NSString *rewardNum){
                LEStrongSelf(self)
                [self addRewarderToList:NO num:rewardNum];
            }];
//            UIResponder *nextRes = self.nextResponder;
//            while (nextRes) {
//                if ([nextRes isKindOfClass:AYCartoonContainViewController.class])
//                {
//                    AYCartoonContainViewController *cartoonController = (AYCartoonContainViewController*)nextRes;
//                    [AYCoinSelectView showCoinSelectViewInView:self.superview.superview.superview model:self.model success:^(NSString *rewardNum){
//                        LEStrongSelf(self)
//                        [self addRewarderToList:NO num:rewardNum];
//                    }];
//                    break;
//                }
//                nextRes = nextRes.nextResponder;
//            }
        }
    }];
}
-(void)addRewarderToList:(BOOL)first num:(NSString*)rewardNum
{
    NSMutableArray<AYMeModel*> *rewardUserArray =nil;
    self.rewardScrollview.contentSize = CGSizeMake(0, self.rewardScrollview.contentSize.height);
    if ([self.model isKindOfClass:AYFictionDetailModel.class])
    {
        AYFictionDetailModel *fictionModel =(AYFictionDetailModel*)self.model;
        if(!first)
        {
            [fictionModel.fictionRewardUserArray insertObject:[AYUserManager userItem] atIndex:0];
            _userNumLable.text = [NSString stringWithFormat:@"%ld",(long)(_userNumLable.text?([_userNumLable.text integerValue]+[rewardNum integerValue]):[rewardNum integerValue])];

        }
        rewardUserArray =fictionModel.fictionRewardUserArray;
    }
    else if ([self.model isKindOfClass:AYCartoonDetailModel.class])
    {
        AYCartoonDetailModel *fictionModel =(AYCartoonDetailModel*)self.model;
        if(!first)
        {
            [fictionModel.cartoonRewardUserArray insertObject:[AYUserManager userItem] atIndex:0];
            _userNumLable.text = [NSString stringWithFormat:@"%ld",(long)(_userNumLable.text?([_userNumLable.text integerValue]+[rewardNum integerValue]):[rewardNum integerValue])];
        }
        rewardUserArray =fictionModel.cartoonRewardUserArray;

    }
    
    [self.rewardScrollview removeAllSubviews];
    [rewardUserArray enumerateObjectsUsingBlock:^(AYMeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         UIImageView * userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2+idx*(24+9), 0, 24, 24)];
         userImageView.layer.cornerRadius = 12.0f;
         userImageView.clipsToBounds = YES;
         userImageView.contentMode = UIViewContentModeScaleAspectFill;
         LEImageSet(userImageView, obj.myHeadImage, @"me_defalut_icon");
         [self.rewardScrollview addSubview:userImageView];
         self.rewardScrollview.contentSize = CGSizeMake(self.rewardScrollview.contentSize.width+31, self.rewardScrollview.contentSize.height);
     }];
    //不够一行，设置居中
    CGFloat scrolldis =self.rewardScrollview.width-self.rewardScrollview.contentSize.width;
     if(scrolldis>0)
     {
         CGFloat originx = scrolldis/2.0f; //居中的x坐标
         CGFloat rigihtMoveDis = originx -2; //居中需要向右移动的e距离
         [self.rewardScrollview.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             if ([obj isKindOfClass:UIImageView.class]) {
                 obj.left+=rigihtMoveDis;
             }
         }];
     }
    
}
-(void)fillCellWithModel:(id)model
{
    _model = model;
    [self addRewarderToList:YES num:0];

    if ([model isKindOfClass:AYFictionDetailModel.class])
    {
        AYFictionDetailModel *fictionModel =(AYFictionDetailModel*)model;
        _userNumLable.text = fictionModel.fictionRewardCoinNum;
    }
    else if ([model isKindOfClass:AYCartoonDetailModel.class])
    {
        AYCartoonDetailModel *fictionModel =(AYCartoonDetailModel*)model;
        _userNumLable.text = fictionModel.cartoonRewardCoinNum;

    }
}
+(CGFloat)cellHeight
{
    return 100.0f;
}
@end

#import "UIImage+YYAdd.h"

//简介
@interface AYFictionDetailIntroduceTableViewCell()
@property(nonatomic,strong)UILabel *introduceLable; //简介
@property(nonatomic,strong)id dataModel; //箭头
@property(nonatomic,assign)BOOL isExpand; //箭头
@property(nonatomic,assign)BOOL needExpand; //是否可以扩展
@property(nonatomic,assign )NSInteger initLenth; //收起模式显示的字符数
@property(nonatomic,strong )NSMutableAttributedString *expandMutableStr; //扩展模式字符c
@property(nonatomic,strong )NSMutableAttributedString *unexpandMutableStr; //收起模式

@end

static BOOL expand = NO; //是否扩展

static CGFloat introduceTextHeight =0;

#define  AYINTRODUCE_DEFAULT_HEIGHT 80

@implementation AYFictionDetailIntroduceTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
    expand = NO;
//    UILabel  *introduceNameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
//    introduceNameLable.text = AYLocalizedString(@"简介");
//    introduceNameLable.frame = CGRectMake(15, 6, 200, 15);
  //  [self.contentView addSubview:introduceNameLable];
    _introduceLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    _introduceLable.frame = CGRectMake(15, 6, ScreenWidth-30, AYINTRODUCE_DEFAULT_HEIGHT);
    [self.contentView  addSubview:_introduceLable];
 
    LEWeakSelf(self)
    [_introduceLable addTapGesutureRecognizer:^(UITapGestureRecognizer *ges)
    {
        LEStrongSelf(self)
        if (!self.needExpand) {
            return;
        }
        self.isExpand = !self.isExpand;
        expand = self.isExpand;
        if ([self.dataModel isKindOfClass:AYFictionDetailModel.class])
        {
            //只更新高度，不更新内容
            [[self getTableView] beginUpdates];
            [[self getTableView] endUpdates];
            AYFictionDetailModel *detailModel = self.dataModel;
            [UIView animateWithDuration:0.2 animations:^{
                self.introduceLable.height = self.isExpand? introduceTextHeight:AYINTRODUCE_DEFAULT_HEIGHT;
                [self setIntroduceLableText:detailModel.fictionIntroduce];
           
            }];
            
        }
    }];
}
-(UITableView*)getTableView
{
    UIResponder *nextRes = self.nextResponder;
    while (nextRes) {
        if ([nextRes isKindOfClass:UITableView.class]) {
            return (UITableView*)nextRes;
        }
        nextRes = nextRes.nextResponder;
    }
    return nil;
}
-(void)fillCellWithModel:(id)model
{
    _dataModel = model;
    if ([model isKindOfClass:AYFictionDetailModel.class])
    {
        AYFictionDetailModel *fictionModel =(AYFictionDetailModel*)model;
        if(fictionModel.fictionIntroduce && fictionModel.fictionIntroduce.length>0)
        {
            NSAttributedString *initAttributeStr = [self getAttr:[[NSAttributedString alloc] initWithString:fictionModel.fictionIntroduce]];
               CGFloat introduceHeight =[AYUtitle getAttributedStringHeight:initAttributeStr width:_introduceLable.width attribute:[self introduceAttributes]];
                 if(introduceHeight>AYINTRODUCE_DEFAULT_HEIGHT)
                {
                    introduceTextHeight = [AYUtitle getAttributedStringHeight:[self getExpandAttributedString:fictionModel.fictionIntroduce] width:_introduceLable.width attribute:[self introduceAttributes]];
                    self.needExpand = YES;
                    [self setIntroduceLableText:fictionModel.fictionIntroduce];
                }
               else
               {
                   introduceTextHeight =introduceHeight;
                   self.needExpand = NO;
                    _introduceLable.attributedText = initAttributeStr;
               }
        }
    }
    else if ([model isKindOfClass:AYCartoonDetailModel.class])
    {
        AYCartoonDetailModel *fictionModel =(AYCartoonDetailModel*)model;
        _introduceLable.attributedText = [self getAttr:[[NSAttributedString alloc] initWithString:fictionModel.cartoonIntroduce]];
    }
}
-(NSMutableAttributedString*)getExpandAttributedString:(NSString*)intrContent
{
       if (!_expandMutableStr)
       {
           NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
           backAttachment.image = [[UIImage imageNamed:@"arry_right"] imageByRotateLeft90];
           backAttachment.bounds = CGRectMake(0, 0, 12, 7);
           NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
           NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:intrContent];
           NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
           [newAttributString appendAttributedString:secondString];
           [orginalAttributString appendAttributedString:newAttributString];
           _expandMutableStr = [self getAttr:orginalAttributString];
       }
    return _expandMutableStr;
}

-(NSMutableAttributedString*)getUnExpandAttributedString:(NSString*)intrContent
{
    if (!_unexpandMutableStr)
    {
        NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
        backAttachment.image =[[UIImage imageNamed:@"arry_right"] imageByRotateRight90];
        backAttachment.bounds = CGRectMake(0, 0, 12, 7);
        NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
        NSString *noExpandStr = [intrContent substringToIndex:[AYUtitle strLenthToSize:_introduceLable.size str:intrContent attribute:[self introduceAttributes]]];
        noExpandStr = [noExpandStr stringByAppendingString:@"..."];
        NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:noExpandStr];
        NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
        [newAttributString appendAttributedString:secondString];
        [orginalAttributString appendAttributedString:newAttributString];
        _unexpandMutableStr = [self getAttr:orginalAttributString];
    }
    return _unexpandMutableStr;
}
-(void)setIntroduceLableText:(NSString*)introContent
{
    self.introduceLable.attributedText = self.isExpand?[self getExpandAttributedString:introContent]:[self getUnExpandAttributedString:introContent];
}
- (NSMutableAttributedString*)getAttr:(NSAttributedString*)str
{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:str];
    [attributedString addAttributes:[self introduceAttributes] range:NSMakeRange(0, str.length)];
    return [attributedString copy];
}
- (NSDictionary *)introduceAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:_introduceLable.font ,
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
    
  //   [UIColorredColor],NSForegroundColorAttributeName,
}

+(CGFloat)cellHeight
{
    if (!expand)
    {
        return AYINTRODUCE_DEFAULT_HEIGHT+10.0f;
    }
    else
    {
        return introduceTextHeight+15.0f;
    }
}
@end


@interface AYFictionDetailMenuTableViewCell()
@property(nonatomic,strong)AYFictionDetailModel *detailModel; //小说分数l
@property(nonatomic,strong)UILabel *updateSectionLable; //小说分数l

@end
@implementation AYFictionDetailMenuTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
//    UIImageView* menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 16, 12)];
//    menuImageView.image = LEImage(@"menu_red");
//    [self.contentView addSubview:menuImageView];
    
    UILabel  *menuNameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    CGFloat menuWidth= LETextWidth(AYLocalizedString(@"目录"), menuNameLable.font);
    menuNameLable.text = AYLocalizedString(@"目录");
    menuNameLable.frame = CGRectMake(15, 10, menuWidth+3, 16);
    [self.contentView addSubview:menuNameLable];
    
    UILabel  *updateSectionLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:14] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentLeft numberOfLines:1];
 //   updateSectionLable.text = [NSString stringWithFormat:AYLocalizedString(@"更新%d章节"),];
    updateSectionLable.frame = CGRectMake(menuNameLable.left+menuNameLable.width,0, ScreenWidth-menuNameLable.left-menuNameLable.width-30, 36);
    [self.contentView addSubview:updateSectionLable];
    _updateSectionLable= updateSectionLable;
    
    UIImageView *arrayImageView = [UIImageView new];
    [self.contentView addSubview:arrayImageView];
    arrayImageView.frame = CGRectMake(ScreenWidth-16-15, 11, 16, 16);
    [arrayImageView setImage:LEImage(@"arry_right_black")];
    [self.contentView addSubview:arrayImageView];
    
}
-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYFictionDetailModel.class])
    {
        AYFictionDetailModel *fictDetailModel = (AYFictionDetailModel*)model;
        _updateSectionLable.text =([fictDetailModel.fiction_update_status integerValue]==1)?@"":[NSString stringWithFormat:AYLocalizedString(@"更新%d章节"),[fictDetailModel.fiction_update_section integerValue]];
        if ([fictDetailModel.fiction_update_status integerValue]==2) {
            _updateSectionLable.text  = [NSString stringWithFormat:@":%@",_updateSectionLable.text];
        }
    }
    if ([model isKindOfClass:AYCartoonDetailModel.class])
    {
//        AYCartoonDetailModel *fictDetailModel = (AYCartoonDetailModel*)model;
//        _updateSectionLable.text =([fictDetailModel.cartoon_update_status integerValue]==1)?@"":[NSString stringWithFormat:AYLocalizedString(@"更新%d章节"),[fictDetailModel.cartoon_update_status integerValue]];
//        if ([fictDetailModel.cartoon_update_status integerValue]==2) {
//            _updateSectionLable.text  = [NSString stringWithFormat:@":%@",_updateSectionLable.text];
//        }
    }
    
}
+(CGFloat)cellHeight
{
    return 36.0f;
}
@end
//评论
@interface AYFictionDetailInvationTableViewCell()
@property(nonatomic,strong)UILabel *titleLable; //标题

@end

//邀请
@implementation AYFictionDetailInvationTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
    UILabel  *menuNameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    menuNameLable.text = AYLocalizedString(@"邀请好友送金币");
    menuNameLable.frame = CGRectMake(15, 10, ScreenWidth-30, 16);
    [self.contentView addSubview:menuNameLable];
    self.titleLable = menuNameLable;
    
    UIImageView *arrayImageView = [UIImageView new];
    [self.contentView addSubview:arrayImageView];
    arrayImageView.frame = CGRectMake(ScreenWidth-15-15, 11, 16, 16);
    [arrayImageView setImage:LEImage(@"arry_right_black")];
    [self.contentView addSubview:arrayImageView];
}
-(void)fillCellWithModel:(id)model
{
    if ([model isEqualToString:@"charge"]) {
        self.titleLable.text = AYLocalizedString(@"我不会充值怎么办？");
    }
    else
    {
        self.titleLable.text = AYLocalizedString(@"邀请好友送金币");

    }
}
+(CGFloat)cellHeight
{
    return 36.0f;
}
@end


//评论
@interface AYDetailCommentHeadCell()
@property(nonatomic,strong)UIImageView *commentImageView;//评论图片
@property(nonatomic,strong)UILabel *commentLable; //标题

@property(nonatomic,strong)UILabel *commentMoreLable; //更多评论
@property(nonatomic,strong)id bookModel; //更多评论

@end

@implementation AYDetailCommentHeadCell

-(void)setUp
{
   [self configureUI];
}

-(void)configureUI
{
    UIImageView *commentImageView = [UIImageView new];
    commentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:commentImageView];
    commentImageView.image = LEImage(@"write_comment");
    _commentImageView = commentImageView;
    [commentImageView setEnlargeEdgeWithTop:6 right:6 bottom:6 left:6];
    [commentImageView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        NSDictionary *paraDic;
        if ([self.bookModel isKindOfClass:AYFictionDetailModel.class])
        {
            AYFictionDetailModel *fictionModel =(AYFictionDetailModel*)self.bookModel;
            paraDic = [NSDictionary dictionaryWithObjectsAndKeys:@(NO),@"cartoon",fictionModel.fictionID,@"bookId", nil];
        }
        else if ([self.bookModel isKindOfClass:AYCartoonDetailModel.class])
        {
            AYCartoonDetailModel *fictionModel =(AYCartoonDetailModel*)self.bookModel;
            paraDic = [NSDictionary dictionaryWithObjectsAndKeys:@(YES),@"cartoon",fictionModel.cartoonID,@"bookId", nil];
        }
        [ZWREventsManager sendViewControllerEvent:kEventAYWriteCommentViewController parameters:paraDic];
    }];
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:titleLable];
    titleLable.text = AYLocalizedString(@"评论(%@)");
    _commentLable = titleLable;
    [self layoutUI];
}

-(void)layoutUI
{
    NSDictionary * _binds = @{@"commentImageView":self.commentImageView, @"commentLable":self.commentLable};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[commentLable]-(>=15)-[commentImageView(==24)]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_binds]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[commentLable]-5-|" options:0 metrics:nil views:_binds]];
}

-(void)fillCellWithModel:(id)model
{
    _bookModel = model;
    if ([self.bookModel isKindOfClass:AYFictionDetailModel.class])
    {
       AYFictionDetailModel *fictDetailModel = (AYFictionDetailModel*)model;
      _commentLable.text = [NSString stringWithFormat:AYLocalizedString(@"评论(%@)"),[fictDetailModel.fictionSumComment stringValue]];
    }
    else if ([self.bookModel isKindOfClass:AYCartoonDetailModel.class])
    {
        AYCartoonDetailModel *fictDetailModel = (AYCartoonDetailModel*)model;
        _commentLable.text = [NSString stringWithFormat:AYLocalizedString(@"评论(%@)"),[fictDetailModel.cartoonSumComment stringValue]];
    }
}
+(CGFloat)cellHeight
{
    return 36;
}
@end

//评论底部cell
@interface AYDetailCommentFooterCell()
@property(nonatomic,strong)id bookModel; //更多评论
@end
@implementation AYDetailCommentFooterCell

-(void)setUp
{
    [self configureUI];
}

-(void)configureUI
{
    UILabel *moreLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    moreLable.frame = CGRectMake(0, 0, ScreenWidth, 40);
    moreLable.text = AYLocalizedString(@"查看更多的评论");
    moreLable.textAlignment= NSTextAlignmentCenter;
    [self.contentView addSubview:moreLable];
    LEWeakSelf(self)
    [moreLable addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        if ([self.bookModel isKindOfClass:AYFictionDetailModel.class])
        {
            AYFictionDetailModel *fictionModel = (AYFictionDetailModel*)self.bookModel;
            NSDictionary  *paraDic = [NSDictionary dictionaryWithObjectsAndKeys:@(AYCommentTypeFiction),@"type",fictionModel.fictionID,@"book_id", nil];
            [ZWREventsManager sendViewControllerEvent:kEventAYCommentViewController parameters:paraDic];
        }
        else if ([self.bookModel isKindOfClass:AYCartoonDetailModel.class])
        {
            AYCartoonDetailModel *fictionModel = (AYCartoonDetailModel*)self.bookModel;
            NSDictionary  *paraDic = [NSDictionary dictionaryWithObjectsAndKeys:@(AYCommentTypeCartoon),@"type",fictionModel.cartoonID,@"book_id", nil];
            [ZWREventsManager sendViewControllerEvent:kEventAYCommentViewController parameters:paraDic];
        }

    }];
}
-(void)fillCellWithModel:(id)model
{
    _bookModel = model;
}
+(CGFloat)cellHeight
{
    return 40;
}
@end
#import "AYFictionModel.h"

//热门推荐
@interface AYFictionDetailRecommentTableViewCell()
@property(nonatomic,strong)UIScrollView *bookRecommendScrollview;//推荐view
@end
@implementation AYFictionDetailRecommentTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    UILabel  *introduceNameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    introduceNameLable.text = AYLocalizedString(@"热门推荐");
    introduceNameLable.frame = CGRectMake(15, 10, 200, 13);
    [self.contentView addSubview:introduceNameLable];
    
    UIScrollView *scrollview = [UIScrollView new];
    [self.contentView addSubview:scrollview];
    scrollview.frame = CGRectMake(0,33, ScreenWidth ,205.0f-33);
    scrollview.scrollEnabled = YES;
    scrollview.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:scrollview];
    _bookRecommendScrollview = scrollview;
    scrollview.scrollEnabled = NO;
}
-(UIView*)bookItemView:(id)bookModel frame:(CGRect)frame imageHeight:(CGFloat)imageHeight
{
    BOOL fiction = [bookModel isKindOfClass:AYFictionModel.class];
    
    UIView* bookView = [[UIView alloc] initWithFrame:frame];
    UIImageView *fictionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, imageHeight)];
    LEImageSet(fictionImageView,(fiction?((AYFictionModel*)bookModel).fictionImageUrl:((AYCartoonDetailModel*)bookModel).cartoonImageUrl), @"ws_register_example_company");
    [bookView addSubview:fictionImageView];
    [fictionImageView addCornorsWithValue:4.0f];
    
    UILabel *bookNmaeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:3];
    bookNmaeLable.preferredMaxLayoutWidth = frame.size.width;
    bookNmaeLable.frame = CGRectMake(fictionImageView.frame.origin.x, fictionImageView.frame.size.height+1, fictionImageView.frame.size.width, frame.size.height-imageHeight-15);
    [bookView addSubview:bookNmaeLable];
    bookNmaeLable.text = (fiction?((AYFictionModel*)bookModel).fictionTitle:((AYCartoonDetailModel*)bookModel).cartoonTitle);
//    CGFloat nameHeight = LETextHeight(bookNmaeLable.text, bookNmaeLable.font, bookNmaeLable.width);
//    bookNmaeLable.height = nameHeight+20;
//    bookNmaeLable.top = fictionImageView.frame.size.height;
    return bookView;
}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYFictionDetailModel.class])
    {
        CGFloat fictionImgWidth = ScreenWidth*75.0f/375.0f;
        CGFloat fictionImgHeight =fictionImgWidth*100.0f/75.0f;
        CGFloat dis_x = (ScreenWidth-4*fictionImgWidth-12*2)/3.0f;
        AYFictionDetailModel *fictionModel =(AYFictionDetailModel*)model;
        [fictionModel.recommentFictionList enumerateObjectsUsingBlock:^(AYFictionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           UIView *subView= [self bookItemView:obj frame:CGRectMake(12+idx*(fictionImgWidth+dis_x), 0, fictionImgWidth, 205.0f-30) imageHeight:fictionImgHeight];
            [subView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
                [ZWREventsManager sendViewControllerEvent:kEventAYFictionDetailViewController parameters:obj];
            }];
            [self.bookRecommendScrollview addSubview:subView];
            self.bookRecommendScrollview.contentSize = CGSizeMake(self.bookRecommendScrollview.contentSize.width+subView.width+dis_x, 0);

        }];
    }
    if ([model isKindOfClass:AYCartoonDetailModel.class])
    {
        CGFloat fictionImgWidth = ScreenWidth*75.0f/375.0f;
        CGFloat fictionImgHeight =fictionImgWidth*100.0f/75.0f;
        CGFloat dis_x = (ScreenWidth-4*fictionImgWidth-12*2)/3.0f;

        AYCartoonDetailModel *fictionModel =(AYCartoonDetailModel*)model;
        [fictionModel.cartoonRecommendList enumerateObjectsUsingBlock:^(AYCartoonModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *subView= [self bookItemView:obj frame:CGRectMake(12+idx*(fictionImgWidth+dis_x), 0, fictionImgWidth, self.height-36) imageHeight:fictionImgHeight];
            [subView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
                [ZWREventsManager sendViewControllerEvent:kEventAYNewCartoonDetailViewController parameters:obj];
            }];
            [self.bookRecommendScrollview addSubview:subView];
            self.bookRecommendScrollview.contentSize = CGSizeMake(self.bookRecommendScrollview.contentSize.width+subView.width+dis_x, 0);
            
        }];
    }
}
+(CGFloat)cellHeight
{
    return 205.0f;
}
@end

@implementation AYFictionDetailTableViewEmptyCell
-(void)setUp
{
    [self configureUI];
}
-(void)configureUI
{
    self.contentView.backgroundColor = RGB(243, 243, 243);
}
+(CGFloat)cellHeight
{
    return 0;
}
@end


UIKIT_EXTERN void _AYFictionDetailCellsRegisterToTable(UITableView * tableView,int dataType)
{
    if (dataType ==0)
    {
        LERegisterCellForTable(AYFictionDetailHeadTableViewCell.class, tableView);
        
    }
    else if (dataType ==1)
    {
        LERegisterCellForTable(AYCartoonDetailTableViewCell.class, tableView);
         LEConfigurateCellBehaviorsFunctions([AYCartoonDetailTableViewCell class], @selector(fillCellWithModel: ),nil);
   

    }
    else if (dataType ==2)
    {
       LERegisterCellForTable(AYCartoonActionTableViewCell.class, tableView); LERegisterCellForTable(AYCartoonSwitchChapterTableViewCell.class, tableView);
    //LERegisterCellForTable(AYCartoonChapterContentTableViewCell.class, tableView);

    }
    LERegisterCellForTable(AYFictionDetailRewardTableViewCell.class, tableView);
    LERegisterCellForTable(AYFictionDetailIntroduceTableViewCell.class, tableView);
    LERegisterCellForTable(AYFictionDetailMenuTableViewCell.class, tableView);
    
    LERegisterCellForTable(AYFictionDetailInvationTableViewCell.class, tableView);
    
    LERegisterCellForTable(AYFictionDetailRecommentTableViewCell.class, tableView);
    
    LERegisterCellForTable(AYFictionDetailTableViewEmptyCell.class, tableView);
    
    LERegisterCellForTable(AYCommentTableViewCell.class,tableView);
    LEConfigurateCellBehaviorsFunctions([AYCommentTableViewCell class], @selector(fillCellWithModel: ),nil);
    
    LERegisterCellForTable(AYDetailCommentHeadCell.class, tableView);
    LERegisterCellForTable(AYDetailCommentFooterCell.class, tableView);
}
UIKIT_EXTERN UITableViewCell * _AYFictionDetailGetCellByItem(id object, int dataType,UITableView * tableView, NSIndexPath * indexPath, void(^fetchedEvent)(UITableViewCell * fetchCell))
{
    UITableViewCell * _fetchCell = nil;
    
    NSString *cellTypeStr = [object safe_objectAtIndex:0];
    id cellObj = [object safe_objectAtIndex:1];

    if ([cellTypeStr isEqualToString:@"head"]) {
        
        if (dataType ==0)
        {
            _fetchCell = LEGetCellForTable(AYFictionDetailHeadTableViewCell.class, tableView, indexPath);
            [((AYFictionDetailHeadTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
        }
        else  if (dataType ==1)
        {
            _fetchCell = LEGetCellForTable(AYCartoonDetailTableViewCell.class, tableView, indexPath);
            [((AYCartoonDetailTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
        }

    }
    else if ([cellTypeStr isEqualToString:@"cartoon_action"]) {
        _fetchCell = LEGetCellForTable(AYCartoonActionTableViewCell.class, tableView, indexPath);
        [((AYCartoonActionTableViewCell*)_fetchCell) fillCellWithModel:cellObj];

    }
    else if ([cellTypeStr isEqualToString:@"cartoon_chapter"]) {
        _fetchCell = LEGetCellForTable(AYCartoonSwitchChapterTableViewCell.class, tableView, indexPath);
    }
    else if ([cellTypeStr isEqualToString:@"empty"]) {
        _fetchCell = LEGetCellForTable(AYFictionDetailTableViewEmptyCell.class, tableView, indexPath);
    }
    else if ([cellTypeStr isEqualToString:@"reward"]) {
        _fetchCell = LEGetCellForTable(AYFictionDetailRewardTableViewCell.class, tableView, indexPath);
        [((AYFictionDetailRewardTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
    }
    else if ([cellTypeStr isEqualToString:@"introduce"]) {
        _fetchCell = LEGetCellForTable(AYFictionDetailIntroduceTableViewCell.class, tableView, indexPath);
        [((AYFictionDetailIntroduceTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
    }
    else if ([cellTypeStr isEqualToString:@"menu"]) {
        _fetchCell = LEGetCellForTable(AYFictionDetailMenuTableViewCell.class, tableView, indexPath);
        [((AYFictionDetailMenuTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
    }
    else if ([cellTypeStr isEqualToString:@"invate"]) {
        _fetchCell = LEGetCellForTable(AYFictionDetailInvationTableViewCell.class, tableView, indexPath);
        [((AYFictionDetailInvationTableViewCell*)_fetchCell) fillCellWithModel:cellTypeStr];

    }
    else if ([cellTypeStr isEqualToString:@"charge"]) {
        _fetchCell = LEGetCellForTable(AYFictionDetailInvationTableViewCell.class, tableView, indexPath);
        [((AYFictionDetailInvationTableViewCell*)_fetchCell) fillCellWithModel:cellTypeStr];
    }
    else if ([cellTypeStr isEqualToString:@"commenthead"]) {
        _fetchCell = LEGetCellForTable(AYDetailCommentHeadCell.class, tableView, indexPath);
          [((AYDetailCommentHeadCell*)_fetchCell) fillCellWithModel:cellObj];
        
    }
    else if ([cellTypeStr isEqualToString:@"commentfoot"]) {
        _fetchCell = LEGetCellForTable(AYDetailCommentFooterCell.class, tableView, indexPath);
            [((AYDetailCommentFooterCell*)_fetchCell) fillCellWithModel:cellObj];
        
    }
    else if ([cellTypeStr isEqualToString:@"comment"]) {
//        _fetchCell = LEGetCellForTable(AYFictionDetailCommentTableViewCell.class, tableView, indexPath);
//        [((AYFictionDetailCommentTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
        _fetchCell = LEGetCellForTable(AYCommentTableViewCell.class, tableView, indexPath);
        [((AYCommentTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
    }
    else if ([cellTypeStr isEqualToString:@"recomment"]) {
        _fetchCell = LEGetCellForTable(AYFictionDetailRecommentTableViewCell.class, tableView, indexPath);
        [((AYFictionDetailRecommentTableViewCell*)_fetchCell) fillCellWithModel:cellObj];
    }
    //触发事件构成
    if ( _fetchCell && fetchedEvent ) {
        fetchedEvent(_fetchCell);
    } else if ( !_fetchCell ) {
        Debug(@">> 未能找到Cell，此提示出现将引发崩溃！\n");
    }
    return _fetchCell;
}
UIKIT_EXTERN CGFloat _AYFictionDetailCellHeightByItem(id object,NSIndexPath * indexPath,int dataType)
{

    NSString *cellTypeStr = [object safe_objectAtIndex:0];
    id cellObj = [object safe_objectAtIndex:1];
    if ([cellTypeStr isEqualToString:@"head"]) {
        
        if (dataType ==0)
        {
            return  LEGetHeightForCellWithObject(AYFictionDetailHeadTableViewCell.class, cellObj, nil);
        }
        else if (dataType ==1)
        {
            return  LEGetHeightForCellWithObject(AYCartoonDetailTableViewCell.class, cellObj, nil);
        }
    }
    else if ([cellTypeStr isEqualToString:@"cartoon_action"]) {
    
        return  LEGetHeightForCellWithObject(AYCartoonActionTableViewCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"cartoon_chapter"]) {

            return  LEGetHeightForCellWithObject(AYCartoonSwitchChapterTableViewCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"empty"]) {
        
        return  LEGetHeightForCellWithObject(AYFictionDetailTableViewEmptyCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"reward"]) {
        return  LEGetHeightForCellWithObject(AYFictionDetailRewardTableViewCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"introduce"]) {
        return  LEGetHeightForCellWithObject(AYFictionDetailIntroduceTableViewCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"menu"]) {
        
        return  LEGetHeightForCellWithObject(AYFictionDetailMenuTableViewCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"invate"] || [cellTypeStr isEqualToString:@"charge"]) {
        
        return  LEGetHeightForCellWithObject(AYFictionDetailInvationTableViewCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"commenthead"]) {
        return  LEGetHeightForCellWithObject(AYDetailCommentHeadCell.class, cellObj, nil);
        
    }
    else if ([cellTypeStr isEqualToString:@"commentfoot"]) {
        return  LEGetHeightForCellWithObject(AYDetailCommentFooterCell.class, cellObj, nil);
        
    }
    else if ([cellTypeStr isEqualToString:@"comment"]) {
        
        return  LEGetHeightForCellWithObject(AYCommentTableViewCell.class, cellObj, nil);
    }
    else if ([cellTypeStr isEqualToString:@"recomment"]) {
        return  LEGetHeightForCellWithObject(AYFictionDetailRecommentTableViewCell.class, cellObj, nil);
    }

    return 0;
}
