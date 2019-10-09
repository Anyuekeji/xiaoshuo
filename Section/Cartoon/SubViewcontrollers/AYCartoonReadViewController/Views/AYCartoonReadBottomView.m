//
//  AYCartoonReadBottomView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonReadBottomView.h"

@implementation AYCartoonReadBottomView
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    
    NSArray *itemArray = @[@"btn_back_nav",@"",@"btn_back_nav",@"menu",@"read_comment"];
    [itemArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //返回btn
        UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemBtn setEnlargeEdgeWithTop:9 right:9 bottom:9 left:9];
        if (obj.length>0) {
            [itemBtn setImage:LEImage(obj) forState:UIControlStateNormal];
            if (idx ==2) {
                itemBtn.transform = CGAffineTransformMakeRotation(180.0f *M_PI / 180.0);
            }
        }
        else
        {
            [itemBtn setTitle:AYLocalizedString(@"当前话") forState:UIControlStateNormal];
            itemBtn.titleLabel.font = [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
            [itemBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [self addSubview:itemBtn];
        
        if (idx ==0)
        {
            itemBtn.frame = CGRectMake(15, (self.bounds.size.height-16)/2.0f, 16, 16);
        }
        else if (idx ==1)
        {
            CGFloat textWidth = LETextWidth(AYLocalizedString(@"当前话"), [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE]);
            itemBtn.frame = CGRectMake(16+19+5, (self.bounds.size.height-14)/2.0f, textWidth, 14);
        }
        else if (idx ==2)
        {
            CGFloat textWidth = LETextWidth(AYLocalizedString(@"当前话"), [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE]);

            itemBtn.frame = CGRectMake(15+19+2+textWidth+16, (self.bounds.size.height-16)/2.0f, 16, 16);
        }
        else if (idx ==3)
        {
            itemBtn.frame = CGRectMake(ScreenWidth-13-15-13-25, (self.bounds.size.height-12)/2.0f, 14, 12);
        }
        else if (idx ==4)
        {
            itemBtn.frame = CGRectMake(ScreenWidth-13-15, (self.bounds.size.height-14)/2.0f, 13, 14);
        }
        LEWeakSelf(self)
        [itemBtn addAction:^(UIButton *btn) {
            LEStrongSelf(self)
            if (idx ==0)
            {
                if([self.delegate respondsToSelector:@selector(previousChapterInCartoonReadBottomView:)])
                {
                    [self.delegate previousChapterInCartoonReadBottomView:self];
                }
            }
            else if (idx ==1)
            {
               
            }
            else if (idx ==2)
            {
                if([self.delegate  respondsToSelector:@selector(nextChapterInCartoonReadBottompView:)])
                {
                    [self.delegate nextChapterInCartoonReadBottompView:self];
                }
            }
            else if (idx ==3)
            {
                if([self.delegate respondsToSelector:@selector(menuInCartoonReadBottomView:)])
                {
                    [self.delegate menuInCartoonReadBottomView:self];
                }
            }
            else if (idx ==4)
            {
                if([self.delegate respondsToSelector:@selector(commentInCartoonReadBottomView:)])
                {
                    [self.delegate commentInCartoonReadBottomView:self];
                }
            }
            
        }];
    } ];
    
    //设置阴影
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 1;
    
    // 单边阴影 底边边
    float shadowPathWidth = self.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, self.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    self.layer.shadowPath = path.CGPath;
}

@end
