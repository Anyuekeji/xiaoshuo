//
//  UICollectionViewCell+LEAF.m
//  BingoDu
//
//  Created by liuyunpeng on 16/3/12.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import "UICollectionViewCell+LEAF.h"

@implementation UICollectionViewCell (LEAF)

+ (UICollectionViewCell<LECollectionHelperProtocol> *) collectionCellItem {
    return [[self alloc] initWithFrame:CGRectZero];
}

+ (NSString *) identifier {
    return NSStringFromClass([self class]);
}

- (CGSize) fittingSize {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

@end
