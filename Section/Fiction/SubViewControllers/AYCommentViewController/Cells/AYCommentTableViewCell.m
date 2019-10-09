//
//  AYCommentTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCommentTableViewCell.h"
#import "AYCommentModel.h"

@interface AYCommentTableViewCell()
@property(nonatomic,strong)UILabel *commentNameLable; //评论者
@property(nonatomic,strong)UIView  *comentLevelAndGrade; //小说几星和评分
@property(nonatomic,strong)UILabel *commentContentLable; //评论内容
@property(nonatomic,strong)UILabel *commentTimeLable; //评论时间
@property(nonatomic,strong)UIImageView *commenterHeadView; //评论者头像

@property(nonatomic,strong)UILabel *replyLable; //回复视图

@end
@implementation AYCommentTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
}

-(void)configureUI
{
 
    [self bottomLineRightMoveWithValue:60];
    UIImageView *headImageView = [UIImageView new];
    headImageView.contentMode = UIViewContentModeScaleAspectFill;
    headImageView.clipsToBounds = YES;
    headImageView.translatesAutoresizingMaskIntoConstraints = NO;
    headImageView.layer.cornerRadius = 17.5f;
    [self.contentView addSubview:headImageView];
    _commenterHeadView = headImageView;
    
    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentLeft numberOfLines:2];
    nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:nameLable];
    _commentNameLable = nameLable;
    
    UILabel *contentLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    contentLable.preferredMaxLayoutWidth = ScreenWidth-80; contentLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:contentLable];
    _commentContentLable = contentLable;
    
    UILabel *timeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:UIColorFromRGB(0x999999) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    timeLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:timeLable];
    _commentTimeLable = timeLable;
    
    
    UILabel *replyLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    replyLable.preferredMaxLayoutWidth = ScreenWidth - 75;
 replyLable.translatesAutoresizingMaskIntoConstraints = NO;
    replyLable.backgroundColor = UIColorFromRGB(0xf7f7f7);
    [self.contentView addSubview:replyLable];
    _replyLable = replyLable;
    replyLable.layer.cornerRadius = 5.0f;
    
    UIView *levelView = [UIView new];
    levelView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:levelView];
    _comentLevelAndGrade = levelView;
    for (int i=0; i<5; i++)
    {
        UIImageView* starView = [[UIImageView alloc] initWithImage:LEImage(@"stat_shadow")];
        starView.frame = CGRectMake(i*(12+5), 0, 12, 12);
        starView.tag = 13546+i;
        [levelView addSubview:starView];
    }
    [self layoutUI];
}

-(void)layoutUI
{
    NSDictionary * _binds = @{@"commentNameLable":self.commentNameLable, @"commentContentLable":self.commentContentLable, @"commentTimeLable":self.commentTimeLable, @"comentLevelAndGrade":self.comentLevelAndGrade, @"replyLable":self.replyLable, @"headView":self.commenterHeadView};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[headView(==35)]" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[headView(==35)]" options:0 metrics:nil views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[commentNameLable]-15-|" options:0 metrics:nil views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[commentTimeLable(==140)]-(>=10@999)-[comentLevelAndGrade(==80)]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_binds]];

    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[replyLable]-15-|" options:0 metrics:nil views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[commentContentLable]-15-|" options:0 metrics:nil views:_binds]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_comentLevelAndGrade attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:12.0f]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[commentNameLable(==22@999)]-5-[commentTimeLable(==20@999)]-4@999-[commentContentLable(>=20@999)]-9@999-[replyLable]-9@999-|" options:0 metrics:nil views:_binds]];
}

-(void)fillCellWithModel:(id)model
{
    if ([model isKindOfClass:AYCommentModel.class])
    {
        [_comentLevelAndGrade.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *statImageView = (UIImageView*)obj;
            statImageView.image =LEImage(@"stat_shadow");
        }];
        
        AYCommentModel *fictionModel =(AYCommentModel*)model;
        LEImageSet(self.commenterHeadView, fictionModel.commenterHeadImage, @"me_defalut_icon");
        _commentNameLable.text =fictionModel.commentName;
        _commentContentLable.text =fictionModel.commentContent;
        _commentTimeLable.text =fictionModel.commentTime;
        int statNum = [fictionModel.commentStarNum intValue];

        for (int i=0; i<statNum; i++)
        {
            UIImageView *statImageView = [_comentLevelAndGrade viewWithTag:13546+i];
            if (statImageView) {
                statImageView.image = LEImage(@"stat_light");
            }
        }
        NSInteger replyCount = fictionModel.commentReplyArray.count;
        if (replyCount>0)
        {
            NSMutableAttributedString *finalAttString = [[NSMutableAttributedString alloc] init];
            for (int i=0; i<replyCount;i++)
            {
                AYCommentReplyModel *obj = [fictionModel.commentReplyArray objectAtIndex:i];
                NSString *replyText =[NSString stringWithFormat:@"%@:%@",obj.commentReplyName,obj.commentReplyContent];
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:replyText];
                [attString addAttributes:[self replyLableAttributes] range:NSMakeRange(0, obj.commentReplyName.length)];
                [attString addAttribute:NSForegroundColorAttributeName value:RGB(205, 85, 108) range:NSMakeRange(0, obj.commentReplyName.length)];
                if (i>0) {
                    [finalAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"] ];
                }
                [finalAttString appendAttributedString:attString];
            }
            _replyLable.attributedText = finalAttString;

        }
        else
        {
            _replyLable.text = @"";
        }

    }
}
- (NSDictionary *)replyLableAttributes {
    UIFont *font_ = [UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //paragraphStyle.lineSpacing = font_.pointSize / 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    NSDictionary *dic = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font_,NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
    return dic;
}
@end
