//
//  UIGestureRecognizer+LEAF.m
//  BingoDu
//
//  Created by Leaf on 16/4/21.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "UIGestureRecognizer+LEAF.h"
#import <objc/runtime.h>

@implementation UIGestureRecognizer (LEAF)

- (void) setIdentifier:(NSString *)identifier {
    objc_setAssociatedObject(self, @selector(identifier), identifier, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *) identifier {
    return objc_getAssociatedObject(self, @selector(identifier));
}

@end
