//
//  AYCartoonLoadProgressViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/15.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYCartoonLoadProgressViewController.h"
#import <YYKit/YYKit.h>

@interface AYCartoonLoadProgressViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *cartoonImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *loadingLable;
@property (weak, nonatomic) IBOutlet UIProgressView *loadingProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopContrains;
@end

@implementation AYCartoonLoadProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    // Do any additional setup after loading the view from its nib.
}

-(void)configureUI
{
    //设置进度条的颜色
    _loadingProgressView.progressTintColor = RGB(250, 85, 108);
    //设置进度条的当前值，范围：0~1；
    _loadingProgressView.progress = 0.1;
    self.cartoonImageVIew.alpha = 1.0f;
    
    self.cartoonImageVIew.contentMode= UIViewContentModeScaleAspectFill;
    [self animateImageView:1.0];
    
    _loadingLable.text = [NSString stringWithFormat:@"%@....",AYLocalizedString(@"努力加载中")];
    
    if(_ZWIsIPhoneXSeries())
    {
        _imageTopContrains.constant+=87;
    }
    
}
-(void)animateImageView:(CGFloat)startAlpha
{
    [UIView animateWithDuration:2.0f animations:^{
        if (startAlpha<=0.35) {
            self.cartoonImageVIew.alpha = 1;
        }
        else
        {
            self.cartoonImageVIew.alpha = 0.3f;
        }
        
    } completion:^(BOOL finished) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateImageView:(startAlpha<=0.35)?1.0:0.3f];
    });
}

-(void)setDownProgress:(CGFloat)downProgress
{
    if (downProgress>0 && downProgress<=1.0f )
    {
        _loadingProgressView.progress = downProgress;
    }
}
-(void)setCartoonImageUrl:(NSString *)cartoonImageUrl
{
    LEImageSet(_cartoonImageVIew, cartoonImageUrl, @"ws_register_example_company");
}
@end
