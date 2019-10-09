//
//  AYShowTextView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYShowTextView : UIView
@property (nonatomic, copy) NSString *string;//要显示的字符串
@property (nonatomic, assign) NSInteger font; //字体大小
@property (nonatomic, strong) UIColor *textColor; //字体颜色

@end

NS_ASSUME_NONNULL_END
