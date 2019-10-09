//
//  UIImageView+AY.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/23.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "UIImageView+AY.h"

@implementation UIImageView (AY)
-(void)addOrRemoveFreeFlag:(BOOL)add
{
    if ([self viewWithTag:12658]) {
        [[self viewWithTag:12658] removeFromSuperview];
    }
    if (add)
    {
        UILabel *freeFlagLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:12] textColor:RGB(255, 255, 255) textAlignment:NSTextAlignmentCenter numberOfLines:1];
        freeFlagLable.tag = 12658;
        freeFlagLable.backgroundColor =RGB(255, 59, 98);
        [self addSubview:freeFlagLable];
        freeFlagLable.text = AYLocalizedString(@"免费");
        freeFlagLable.frame = CGRectMake(-45, 8, 116, 14);
        freeFlagLable.transform =CGAffineTransformMakeRotation (-M_PI_4);
    }
}

//增加阴影
-(void)addOrRemoveShowdow:(BOOL)add
{
    if (add) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.7f;
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOffset = CGSizeMake(4,4);
    }
    else
    {
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 0.0f;
        self.layer.shadowRadius = 4.0f;
    }

}
-(void)addCornorsWithValue:(CGFloat)cornorsValue
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = cornorsValue;
}
@end
