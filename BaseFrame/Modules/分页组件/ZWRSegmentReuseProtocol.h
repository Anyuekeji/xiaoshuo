//
//  ZWRSegmentReuseProtocol.h
//  CallU
//
//  Created by Leaf on 16/4/13.
//  Copyright © 2016年 NHZW. All rights reserved.
//

@protocol ZWRSegmentReuseProtocol <NSObject>

@required
/**
 *  在这里返回唯一标识，用于提高复用效率
 */
- (NSString *) uniqueIdentifier;
/**
 *  段显示标题
 */
- (NSString *) segmentTitle;

@optional
/**
 *  如果主界面是一个ScrollView或者其子类请在这里返回｜为了ZWRSlideSegmentViewController滚动动画
 */
- (UIScrollView *) scrollView;

/**
 *  当从显示栏位移除的时候会调用此方法，可实现相关移除逻辑
 */
- (void) segmentDidRemoveViewController;
/**
 *  当进入显示栏位的时候将会调用此方法，可实现相关逻辑
 */
- (void) segmentDidLoadViewController;
/**
 *  如果主界面触发viewWillAppear:｜切换到本页面，将同时访问当前已经显示页面的此方法
 */
- (void) segmentViewWillAppear;
/**
 *  如果主界面触发viewWillDisappear:｜从本页面切走（<-暂时不可用），将同时访问当前已经显示页面的此方法
 */
- (void) segmentViewWillDisappear;
/**
 收到内存警告将触发此方法
 */
- (void) segmentRecivedMemoryWarning;

@end
