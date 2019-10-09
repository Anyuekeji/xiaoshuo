//
//  AYCartoonTableViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETableViewCell.h"
#import <YYKit.h>
#import "LELoadProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonDetailTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
@end

@interface AYCartoonActionTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
//@property (nonatomic, copy) void (^ayactionShareChapterClicked)(void);
@end

@interface AYCartoonSwitchChapterTableViewCell : LETableViewCell
@property (nonatomic, copy) void (^aySwitchChapterClicked)(BOOL nextChapter);
@end


@interface AYCartoonChapterContentTableViewCell : LETableViewCell
@property(nonatomic,strong) UIImageView *contentImageView; //点赞lable
@property(nonatomic,strong) LELoadProgressView *progressView;
@end
NS_ASSUME_NONNULL_END
