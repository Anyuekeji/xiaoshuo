//
//  AYReadContentView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYReadContentView : UIView

/** 显示的字符串 */
@property (nonatomic, copy) NSString *content;
/** 当前页数 */
@property (nonatomic, assign) NSInteger currentPage;
/** 总页数 */
@property (nonatomic, assign) NSInteger totalPage;
/** 字体大小*/
@property (nonatomic, assign) NSInteger font;
/**字体颜色*/
@property (nonatomic, strong) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
