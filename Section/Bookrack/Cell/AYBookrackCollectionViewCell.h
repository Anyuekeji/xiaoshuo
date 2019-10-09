//
//  AYBookrackCollectionViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/1.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define CELL_WIDTH (ScreenWidth-2*15-2*15)/3.0f

@interface AYBookrackCollectionViewCell : UICollectionViewCell
//是否处于编辑状态
@property(nonatomic,assign) BOOL edit;
//是否被选中删除
@property(nonatomic,assign) BOOL willDelete;

@property (nonatomic, strong) UIImageView *bookCoverImageView; //书的封面
/**填充数据*/
-(void)filCellWithModel:(id)model;
+(CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
