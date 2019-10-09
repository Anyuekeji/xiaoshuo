//
//  VideoEditMenu.h
//  VideoManager
//
//  Created by liuyunpeng on 2018/10/11.
//  Copyright © 2018年 AnYue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEItemView : UIView
/**
 * 创建view
 */
- (instancetype)initWithTitle:(NSString*)itemTitle icon:(NSString*)iconUrl  isBigMode:(BOOL)isBigMode  numInOneLine:(NSInteger) num;
/**
 * 是否选中
 */
//@property(nonatomic,assign) BOOL select;
@end
