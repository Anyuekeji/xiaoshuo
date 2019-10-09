//
//  AYCartoonReadBottomView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class  AYCartoonReadBottomView;

@protocol AYCartoonReadBottomViewDelegate<NSObject>
//上一章
-(void)previousChapterInCartoonReadBottomView:(AYCartoonReadBottomView *)bottomView;
//下一章
-(void)nextChapterInCartoonReadBottompView:(AYCartoonReadBottomView *)bottomView;
//菜单
-(void)menuInCartoonReadBottomView:(AYCartoonReadBottomView *)bottomView;
//评论
-(void)commentInCartoonReadBottomView:(AYCartoonReadBottomView *)bottomView;
@end

@interface AYCartoonReadBottomView : UIView
@property (nonatomic,weak) id<AYCartoonReadBottomViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
