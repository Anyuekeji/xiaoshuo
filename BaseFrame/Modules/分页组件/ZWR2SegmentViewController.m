//
//  ZWR2SegmentViewController.m
//  DSQiche
//
//  Created by allen on 2017/7/31.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import "ZWR2SegmentViewController.h"
#import "LESegment.h"

@interface ZWR2SegmentViewController ()

@end

@implementation ZWR2SegmentViewController

- (void)viewDidLoad {
    [self setUpSegmentControl];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setUpSegmentControl {
    self.segmentControl = [[LESegment alloc] init];
    self.segmentControl.backgroundColor = UIColorFromRGB(0xffffff);
    self.segmentControl.type = LESegmentTypeDynamicWidth;
    
    [self.view addSubview:self.segmentControl];
    self.view.clipsToBounds = YES;
}
@end
