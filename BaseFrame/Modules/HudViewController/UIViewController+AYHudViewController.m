//
//  UIViewController+AYHudViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "UIViewController+AYHudViewController.h"
#import <objc/runtime.h>

#define TIMEOUT         30
#define CUSTOMERTIME    2.0f

@implementation UIViewController (AYHudViewController)

#pragma mark - 运行时Properties
- (void) setHUD : (MBProgressHUD *) HUD {
    objc_setAssociatedObject(self, @selector(HUD), HUD, OBJC_ASSOCIATION_RETAIN);
}

- (MBProgressHUD *) HUD {
    return objc_getAssociatedObject(self, @selector(HUD));
}

- (MBProgressHUD *) navHud {
    if ( self.HUD ) {
        [self.HUD hide:NO];
    }
    if ( self.navigationController ) {
        MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        //        hud.darkBlur = YES;
        hud.blur = NO;
        hud.delegate = self;
        [self.navigationController.view addSubview:hud];
        return hud;
    } else {
        MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.delegate = self;
        [self.navigationController.view addSubview:hud];
        return hud;
    }
}

#pragma mark - 封装显示
- (void) showHUD {
    [self createHUDWithMode:MBProgressHUDModeIndeterminate
                      title:nil
                     detail:nil
       needAutoThreadRemove:YES
                  hideAfter:0.0f];
}

- (void) showHUDWithTitle : (NSString *) title {
    [self createHUDWithMode:MBProgressHUDModeIndeterminate
                      title:title
                     detail:nil
       needAutoThreadRemove:YES
                  hideAfter:0.0f];
}

- (void) showHUDWithTitle : (NSString *) title detail : (NSString *) detail {
    [self createHUDWithMode:MBProgressHUDModeIndeterminate
                      title:title
                     detail:detail
       needAutoThreadRemove:YES
                  hideAfter:0.0f];
}

- (void) showHUDWithDeterminateTitle : (NSString *) title detail : (NSString *) detail {
    [self createHUDWithMode:MBProgressHUDModeDeterminate
                      title:title
                     detail:detail
       needAutoThreadRemove:YES
                  hideAfter:0.0f];
}

- (void) showHUDWithDeterminateHorizontalBarTitle : (NSString *) title detail : (NSString *) detail {
    [self createHUDWithMode:MBProgressHUDModeDeterminateHorizontalBar
                      title:title
                     detail:detail
       needAutoThreadRemove:YES
                  hideAfter:0.0f];
}

- (void) showHUDWithAnnularTitle : (NSString *) title detail : (NSString *) detail {
    [self createHUDWithMode:MBProgressHUDModeAnnularDeterminate
                      title:title
                     detail:detail
       needAutoThreadRemove:YES
                  hideAfter:0.0f];
}

- (void) updateHUDProgress : (float) progress {
    if ( self.HUD ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.HUD.progress = progress;
        });
    }
}

- (void) showHUDTextTitle : (NSString *) title detail : (NSString *) detail hideAfter : (NSTimeInterval) delay {
    if ( title || detail ) {
        [self createHUDWithMode:MBProgressHUDModeText
                          title:title
                         detail:detail
           needAutoThreadRemove:NO
                      hideAfter:delay];
    }
}

- (void) showHUDWithCustomerView : (UIView *) customerView title : (NSString *) title detail : (NSString *) detail hideAfter : (NSTimeInterval) delay {
    if ( customerView ) {
        self.HUD = [self navHud];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.customView = customerView;
        self.HUD.labelText = title;
        self.HUD.detailsLabelText = detail;
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:delay];
    }
}

- (void) hideHUD {
    if ( self.HUD ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
        });
    }
}

- (void) showHUDWithComplete {
    [self showHUDWithCustomerView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_promt_complete"]] title:nil detail:nil hideAfter:CUSTOMERTIME];
}

- (void) showHUDWithCompleteMess : (NSString *) mess {
    [self showHUDWithCustomerView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_promt_complete"]] title:mess detail:nil hideAfter:CUSTOMERTIME];
}

- (void) showHUDWithErrorMess : (NSString *) messTitle detail : (NSString *) detail {
    [self showHUDWithCustomerView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_promt_wrong"]] title:messTitle detail:detail hideAfter:CUSTOMERTIME];
}

- (void) showHUDWithWarningMess : (NSString *) messTitle detail : (NSString *) detail {
    [self showHUDWithCustomerView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_promt_warning"]] title:messTitle detail:detail hideAfter:CUSTOMERTIME];
}
#pragma mark - Window 界面的HUD
- (void) showWindowHUDWithMess : (NSString *) messTitle detail : (NSString *) detail hideAfter : (NSTimeInterval) delay {
    [self windowHUDWithMode:MBProgressHUDModeText customerView:nil title:messTitle detail:detail needAutoThreadRemove:NO hideAfter:delay > 0 ? delay : CUSTOMERTIME];
}

- (void) showWindowHUDWithCompleteMess : (NSString *) mess {
    [self windowHUDWithMode:MBProgressHUDModeCustomView customerView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_promt_complete"]] title:nil detail:mess needAutoThreadRemove:NO hideAfter:CUSTOMERTIME];
}

- (void) showWindowHUDWithErrorMess : (NSString *) messTitle detail : (NSString *) detail {
    [self windowHUDWithMode:MBProgressHUDModeCustomView customerView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_promt_wrong"]] title:messTitle detail:detail needAutoThreadRemove:NO hideAfter:CUSTOMERTIME];
}

- (void) showWindowHUDWithWarningMess : (NSString *) messTitle detail : (NSString *) detail {
    [self windowHUDWithMode:MBProgressHUDModeCustomView customerView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_promt_warning"]] title:messTitle detail:detail needAutoThreadRemove:NO hideAfter:CUSTOMERTIME];
}

#pragma mark - HUD生产
- (void) createHUDWithMode : (MBProgressHUDMode) mode
                     title : (NSString *) title
                    detail : (NSString *) detail
      needAutoThreadRemove : (BOOL) autoThreadRemove
                 hideAfter : (NSTimeInterval) delay {
    self.HUD = [self navHud];
    self.HUD.mode = mode;
    self.HUD.labelText = title;
    self.HUD.detailsLabelText = detail;
    [self.HUD show:YES];
    if ( autoThreadRemove ) {
        [self startThreadListening];
    } else {
        [self.HUD hide:YES afterDelay:delay];
    }
}

- (void) windowHUDWithMode : (MBProgressHUDMode) mode
              customerView : (UIView *) customerView
                     title : (NSString *) title
                    detail : (NSString *) detail
      needAutoThreadRemove : (BOOL) autoThreadRemove
                 hideAfter : (NSTimeInterval) delay {
    if ( self.HUD ) {
        [self.HUD hide:NO];
    }
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    self.HUD.darkBlur = YES;
    self.HUD.delegate = self;
    [self.view.window addSubview:self.HUD];
    
    self.HUD.mode = mode;
    self.HUD.labelText = title;
    self.HUD.detailsLabelText = detail;
    self.HUD.removeFromSuperViewOnHide = YES;
    if ( mode == MBProgressHUDModeCustomView ) {
        self.HUD.customView = customerView;
    }
    [self.HUD show:YES];
    if ( autoThreadRemove ) {
        [self startThreadListening];
    } else {
        [self.HUD hide:YES afterDelay:delay];
    }
}

#pragma mark - 线程监听
- (void) startThreadListening {
    [NSThread detachNewThreadSelector:@selector(listeningToHUD:) toTarget:self withObject:self.HUD];
}

- (void) listeningToHUD : (MBProgressHUD *) hud {
    BOOL isChanged = NO;
    NSInteger times = TIMEOUT;
    while ( times > 0 ) {
        if ( hud != self.HUD ) {
            isChanged = YES;
            break;
        }
        times --;
        sleep(1);//停留1秒
    }
    if ( self ) {
        [self performSelectorOnMainThread: isChanged ? @selector(justStopThread) : @selector(stopThreadAndRemoveHUD) withObject:nil waitUntilDone:NO];
    }
}

- (void) stopThreadAndRemoveHUD {
    if ( self.HUD ) {
        [self.HUD hide:YES];
    }
}

- (void) justStopThread {
    //
}

#pragma mark - MBProgressHUDDelegate
- (void) hudWasHidden : (MBProgressHUD *) hud {
    [hud removeFromSuperview];
    if ( self.HUD == hud ) {
        self.HUD = nil;
    }
}
@end
