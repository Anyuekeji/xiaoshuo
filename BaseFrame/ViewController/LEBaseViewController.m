//
//  LEBaseViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LEBaseViewController.h"

@interface LEBaseViewController ()

@end

@implementation LEBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//重载了navigationController指向
- (UINavigationController *) navigationController {
    if ( self.parentViewController && [super navigationController] == nil ) {
        return [self.parentViewController navigationController];
    }

    return [super navigationController];
}
@end
