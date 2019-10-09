//
//  LELineTableViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LETableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

#define  CustomLineCellLineTag 98439

@interface LELineTableViewCell : LETableViewCell
/**是否显示底部分割线*/
-(void)hideOrShowLine:(BOOL)show;
/**底部line右移*/
-(void)bottomLineRightMoveWithValue:(CGFloat)value;

/**底部line居中*/
-(void)bottomLineCenterWithOffset:(CGFloat)offset;
@end

NS_ASSUME_NONNULL_END
