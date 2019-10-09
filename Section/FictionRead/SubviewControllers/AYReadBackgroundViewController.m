//
//  AYReadBackgroundViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/20.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYReadBackgroundViewController.h"

@interface AYReadBackgroundViewController ()

@end

@implementation AYReadBackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)setCurrentContentViewController:(UIViewController *)currentContentViewController
{
    if(currentContentViewController)
    {
        UIImage *bgImage = [AYUtitle imageWithUIView:currentContentViewController.view];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:currentContentViewController.view.bounds];
        bgImageView.image = bgImage;
        bgImageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        [self.view addSubview:bgImageView];
    }
}
@end
