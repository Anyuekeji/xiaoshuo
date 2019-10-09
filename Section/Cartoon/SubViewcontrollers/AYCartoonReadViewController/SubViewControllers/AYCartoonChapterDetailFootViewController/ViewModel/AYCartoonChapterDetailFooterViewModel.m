//
//  AYCartoonChapterDetailFooterViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonChapterDetailFooterViewModel.h"
#import "AYCartoonChapterModel.h"

@interface AYCartoonChapterDetailFooterViewModel ()
@property(nonatomic,strong) AYCartoonChapterModel *cartoonDetailModel; //小说总章节数
@property(nonatomic,strong) NSArray *itemArray; //小说总章节数
@end
@implementation AYCartoonChapterDetailFooterViewModel
- (void) setUp
{
    [super setUp];
    _itemArray = [NSArray arrayWithObjects:@"cartoon_action",@"cartoon_chapter",@"empty",@"comment", nil];
}

#pragma mark - Table Used
- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count;
    
}

- (id) objectForIndexPath : (NSIndexPath *) indexPath {
    
    NSString *value =[_itemArray objectAtIndex:indexPath.row];
    NSMutableArray *objArray = [NSMutableArray new];
    [objArray safe_addObject:value];
    [objArray safe_addObject:_chapterModel];
    
    return objArray;
}
-(void)setChapterModel:(AYCartoonChapterModel *)chapterModel
{
    _chapterModel = chapterModel;
}
@end
