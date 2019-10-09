//
//  LETableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETableViewCell.h"

@implementation LETableViewCell

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super initWithCoder:aDecoder] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        [self setUp];
    }
    return self;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        [self setUp];
    }
    return self;
}

- (void) setUp {
    //    ZWLog(@">> You may rewrite this function <setUp> to make self behaviors!");
}

//- (UIEdgeInsets) layoutMargins {
//    return UIEdgeInsetsZero;
//}

+ (CGFloat) estimatedHeight {
    return 44.0f;
}

@end
