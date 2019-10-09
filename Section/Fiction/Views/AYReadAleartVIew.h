//
//  AYReadAleartVIew.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/21.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/***
 * alertview
 */
@interface AYReadAleartVIew : UIView
+(void)shareReadAleartViewWithTitle:(NSString*)title okActionTitle:(NSString*)okTitle okCancle:(BOOL)autoCancle cancleActionTitle:(NSString*)cancleTitle parentView:(UIView*)parentView okBlock : (void(^)(bool ok)) okBlock;
+(void)removeReadAleartView;


@end

NS_ASSUME_NONNULL_END
