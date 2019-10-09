//
//  AYFictionDetailTableViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//
#import "LELineTableViewCell.h"

@class AYFictionDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface AYFictionDetailTableViewCell : LETableViewCell

@end
//书架介绍
@interface AYFictionDetailHeadTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
@property (nonatomic, copy) void (^ayGetFictionHeadImageView)(UIImageView*);
@end
//打赏
@interface AYFictionDetailRewardTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
+(CGFloat)cellHeight;
@end

//简介
@interface AYFictionDetailIntroduceTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
+(CGFloat)cellHeight;

@end
//目录
@interface AYFictionDetailMenuTableViewCell : LELineTableViewCell
+(CGFloat)cellHeight;
-(void)fillCellWithModel:(id)model;

@end
//邀请好友
@interface AYFictionDetailInvationTableViewCell : LELineTableViewCell
-(void)fillCellWithModel:(id)model;
+(CGFloat)cellHeight;

@end
//评论头部cell
@interface AYDetailCommentHeadCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
@end
//评论底部cell
@interface AYDetailCommentFooterCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
@end
//热门推荐
@interface AYFictionDetailRecommentTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
+(CGFloat)cellHeight;

@end

/**空白填充cell*/
@interface AYFictionDetailTableViewEmptyCell : LETableViewCell
+(CGFloat)cellHeight;
@end




/**
 *  注册行样式到一个表
 *
 *  @param tableView 注册的表格实例
 */
UIKIT_EXTERN void _AYFictionDetailCellsRegisterToTable(UITableView * tableView,int dataType);

/**
 *  依据对象 获取行Cell实例
 *
 *  @param object    对象
 *  @param tableView 当前表
 *  @param indexPath 索引
 *
 *  @return 行
 */
UIKIT_EXTERN UITableViewCell * _AYFictionDetailGetCellByItem(id object, int dataType,UITableView * tableView, NSIndexPath * indexPath, void(^fetchedEvent)(UITableViewCell * fetchCell));

/**
 计算行高度
 
 @param object 数据对象
 @return 新闻行高度
 */
UIKIT_EXTERN CGFloat _AYFictionDetailCellHeightByItem(id object,NSIndexPath * indexPath,int dataType);
NS_ASSUME_NONNULL_END
