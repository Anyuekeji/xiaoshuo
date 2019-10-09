//
//  UIView+AY.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/28.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "UIView+AY.h"

@implementation UIView (AY)
//增加阴影
-(void)addOrRemoveShowdow:(BOOL)add
{
    if (add) {
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOffset = CGSizeMake(3,3);
    }
    else
    {
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 0.0f;
        self.layer.shadowRadius = 4.0f;
    }
}
@end
