//
//  ZWRSegmentItem.m
//  CallU
//
//  Created by Leaf on 2017/3/27.
//  Copyright © 2017年 2.1.6. All rights reserved.
//

#import "ZWR2SegmentItem.h"

@implementation ZWR2SegmentItem

+ (ZWR2SegmentItem *) segmentItemWithIdentifier : (id) segmentIdentifier
                                          title : (NSString *) title
                         forViewControllerClass : (Class<ZWR2SegmentViewControllerProtocol>) clazz
                                   registerItem : (id) registerItem {
    ZWR2SegmentItem * segmentItem = [[ZWR2SegmentItem alloc] init];
    segmentItem.segmentIdentifier = segmentIdentifier;
    segmentItem.segmentTitle = title;
    segmentItem.viewControllerClass = clazz;
    segmentItem.registerItem = registerItem;
    return segmentItem;
}

- (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewController {
    if ( !_viewController ) {
        _viewController = [self.viewControllerClass viewControllerWithSegmentRegisterItem:self.registerItem segmentItem:self];
    }
    return _viewController;
}

- (BOOL) isCreatedViewController {
    return _viewController != nil;
}

- (BOOL) isEqual:(id)object {
    if ( [object isKindOfClass:self.class] ) {
        if ( [self.segmentIdentifier isKindOfClass:NSString.class] ) {
            return [self.segmentIdentifier isEqualToString:[object segmentIdentifier]];
        }
        return [object segmentIdentifier] == self.segmentIdentifier;
    }
    return NO;
}

@end
