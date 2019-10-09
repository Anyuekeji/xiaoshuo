//
//  AYMeViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYMeViewModel.h"
@interface AYMeViewModel()

@property (nonatomic,strong) NSMutableArray<NSString*>  *itemArray;
@end


@implementation AYMeViewModel
- (void) setUp {
    [super setUp];
    //head表示头，empty 表示空隙
   // _itemArray = [NSMutableArray arrayWithObjects:@"empty",@"head",@"coin",@"empty",@"记录",@"评论",@"签到",@"邀请",@"意见反馈",@"设置",nil];
    _itemArray = [NSMutableArray arrayWithObjects:@"head",@"coin",@"empty",@"金币明细",@"FB在线客服",@"empty",@"作者投稿",@"常见问题",@"意见反馈",@"设置",nil];
}
#pragma mark - Table Used
- (NSInteger)numberOfSections {
    return 1;
}
- (NSInteger) numberOfRowsInSection:(NSInteger)section {

    return _itemArray.count;
}

- (id) objectForIndexPath : (NSIndexPath *) indexPath {
    
    return _itemArray[indexPath.row];
}
@end
