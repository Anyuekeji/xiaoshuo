//
//  AYCartoonReadViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonReadViewModel.h"
#import "AYCartoonChapterContentModel.h" //章节内容model

@interface AYCartoonReadViewModel ()
@property(nonatomic,strong) NSArray<NSString*> *itemArray; //底部评论s数据

@end
@implementation AYCartoonReadViewModel
- (void) setUp
{
    [super setUp];
   // _itemArray = [NSArray arrayWithObjects:@"cartoon_action",@"cartoon_chapter",@"empty",@"comment", nil];
    _itemArray = [NSArray arrayWithObjects:@"cartoon_action",@"empty",@"cartoon_chapter",nil];//去掉评论
}

#pragma mark - Table Used
- (NSInteger)numberOfSections {
    return 2;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    if(section ==0)
    {
        return _cartoonDetailModel.cartoonImageUrlArray.count;
    }
    else
    {
        return [_itemArray count];
    }
    
}

- (id) objectForIndexPath : (NSIndexPath *) indexPath {
    
    if(indexPath.section ==0)
    {
        AYCartoonChapterImageUrlModel *value =[_cartoonDetailModel.cartoonImageUrlArray objectAtIndex:indexPath.row];
        return value;
        
    }
    else
    {
        NSString *value =[_itemArray objectAtIndex:indexPath.row];
        NSMutableArray *objArray = [NSMutableArray new];
        [objArray safe_addObject:value];
        [objArray safe_addObject:_cartoonDetailModel];
        
        return objArray;
        
    }

}

-(void)setCartoonDetailModel:(AYCartoonChapterContentModel *)cartoonDetailModel
{
    _cartoonDetailModel = cartoonDetailModel;
}
@end
