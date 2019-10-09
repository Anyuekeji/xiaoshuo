//
//  AYBaseViewModle.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

@implementation AYBaseViewModle
+ (id) viewModel {
    return [[self alloc] init];
}

- (instancetype) init {
    if ( self = [super init] ) {
        [self setUp];
    }
    return self;
}
+ (id) viewModelWithViewController : (UIViewController *) viewController {
    return [[self alloc] initWithViewController:viewController];
}

- (instancetype) initWithViewController : (UIViewController *) viewController {
    if ( self = [super init] ) {
        _linkViewController = viewController;
        [self setUp];
    }
    return self;
}

- (void) setUp {
    
}
@end
