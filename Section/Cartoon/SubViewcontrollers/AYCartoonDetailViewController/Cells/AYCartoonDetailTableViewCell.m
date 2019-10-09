//
//  AYCartoonTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonDetailTableViewCell.h"
#import "AYCartoonDetailModel.h"
#import "AYFictionDetailTableViewCell.h"

#define  AYCARTOONINTRODUCE_DEFAULT_HEIGHT 100

static BOOL expand = NO; //是否扩展

static CGFloat cartoonIntroduceTextHeight =0;

@interface AYCartoonDetailTableViewCell()
@property(nonatomic,strong)UILabel *autherLable;
@property(nonatomic,strong)UILabel *autherValueLable;//作者
@property(nonatomic,strong)UILabel *updateTimeLable; //更新时间
@property(nonatomic,strong)UILabel *updateTimeValueLable;
@property(nonatomic,strong)UILabel *introduceValueLable; //
//@property(nonatomic,strong)UILabel *introduceLable; //简介
@property(nonatomic,strong)UILabel *hotLable; //
@property(nonatomic,strong)UILabel *hotValueLable; //人气
@property(nonatomic,strong)UILabel *agreeLable; //
@property(nonatomic,strong)UILabel *agreeValueLable; //点赞
@property(nonatomic,strong)UILabel *collectLable; ///收藏
@property(nonatomic,strong)UILabel *collectValueLable; //收藏
@property(nonatomic,strong )NSMutableAttributedString *expandMutableStr; //扩展模式字符c
@property(nonatomic,strong )NSMutableAttributedString *unexpandMutableStr; //收起模式
@property(nonatomic,assign)BOOL isExpand; //箭头
@property(nonatomic,assign)BOOL needExpand; //是否可以扩展
@property(nonatomic,strong )AYCartoonDetailModel *cartoonDetailModle; //收起模式

@end
@implementation AYCartoonDetailTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
    UIView *topContainView  = [UIView new];
  topContainView.translatesAutoresizingMaskIntoConstraints = NO;
    topContainView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:topContainView];
    
    UILabel *autherLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    autherLable.text  = AYLocalizedString(@"作者");
    autherLable.frame = CGRectMake(15, 17, 120, 13);
    [topContainView addSubview:autherLable];
    _autherLable = autherLable;
    
    autherLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    autherLable.text  = AYLocalizedString(@"状态");
    autherLable.frame = CGRectMake(ScreenWidth-120-70, 17, 140, 13);
    [topContainView addSubview:autherLable];
    _updateTimeLable = autherLable;
    
    autherLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    autherLable.frame = CGRectMake(15, 35, 120, 25);
    [topContainView addSubview:autherLable];
    _autherValueLable = autherLable;
    //[_autherValueLable sizeToFit];
    
    autherLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    autherLable.frame = CGRectMake(_updateTimeLable.left, _autherValueLable.top, 140, 25);
    [topContainView addSubview:autherLable];
    _updateTimeValueLable = autherLable;
    
    
    UIView *centerContainView  = [UIView new];
    centerContainView.translatesAutoresizingMaskIntoConstraints = NO;
    centerContainView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:centerContainView];
    
//    autherLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentLeft numberOfLines:1];
//    autherLable.text  = AYLocalizedString(@"简介");
//    autherLable.translatesAutoresizingMaskIntoConstraints = NO;
//    [centerContainView addSubview:autherLable];
//    _introduceLable = autherLable;
    
    autherLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    autherLable.translatesAutoresizingMaskIntoConstraints = NO;
    autherLable.preferredMaxLayoutWidth = ScreenWidth-60;
    [centerContainView addSubview:autherLable];
    _introduceValueLable = autherLable;
    
    LEWeakSelf(self)
    [_introduceValueLable addTapGesutureRecognizer:^(UITapGestureRecognizer *ges)
     {
         LEStrongSelf(self)
         if (!self.needExpand) {
             return;
         }
         self.isExpand = !self.isExpand;
         expand = self.isExpand;
             //只更新高度，不更新内容
             [[self getTableView] beginUpdates];
             [[self getTableView] endUpdates];
             [UIView animateWithDuration:0.2 animations:^{
                
                 [self setIntroduceLableText:self.cartoonDetailModle.cartoonIntroduce];
             }];
     }];
    
    NSDictionary * _binds = @{@"introduceValueLable":_introduceValueLable};
    [centerContainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[introduceValueLable]-1-|" options:0 metrics:nil views:_binds]];
    [centerContainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[introduceValueLable]-15-|" options:0 metrics:nil views:_binds]];
    
    UIView *bottomContainView  = [UIView new];
    bottomContainView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomContainView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bottomContainView];
    CGFloat itemWidth = ScreenWidth/3.0f;
    for (int i=0; i<3; i++)
    {
        UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentCenter numberOfLines:1];
        [bottomContainView addSubview:nameLable];
        nameLable.frame = CGRectMake(i*itemWidth, 20, itemWidth, 15);
        if (i==0) {
            _hotLable = nameLable;
            _hotLable.text = AYLocalizedString(@"人气值");
        }
        else if (i==1) {
            _agreeLable = nameLable;
            _agreeLable.text = AYLocalizedString(@"点赞人数");

        }
        else if (i==2) {
            _collectLable = nameLable;
            _collectLable.text = AYLocalizedString(@"已收藏");

        }
        
       UILabel *valueLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(250, 85, 108) textAlignment:NSTextAlignmentCenter numberOfLines:1];
        [bottomContainView addSubview:valueLable];
        valueLable.frame = CGRectMake(i*itemWidth, 2, itemWidth, 15);
        if (i==0) {
            _hotValueLable = valueLable;
        }
        else if (i==1) {
            _agreeValueLable = valueLable;
        }
        else if (i==2) {
            _collectValueLable = valueLable;
        }
    }
    //增加两条竖线
    for (int j=0; j<2; j++) {
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = RGB(211, 211, 211).CGColor;
        lineLayer.frame = CGRectMake((j+1)*itemWidth, (36-17)/2.0f, 1, 17);
        [bottomContainView.layer addSublayer:lineLayer];
    }
 
    _binds = @{@"topContainView":topContainView,@"centerContainView":centerContainView,@"bottomContainView":bottomContainView};
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[bottomContainView(==36@999)]-(==2@999)-[topContainView(==55@999)]-0-[centerContainView]-10-|" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[topContainView]-15-|" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[centerContainView]-15-|" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomContainView]-0-|" options:0 metrics:nil views:_binds]];
}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYCartoonDetailModel.class])
    {
        _cartoonDetailModle = model;
        AYCartoonDetailModel *cartoonModel = model;
        _autherValueLable.text = cartoonModel.cartoonAuthor;
        _updateTimeValueLable.text = ([cartoonModel.cartoon_update_status integerValue]==1)?AYLocalizedString(@"已完结"):AYLocalizedString(@"连载中");
        if (cartoonModel.cartoonIntroduce && cartoonModel.cartoonIntroduce.length>0) {
            NSAttributedString *initAttributeStr = [self getAttr:[[NSAttributedString alloc] initWithString:cartoonModel.cartoonIntroduce]];
            
            CGFloat introduceHeight =[AYUtitle getAttributedStringHeight:initAttributeStr width:_introduceValueLable.width attribute:[self introduceAttributes]];
            
            if(introduceHeight>AYCARTOONINTRODUCE_DEFAULT_HEIGHT)
            {
                cartoonIntroduceTextHeight = [AYUtitle getAttributedStringHeight:[self getExpandAttributedString:cartoonModel.cartoonIntroduce] width:_introduceValueLable.width attribute:[self introduceAttributes]];
                self.needExpand = YES;
                [self setIntroduceLableText:cartoonModel.cartoonIntroduce];
            }
            else
            {
                cartoonIntroduceTextHeight =introduceHeight;
                self.needExpand = NO;
               _introduceValueLable.attributedText = initAttributeStr;
            }
     
        }

        _hotValueLable.text = cartoonModel.cartoonHotNum;
        _agreeValueLable.text = cartoonModel.cartoonAgreeNum;
        _collectValueLable.text = cartoonModel.cartoonColletNum;
    }
}
-(NSMutableAttributedString*)getExpandAttributedString:(NSString*)intrContent
{
    if (!_expandMutableStr)
    {
        NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
        backAttachment.image = [[UIImage imageNamed:@"arry_right_black"] imageByRotateLeft90];
        backAttachment.bounds = CGRectMake(0, -3, 16, 16);
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
        backAttachment.image =[[UIImage imageNamed:@"arry_right_black"] imageByRotateRight90];
        backAttachment.bounds = CGRectMake(0, -3, 16, 16);
        NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
        NSString *noExpandStr = [intrContent substringToIndex:[AYUtitle strLenthToSize:_introduceValueLable.size str:intrContent attribute:[self introduceAttributes]]];
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
    self.introduceValueLable.attributedText = self.isExpand?[self getExpandAttributedString:introContent]:[self getUnExpandAttributedString:introContent];
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
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:_introduceValueLable.font ,
             NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
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
+(CGFloat)cellHeight
{
    if (!expand)
    {
        return AYCARTOONINTRODUCE_DEFAULT_HEIGHT+170.0f;
    }
    else
    {
        
        return cartoonIntroduceTextHeight+170.0f;
    }}
@end

#import "AYCartoonChapterContentModel.h" //章节内容model
#import "AYShareManager.h" //分享管理
#import "AYBookRackManager.h" //书架管理

@interface AYCartoonActionTableViewCell()

@property(nonatomic,strong)UILabel *agreeLable; //点赞lable
@property(nonatomic,strong)AYCartoonChapterContentModel *chapterModel; //点赞lable

@end

@implementation AYCartoonActionTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    CGFloat itemWidth = ScreenWidth/3.0f;
    NSArray *itemArray = @[AYLocalizedString(@"赞"),AYLocalizedString(@"关注"),AYLocalizedString(@"分享")];
    NSArray *itemImageArray = @[@"agree",@"attention",@"share"];
    
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         UIImage *iconImage = LEImage(itemImageArray[idx]);
         UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
         iconImageView.frame = CGRectMake(idx*itemWidth+(itemWidth-iconImage.size.width)/2.0f, (30-iconImage.size.height), iconImage.size.width, iconImage.size.height);
         iconImageView.tag = 56596+idx;
         [self.contentView addSubview:iconImageView];
         [iconImageView setEnlargeEdgeWithTop:15 right:15 bottom:15 left:15];
         LEWeakSelf(self)
         [iconImageView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
             LEStrongSelf(self)
             if (idx ==0) {
                 if([self.chapterModel.hit_status boolValue])
                 {
                     return ;
                 }
                 else if ([AYUserManager isUserLogin])
                 {
                     [self clickLike:(UIImageView*)ges.view];
                 }
                 else
                 {
                     [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                        [self clickLike:(UIImageView*)ges.view];
                     }];
                 }
             }
             else if (idx ==1)
             {
                 if([AYBookRackManager bookInBookRack:[self.chapterModel.cartoonChapterId stringValue]])
                 {
                     return ;
                 }
                 if ([AYUserManager isUserLogin])
                 {
                     [self addCartoonToBookRack:(UIImageView*)ges.view];
                 }
                 else
                 {
                     [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                        [self addCartoonToBookRack:(UIImageView*)ges.view];
                     }];
                 }

             }
             else if (idx ==2) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartoonChapterShareEvents object:nil];
             }
         }];
         
         UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter numberOfLines:1];
         titleLable.frame = CGRectMake(idx*itemWidth, 35, itemWidth, 13);
         titleLable.text = obj;
         [self.contentView addSubview:titleLable];
         
         if (idx ==0) {
             self.agreeLable = titleLable;
         }
         
     }];
}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYCartoonChapterContentModel.class])
    {
        AYCartoonChapterContentModel *chapterModel = model;
        self.chapterModel = chapterModel;
        if([chapterModel.chapterAgreeNum intValue]>0)
        {
            self.agreeLable.text = [NSString stringWithFormat:@"%@(%d)",AYLocalizedString(@"赞"),[chapterModel.chapterAgreeNum intValue]];
    
        }
        if([chapterModel.hit_status boolValue])
        {
            UIImageView *iconImageView = [self viewWithTag:56596];
            if (iconImageView) {
                iconImageView.image =LEImage(@"agreed");
            }
        }
        if([AYBookRackManager bookInBookRack:[self.chapterModel.cartoonId stringValue]])
        {
            UIImageView *iconImageView = [self viewWithTag:56596+1];
            if (iconImageView) {
                iconImageView.image = LEImage(@"attentioned");
            }
        }

    }
}

+(CGFloat)cellHeight
{
    return 60;
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
#pragma mark - network -
-(void)clickLike:(UIImageView*)imageView
{
    if([self.chapterModel.hit_status boolValue])
    {
        return;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:self.chapterModel.cartoonChapterId forKey:@"cart_section_id"];
        
    }];
    [ZWNetwork post:@"HTTP_Post_Cartoon_ClickLike" parameters:para success:^(id record)
     {
        self.chapterModel.chapterAgreeNum =[NSString stringWithFormat:@"%ld",[self.chapterModel.chapterAgreeNum integerValue]+1];
        self.agreeLable.text = [NSString stringWithFormat:@"%@(%d)",AYLocalizedString(@"赞"),[self.chapterModel.chapterAgreeNum intValue]];
         self.chapterModel.hit_status = @(YES);
         imageView.image = LEImage(@"agreed");
         
     } failure:^(LEServiceError type, NSError *error) {
         occasionalHint([error localizedDescription]);
     }];
}

#pragma mark - net work -
-(void)addCartoonToBookRack:(UIImageView*)imageView
{
    [AYBookRackManager addBookToBookRackWithBookID:self.chapterModel.cartoonId fiction:NO compete:^{
        NSString *result = AYLocalizedString(@"加入书架成功");
        occasionalHint(result);
        imageView.image = LEImage(@"attentioned");

    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}
@end

@implementation AYCartoonSwitchChapterTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    CGFloat itemWidth = ScreenWidth/2.0f;
    NSArray *itemArray = @[AYLocalizedString(@"上一篇"),AYLocalizedString(@"下一篇")];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth/2.0f, 15, 1, 52-30)];
    lineView.backgroundColor = UIColorFromRGB(0x999999);
    [self.contentView addSubview:lineView];

    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:[UIColor blackColor] title:obj image:nil];
         itemBtn.frame = CGRectMake(idx*itemWidth, 1, itemWidth, 50);
         itemBtn.tag = idx+569;
         
         
         [self.contentView addSubview:itemBtn];
         LEWeakSelf(self)
         [itemBtn addAction:^(UIButton *btn) {
             LEStrongSelf(self)
             NSInteger tag = btn.tag-569;
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (tag==0) {//上一篇
                     if (self.aySwitchChapterClicked) {
                         self.aySwitchChapterClicked(NO);
                     }
                 }
                 else if (tag==1) {//下一篇
                     if (self.aySwitchChapterClicked) {
                         self.aySwitchChapterClicked(YES);
                     }
                 }
             });
      
         }];
         
     }];
}

+(CGFloat)cellHeight
{
    return 52;
}
@end

@interface AYCartoonChapterContentTableViewCell()



@end

@implementation AYCartoonChapterContentTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    _contentImageView = [YYAnimatedImageView new];
    _contentImageView.contentMode= UIViewContentModeScaleAspectFill;
    _contentImageView.clipsToBounds = YES;
    //self.contentView.backgroundColor = [UIColor redColor];
    _contentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_contentImageView];
    
//    NSDictionary * _binds = @{@"contentImageView":self.contentImageView};
//
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentImageView]-0-|" options:0 metrics:nil views:_binds]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentImageView]-0-|" options:0 metrics:nil views:_binds]];
    
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_contentImageView
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.contentView
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1.0f constant:0.0f];
    [self.contentView addConstraint:topConstraint];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_contentImageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f constant:1];
    [self.contentView addConstraint:bottomConstraint];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:_contentImageView
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeLeading
                                 multiplier:1.0f constant:0.0f]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:_contentImageView
                                  attribute:NSLayoutAttributeTrailing
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeTrailing
                                 multiplier:1.0f constant:0.0f]];
    
    CGFloat cellHeight = (5.0f/4.0f)*ScreenWidth;

    _progressView = [[LELoadProgressView alloc] initWithFrame:CGRectMake((ScreenWidth-100)/2.0f,(cellHeight-100)/2.0f , 100, 100) type:circularProgressBar];
 
    _progressView.progressBarBGC = RGB(140, 140, 140);
    _progressView.fillColor = RGB(171, 171, 171);
    [self.contentView addSubview:_progressView];

}

@end
