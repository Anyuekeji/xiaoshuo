//
//  UIViewController+AYNavViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "UIViewController+AYNavViewController.h"

@implementation UIViewController (AYNavViewController)
#pragma mark - 配置NavigationBar Item按钮形式
- (UIBarButtonItem *) barButtonItemWithTitle : (NSString *) title
                                 normalColor : (UIColor *) normalColor
                              highlightColor : (UIColor *) highlightColor
                                 normalImage : (UIImage *) normalImage
                              highlightImage : (UIImage *) highlightImage
                                  leftBarItem:(BOOL)leftBarItem
                                      target : (id) target
                                      action : (SEL) action
{
    if (title && title.length>0) {
        UIButton * button = [self buttonWithTitle:title highlightTitle:nil selectedTitle:nil disableTitle:nil
                                      normalColor:normalColor highlightColor:highlightColor selectedColor:nil disableColor:nil
                                      normalImage:normalImage highlightImage:highlightImage selectedImage:nil disableImage:nil
                                           target:target action:action event:UIControlEventTouchUpInside];
        return [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else
    {
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithImage:normalImage style:UIBarButtonItemStylePlain target:target action:action];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        return barItem;
    }

}
- (void) configurateBackBarButtonItem {
    if ( (self.navigationController && self.navigationController.viewControllers.firstObject != self) || self.navigationController.presentingViewController != nil ) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_nav"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
       self.navigationController.navigationBar.tintColor = [UIColor blackColor];
//        UIBarButtonItem *backBtn =[self barButtonItemWithTitle:nil normalColor:nil highlightColor:nil normalImage:[UIImage imageNamed:@"btn_back_nav"] highlightImage:[UIImage imageNamed:@"btn_back_nav"] leftBarItem:YES target:self action:@selector(backAction)];
//
//        UIView *customView =backBtn.customView;
//        [customView setEnlargeEdgeWithTop:50 right:50 bottom:50 left:50];
        [self setLeftBarButtonItem:backItem];
    }
}
- (void) setLeftBarButtonItemsEmpty
{
    if ( (self.navigationController && self.navigationController.viewControllers.firstObject != self) || self.navigationController.presentingViewController != nil ) {
        [self setLeftBarButtonItem:[self barButtonItemWithTitle:nil normalColor:nil highlightColor:nil normalImage:nil highlightImage:nil leftBarItem:YES target:self action:nil]];
    }
}

- (void) setLeftBarButtonItem : (UIBarButtonItem *) item {
    self.navigationItem.leftBarButtonItem = item;
}

- (void) setLeftBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems {
    [self setLeftBarButtonItems:leftBarButtonItems fixedSpace:-6];
}

- (void) setLeftBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems fixedSpace : (CGFloat) space {
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = space;
    NSMutableArray * items = [NSMutableArray arrayWithArray:leftBarButtonItems];
    [items insertObject:spaceItem atIndex:0];
    
    self.navigationItem.leftBarButtonItems = items;
}

- (void) setRightBarButtonItem : (UIBarButtonItem *) item {
    self.navigationItem.rightBarButtonItem = item;
}

- (void) setRightBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems {
    [self setRightBarButtonItems:leftBarButtonItems fixedSpace:-8];
}

- (void) setRightBarButtonItems : (NSArray<UIBarButtonItem *> *) leftBarButtonItems fixedSpace : (CGFloat) space {
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = space;
    NSMutableArray * items = [NSMutableArray arrayWithArray:leftBarButtonItems];
    [items insertObject:spaceItem atIndex:0];
    self.navigationItem.rightBarButtonItems = items;
}

- (void) backAction {
    [self backActionWithComplete:nil];
}

- (void) backActionWithComplete : (void (^)()) completion {
    if ( self.navigationController.viewControllers.firstObject == self && self.navigationController.presentingViewController ) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:completion];
    } else if ( self.navigationController ) {
        [self.navigationController popViewControllerAnimated:YES];
        if ( completion ) completion();
    } else {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
}

- (UIButton *) buttonWithTitle : (NSString *) normalTitle
                highlightTitle : (NSString *) highlightTitle
                 selectedTitle : (NSString *) selectedTitle
                  disableTitle : (NSString *) disableTitle
                   normalColor : (UIColor *) normalColor
                highlightColor : (UIColor *) highlightColor
                 selectedColor : (UIColor *) selectedColor
                  disableColor : (UIColor *) disableColor
                   normalImage : (UIImage *) normalImage
                highlightImage : (UIImage *) highlightImage
                 selectedImage : (UIImage *) selectedImage
                  disableImage : (UIImage *) disableImage
                        target : (id) target
                        action : (SEL) action
                         event : (UIControlEvents) controlEvents {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    button.exclusiveTouch = YES;
    if ( normalTitle ) {
        [button setTitle:normalTitle forState:UIControlStateNormal];
    }
    if ( highlightTitle ) {
        [button setTitle:highlightTitle forState:UIControlStateHighlighted];
    }
    if ( selectedTitle ) {
        [button setTitle:selectedTitle forState:UIControlStateSelected];
    }
    if ( disableTitle ) {
        [button setTitle:disableTitle forState:UIControlStateDisabled];
    }
    if ( normalColor ) {
        [button setTitleColor:normalColor forState:UIControlStateNormal];
    }
    if ( highlightColor ) {
        [button setTitleColor:highlightColor forState:UIControlStateHighlighted];
    }
    if ( selectedColor ) {
        [button setTitleColor:selectedColor forState:UIControlStateSelected];
    }
    if ( disableColor ) {
        [button setTitleColor:disableColor forState:UIControlStateDisabled];
    }
    if ( normalImage ) {
        [button setImage:normalImage forState:UIControlStateNormal];
    }
    if ( highlightImage ) {
        [button setImage:highlightImage forState:UIControlStateHighlighted];
    }
    if ( selectedImage ) {
        [button setImage:selectedImage forState:UIControlStateSelected];
    }
    if ( disableImage ) {
        [button setImage:disableImage forState:UIControlStateDisabled];
    }
    if ( target && action ) {
        [button addTarget:target action:action forControlEvents:controlEvents];
    }
    [button sizeToFit];
    [button setEnlargeEdgeWithTop:10 right:10 bottom:10 left:20];

    return button;
}

- (void) setNavigationBarColor : (UIColor *) color {
    if ( color && self.navigationController ) {
        [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:color]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
}

- (UIImage *) imageWithColor : (UIColor *) color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  是否显示导航栏
 */
- (BOOL) shouldShowNavigationBar {
    if ( self.parentViewController ) {  //如果有父控制器，子控制器将不能控制导航栏出现｜除非修改本处代码
        return [self.parentViewController shouldShowNavigationBar];
    }
    return YES;
}

/**
 *  是否显示工具栏
 */
- (BOOL) shouldShowToolBar {
    if ( self.parentViewController ) {  //如果有父控制器，子控制器将不能控制工具栏出现｜除非修改本处代码
        return [self.parentViewController shouldShowToolBar];
    }
    return NO;
}
@end
