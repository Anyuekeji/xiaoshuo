//
//  AYReadBottomView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYReadBottomView.h"

@implementation AYReadBottomView

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
    NSArray *itemArray = @[@"menu",@"read_night",@"read_font",@"read_comment"];
    CGFloat itemWidth = ScreenWidth/4.0f;
    if (AY_CURRENT_COUNTRY == AYCountryVietnam) {
        itemArray = @[@"menu",@"read_night",@"read_font"];
       itemWidth = ScreenWidth/3.0f;
    }
    
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //返回btn
        UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        itemBtn.frame = CGRectMake(idx*itemWidth, (49-22)/2.0f, itemWidth, 22);
        [itemBtn setImage:LEImage(obj) forState:UIControlStateNormal];
        [self addSubview:itemBtn];
        [itemBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        if (idx ==1) {
            
            [itemBtn setImage:LEImage(@"read_day") forState:UIControlStateSelected];
            BOOL night = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultNightMode];
            if (night) {
                itemBtn.selected = YES;
            }
        }
        
        LEWeakSelf(self)
        [itemBtn addAction:^(UIButton *btn) {
            LEStrongSelf(self)
            if (idx ==0)
            {
                if([self.delegate respondsToSelector:@selector(menuInReadBottomView:)])
                {
                    [self.delegate menuInReadBottomView:self];
                }
            }
            else if (idx ==1)
            {
                if([self.delegate respondsToSelector:@selector(dayNightSwitchInReadBottompView: day:)])
                {
                    btn.selected = !btn.selected;

                    [self.delegate dayNightSwitchInReadBottompView:self day:!btn.selected];
                }
            }
            else if (idx ==2)
            {
                if([self.delegate  respondsToSelector:@selector(fontSetInReadBottomView:)])
                {
                    [self.delegate fontSetInReadBottomView:self];
                }
            }
            else if (idx ==3)
            {
                if([self.delegate respondsToSelector:@selector(commentInReadBottomView:)])
                {
                    [self.delegate commentInReadBottomView:self];
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
