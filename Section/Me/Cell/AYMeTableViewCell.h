//
//  AYMeTableViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/6.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETableViewCell.h"
#import "LELineTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYMeTableViewHeadCell : LELineTableViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
/** 设置头像 */
@property (nonatomic, copy) void(^ayClickSetHeadImageAction)(UIImageView *headView);
+(CGFloat)cellHeight;
@end

/**充值*/
@interface AYMeChargeTableViewHeadCell : LELineTableViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
/** 设置头像 */
@property (nonatomic, copy) void(^ayClickSetHeadImageAction)(UIImageView *headView);
+(CGFloat)cellHeight;
@end


/**switch Cell*/
@interface AYMeSetAutoLockTableViewCell : LELineTableViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
+(CGFloat)cellHeight;
@end

/**充值记录 Cell*/
@interface AYMeChargeRecoreTableViewCell : LELineTableViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
+(CGFloat)cellHeight;
@end

/**消费记录 Cell*/
@interface AYMeConsumeRecoreTableViewCell : AYMeChargeRecoreTableViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
+(CGFloat)cellHeight;
@end

/**好友记录 Cell*/
@interface AYMeFriendRecoreTableViewCell : LELineTableViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
+(CGFloat)cellHeight;
@end

/**空白填充cell*/
@interface AYMeTableViewEmptyCell : LELineTableViewCell
+(CGFloat)cellHeight;
@end


@interface AYMeTableViewCell : LELineTableViewCell
-(void)filCellWithModel:(id)model;
+(CGFloat)cellHeight;
@end


@interface AYMeAnswerTableViewCell : LELineTableViewCell
-(void)filCellWithModel:(id)model;
@end

/**
 *  注册行样式到一个表
 *
 *  @param tableView 注册的表格实例
 */
UIKIT_EXTERN void _AYMeCellsRegisterToTable(UITableView * tableView,int dataType);

/**
 *  依据对象 获取行Cell实例
 *
 *  @param object    对象
 *  @param tableView 当前表
 *  @param indexPath 索引
 *
 *  @return 行
 */
UIKIT_EXTERN UITableViewCell * _AYMeGetCellByItem(id object, int dataType,UITableView * tableView, NSIndexPath * indexPath, void(^fetchedEvent)(UITableViewCell * fetchCell));

/**
 计算行高度
 
 @param object 数据对象
 @return 新闻行高度
 */
UIKIT_EXTERN CGFloat _AYMeCellHeightByItem(id object,NSIndexPath * indexPath,int dataType);


NS_ASSUME_NONNULL_END



