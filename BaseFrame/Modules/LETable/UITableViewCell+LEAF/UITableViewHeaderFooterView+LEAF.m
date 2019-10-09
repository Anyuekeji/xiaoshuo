//
//  UITableViewHeaderFooterView+LEAF.m
//  CallU
//
//  Created by 刘云鹏 on 16/3/15.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import "UITableViewHeaderFooterView+LEAF.h"

@implementation UITableViewHeaderFooterView (LEAF)

+ (NSString *) identifier {
    return NSStringFromClass([self class]);
}

- (CGFloat) fittingSizeHeight {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return ceil([self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
}

@end
