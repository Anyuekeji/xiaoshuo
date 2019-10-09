//
//  UITableViewCell+LEAF.m
//  BingoDu
//
//  Created by 刘云鹏 on 16/3/15.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import "UITableViewCell+LEAF.h"

@implementation UITableViewCell (LEAF)

+ (NSString *) identifier {
    return NSStringFromClass([self class]);
}

- (CGFloat) fittingSizeHeight {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return ceil([self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
}

@end
