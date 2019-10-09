//
//  AYFictionDetailViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFictionDetailViewController : LETableViewController<ZWREventsProtocol>
-(instancetype)initWithParas:(id)para;


@property(nonatomic,strong)UIImageView *fictionImageView;

@end

NS_ASSUME_NONNULL_END
