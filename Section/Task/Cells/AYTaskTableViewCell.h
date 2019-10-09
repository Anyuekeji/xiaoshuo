//
//  AYTaskTableViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/8.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LELineTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYTaskTableViewCell : LELineTableViewCell
-(void)fillCellWithModel:(id)model;

@end

/**空白填充cell*/
@interface AYTaskTableViewEmptyCell : LETableViewCell
-(void)fillCellWithModel:(id)model;

//更新详细文本
-(void)updateCellDetailInfoWith:(NSInteger)advertiseCount;
+(CGFloat)cellHeight;
@end

/**去分享界面cell*/
@interface AYTaskShareCell : LELineTableViewCell
-(void)fillCellWithModel:(id)model;

+(CGFloat)cellHeight;
@end
NS_ASSUME_NONNULL_END
