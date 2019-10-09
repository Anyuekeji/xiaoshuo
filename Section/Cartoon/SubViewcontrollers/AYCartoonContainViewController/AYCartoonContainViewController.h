//
//  AYCartoonContainViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LEAFViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonContainViewController : LEAFViewController<ZWREventsProtocol>
-(instancetype)initWithPara:(id)para;
//设置封面图
-(void)setSurfaceplot:(NSString*)surfaceUrl;

-(void)switchScrollView:(UIScrollView *)scrollView;

-(void)subScrollViewDidScroll:(UIScrollView *)scrollView;
@end

NS_ASSUME_NONNULL_END
