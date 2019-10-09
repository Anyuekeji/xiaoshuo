//
//  LEWKWebViewController.m
//  CallU
//
//  Created by Leaf on 16/6/20.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "LEWKWebViewController.h"
#import "LESafariActivity.h"

static void *LEWebBrowserContext = &LEWebBrowserContext;

@interface LEWKWebViewController ()

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) UIBarButtonItem *stopLoadingButton, *reloadButton, *backButton, *forwardButton, *actionButton, *fixedSeparator, *flexibleSeparator;

@property (nonatomic, strong) NSTimer *fakeProgressTimer;

@property (nonatomic, strong) NSURL *uiWebViewCurrentURL;

@property (strong, nonatomic) UIPopoverController *activitiyPopoverController;

@end

@implementation LEWKWebViewController

@synthesize URL = _URL;

#pragma mark - Dealloc
- (void)dealloc {
    [self.uiWebView setDelegate:nil];
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
    if ([self isViewLoaded]) {
        [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
}

#pragma mark - Static Initializers
+ (id) controller {
    LEWKWebViewController * webViewController = [[self alloc] initWithConfiguration:nil];
    webViewController.applicationActivities = @[[[LESafariActivity alloc] init]];
    webViewController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToWeibo];
    webViewController.hidesBottomBarWhenPushed = YES;
    return webViewController;
}

#pragma mark - Initializers
- (instancetype) init {
    return [self initWithConfiguration:nil];
}

- (instancetype) initWithConfiguration : (WKWebViewConfiguration *) configuration {
    self = [super init];
    if ( self ) {
        if ( [WKWebView class] ) {
            if ( configuration ) {
                self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            } else {
                self.wkWebView = [[WKWebView alloc] init];
            }
            self.wkWebViewBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.wkWebView];
        } else {
            self.uiWebView = [[UIWebView alloc] init];
            self.uiWebViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.uiWebView];
        }
        //默认显示工具栏
        _showsNavigationToolbar = YES;
        self.actionButtonHidden = NO;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.previousNavigationControllerToolbarHidden = self.navigationController.toolbarHidden;
    self.previousNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    //初始化工具栏,这个必须在前面
    [self setupToolBarItems];
    //
    [self setUpWebView];
    //
    [self setUpProgressView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //
    [self.navigationController.navigationBar addSubview:self.progressView];
    [self updateToolbarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //
    [self.uiWebView setDelegate:nil];
    [self.progressView removeFromSuperview];
}

- (BOOL) shouldShowNavigationBar {
    return YES;
}

- (BOOL) shouldShowToolBar {
    return _showsNavigationToolbar;
}

#pragma mark - Public Interface
- (void) registerHandleActions {

}

- (void) setUpJavascript {

}

- (void)loadRequest:(NSURLRequest *)request {
    if ( self.wkWebView ) {
        [self.wkWebView loadRequest:request];
    } else if ( self.uiWebView ) {
        [self.uiWebView loadRequest:request];
    }
}

- (void)loadURL:(NSURL *)URL {
    _URL = URL;
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    if ( self.wkWebView ) {
        [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
    } else if ( self.uiWebView ) {
        [self.uiWebView loadHTMLString:HTMLString baseURL:nil];
    }
}

#pragma mark - ToolBarItems
- (void)setActionButtonHidden:(BOOL)actionButtonHidden {
    _actionButtonHidden = actionButtonHidden;
    [self updateToolbarState];
}

- (void) setupToolBarItems {
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                           target:self
                                                                           action:@selector(stopButtonPressed:)];
    //
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self
                                                                      action:@selector(refreshButtonPressed:)];
    //
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(backButtonPressed:)];
    //
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(forwardButtonPressed:)];
    //
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    //
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                      target:self
                                                                      action:@selector(action:)];
    //
    self.flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    //
    self.fixedSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                        target:nil
                                                                        action:nil];
    self.fixedSeparator.width = 50.0f;
}

- (UIImage *) backButtonImage {
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *) forwardButtonImage {
    static UIImage *image;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];
        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat x_mid = size.width / 2.0;
        CGFloat y_mid = size.height / 2.0;
        CGContextTranslateCTM(context, x_mid, y_mid);
        CGContextRotateCTM(context, M_PI);
        [backButtonImage drawAtPoint:CGPointMake(-x_mid, -y_mid)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (void)backButtonPressed:(id)sender {
    if ( self.wkWebView ) {
        [self.wkWebView goBack];
    } else if ( self.uiWebView ) {
        [self.uiWebView goBack];
    }
    [self updateToolbarState];
}

- (void)forwardButtonPressed:(id)sender {
    if ( self.wkWebView ) {
        [self.wkWebView goForward];
    } else if ( self.uiWebView ) {
        [self.uiWebView goForward];
    }
    [self updateToolbarState];
}

- (void)refreshButtonPressed:(id)sender {
    if ( self.wkWebView ) {
        [self.wkWebView stopLoading];
        if ( !self.wkWebView.URL && _URL ) {
            [self loadURL:_URL];
        } else {
            [self.wkWebView reload];
        }
    } else if ( self.uiWebView ) {
        [self.uiWebView stopLoading];
        if ( self.uiWebView.request.URL && [self.uiWebView.request.URL.absoluteString isBlank] && _URL ) {
            [self loadURL:_URL];
        } else {
            [self.uiWebView reload];
        }
    }
}

- (void)stopButtonPressed:(id)sender {
    if ( self.wkWebView ) {
        [self.wkWebView stopLoading];
    } else if ( self.uiWebView ) {
        [self.uiWebView stopLoading];
    }
}

- (void) action : (id) sender {
    if (self.activitiyPopoverController.popoverVisible) {
        [self.activitiyPopoverController dismissPopoverAnimated:YES];
        return;
    }
    NSURL * requestURL = self.wkWebView.URL ? self.wkWebView.URL : self.uiWebView.request.URL;
    //
    NSArray *activityItems;
    if ( self.activityItems ) {
        if ( requestURL ) {
            activityItems = [self.activityItems arrayByAddingObject:requestURL];
        } else {
            activityItems = self.activityItems;
        }
    } else if (requestURL ) {
        activityItems = @[requestURL];
    }
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                     applicationActivities:self.applicationActivities];
    if (self.excludedActivityTypes) {
        vc.excludedActivityTypes = self.excludedActivityTypes;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:vc animated:YES completion:NULL];
    } else {
        if (!self.activitiyPopoverController) {
            self.activitiyPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        }
        self.activitiyPopoverController.delegate = self;
        [self.activitiyPopoverController presentPopoverFromBarButtonItem:[self.toolbarItems lastObject]
                                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) reload {
    [self refreshButtonPressed:nil];
}

- (NSURL *) URL {
    if(self.wkWebView) {
        return self.wkWebView.URL && ![self.wkWebView.URL.absoluteString isBlank] ? self.wkWebView.URL : _URL;
    } else if(self.uiWebView) {
        return self.uiWebView.request.URL && ![self.uiWebView.request.URL.absoluteString isBlank] ? self.uiWebView.request.URL : _URL;
    }
    return nil;
}

- (void) setStaticTitle:(NSString *)staticTitle {
    _staticTitle = staticTitle;
    [self updateNavigationTitle];
}

#pragma mark - Toolbar State
- (void)updateToolbarState {
    [self updateNavigationTitle];
    
    if ( !self.showsNavigationToolbar || !self.backButton ) {
        return ;
    }
    BOOL canGoBack = self.wkWebView.canGoBack || self.uiWebView.canGoBack;
    BOOL canGoForward = self.wkWebView.canGoForward || self.uiWebView.canGoForward;
    
    [self.backButton setEnabled:canGoBack];
    [self.forwardButton setEnabled:canGoForward];
    
    NSArray *barButtonItems;
    if( self.wkWebView.loading || self.uiWebViewIsLoading ) {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.stopLoadingButton, self.flexibleSeparator];
    } else {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.reloadButton, self.flexibleSeparator];
    }
    
    if ( !self.actionButtonHidden ) {
        NSMutableArray *mutableBarButtonItems = [NSMutableArray arrayWithArray:barButtonItems];
        [mutableBarButtonItems addObject:self.actionButton];
        barButtonItems = [NSArray arrayWithArray:mutableBarButtonItems];
    }
    
    [self setToolbarItems:barButtonItems animated:YES];
}

//更新标题
- (void) updateNavigationTitle {
    if (!self.navigationItem.titleView) {
        if ( self.staticTitle ) {
            self.title = self.staticTitle;
        } else if ( self.wkWebView.loading || self.uiWebViewIsLoading ) {
            NSString *URLString;
            if( self.wkWebView ) {
                URLString = [self.wkWebView.URL absoluteString];
            } else if ( self.uiWebView ) {
                URLString = [self.uiWebViewCurrentURL absoluteString];
            }
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length]-1];
           // self.title = URLString;
        } else {
            if ( self.wkWebView ) {
                self.title = self.wkWebView.title;
            } else if ( self.uiWebView ) {
                self.title = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
            }
        }
    }

}

#pragma mark - WebView
- (void) setUpWebView {
    if ( self.wkWebView ) {
        [self.wkWebView setFrame:self.view.bounds];
        [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//        [self.wkWebView setNavigationDelegate:self];
        [self.wkWebView setUIDelegate:self];
        [self.wkWebView setMultipleTouchEnabled:YES];
        [self.wkWebView setAutoresizesSubviews:YES];
        [self.wkWebView.scrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:self.wkWebView];
        
        [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:LEWebBrowserContext];
        //
        [self.wkWebViewBridge setWebViewDelegate:self];
        [self registerHandleActions];
    } else if( self.uiWebView ) {
        [self.uiWebView setFrame:self.view.bounds];
        [self.uiWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//        [self.uiWebView setDelegate:self];
        [self.uiWebView setMultipleTouchEnabled:YES];
        [self.uiWebView setAutoresizesSubviews:YES];
        [self.uiWebView setScalesPageToFit:YES];
        [self.uiWebView.scrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:self.uiWebView];
        //
        [self.uiWebViewBridge setWebViewDelegate:self];
        [self registerHandleActions];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ( webView == self.uiWebView ) {
        //先检测是否需要触发事件
        NSURL * URL = request.URL;
        BOOL allow = [self didStartLoadingURL:URL];
        if ( !allow ) { return NO; }
        //如果是打开AppStore或者其他跳转操作
        if(![self externalAppRequiredToOpenURL:URL]) {
            self.uiWebViewCurrentURL = URL;
            self.uiWebViewIsLoading = YES;
            [self updateToolbarState];
            
            [self fakeProgressViewStartLoading];
            //
            if([self.delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)]) {
                allow = [self.delegate webBrowser:self didStartLoadingURL:URL];
            }
            return allow;
        } else if ( URL.scheme ) {
            [self launchExternalAppWithURL:URL];
            return NO;
        } else {
            return NO;
        }
    }
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ( webView == self.uiWebView ) {
        if ( !self.uiWebView.isLoading ) {
            self.uiWebViewIsLoading = NO;
            [self updateToolbarState];
            [self fakeProgressBarStopLoading];
        }
        //
        [self didFinishLoadingURL:self.uiWebView.request.URL];
        if ( [self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingURL:)] ) {
            [self.delegate webBrowser:self didFinishLoadingURL:self.uiWebView.request.URL];
        }
        [self setUpJavascript];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ( webView == self.uiWebView ) {
        if ( !self.uiWebView.isLoading ) {
            self.uiWebViewIsLoading = NO;
            [self updateToolbarState];
            
            [self fakeProgressBarStopLoading];
        }
        //
        NSURL * errorURL = webView.request.URL ? webView.request.URL : [[error userInfo] objectForKey:NSURLErrorFailingURLErrorKey];
        errorURL = errorURL && ![errorURL.absoluteString isBlank] ? errorURL : [self URL];
        [self didFailToLoadURL:errorURL error:error];
        if ( [self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)] ) {
            [self.delegate webBrowser:self didFailToLoadURL:errorURL error:error];
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ( webView == self.wkWebView ) {
        [self updateToolbarState];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ( webView == self.wkWebView ) {
        [self updateToolbarState];
        //
        [self didFinishLoadingURL:webView.URL];
        if ( [self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingURL:)] ) {
            [self.delegate webBrowser:self didFinishLoadingURL:webView.URL];
        }
        [self setUpJavascript];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if ( webView == self.wkWebView ) {
        [self updateToolbarState];
        //
        NSURL *URL = [[error userInfo] objectForKey:NSURLErrorFailingURLErrorKey];
        NSURL * errorURL = URL ? URL :  webView.URL;
        errorURL = errorURL && ![errorURL.absoluteString isBlank] ? errorURL : [self URL];
        [self didFailToLoadURL:errorURL error:error];
        if ( [self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)] ) {
            [self.delegate webBrowser:self didFailToLoadURL:errorURL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if ( webView == self.wkWebView ) {
        [self updateToolbarState];
        //
        NSURL *URL = [[error userInfo] objectForKey:NSURLErrorFailingURLErrorKey];
        NSURL * errorURL = URL ? URL :  webView.URL;
        errorURL = errorURL && ![errorURL.absoluteString isBlank] ? errorURL : [self URL];
        [self didFailToLoadURL:errorURL error:error];
        if ( [self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)] ) {
            [self.delegate webBrowser:self didFailToLoadURL:errorURL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    BOOL allow = [self didStartLoadingURL:URL];
    if ( !allow ) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return ;
    }
    if( [self.delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)] ) {
        allow = [self.delegate webBrowser:self didStartLoadingURL:URL];
    }
    if (!allow)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        return ;
    }
    if(webView == self.wkWebView) {
        

        //如果是打开AppStore或者其他跳转操作
        if(![self externalAppRequiredToOpenURL:URL]) {
            if(!navigationAction.targetFrame) {
                [self loadURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return ;
            }
        } else if ( URL.scheme ) {
            decisionHandler(WKNavigationActionPolicyCancel);
            [self launchExternalAppWithURL:URL];
            return ;
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
            return ;
        }
    }
    //
    if( [self.delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)] ) {
        allow = [self.delegate webBrowser:self didStartLoadingURL:URL];
    }
    decisionHandler( allow ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

#pragma mark - External App Support
- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https", @"wvjbscheme", @"about"]];
    return ![validSchemes containsObject:URL.scheme];
}

- (void)launchExternalAppWithURL:(NSURL *)URL {
    [self didLaunchExternalAppWithURL:URL];
    if ( [self.delegate respondsToSelector:@selector(webBrowser:didLaunchExternalAppWithURL:)] ) {
        [self.delegate webBrowser:self didLaunchExternalAppWithURL:URL];
    }
}

- (void) backAction {
    [self fakeProgressBarStopLoading];
    [super backAction];
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"我知道了"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              completionHandler();
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              completionHandler(NO);
                                                          }];
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                              completionHandler(YES);
                                                          }];
    [alert addAction:defaultAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = prompt;
        textField.text = defaultText;
    }];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              completionHandler(nil);
                                                          }];
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField * textField = alert.textFields.firstObject;
                                                              NSString * text = textField.text;
                                                              completionHandler(text);
                                                          }];
    [alert addAction:defaultAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Estimated Progress KVO (WKWebView)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( [keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView ) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Fake Progress Bar Control (UIWebView)
- (void) setUpProgressView {
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
}

- (void)fakeProgressViewStartLoading {
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!self.fakeProgressTimer) {
        self.fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire:) userInfo:nil repeats:YES];
    }
}

- (void)fakeProgressBarStopLoading {
    if(self.fakeProgressTimer) {
        [self.fakeProgressTimer invalidate];
    }
    
    if(self.progressView) {
        [self.progressView setProgress:1.0f animated:YES];
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressView setProgress:0.0f animated:NO];
        }];
    }
}

- (void)fakeProgressTimerDidFire:(id)sender {
    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
    if([self.uiWebView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.95) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

#pragma mark - Override Interface
- (BOOL) didStartLoadingURL : (NSURL *) URL {
    return YES;
}

- (void) didFinishLoadingURL : (NSURL *) URL {

}
- (void) didFailToLoadURL : (NSURL *) URL error : (NSError *) error {

}
- (void) didLaunchExternalAppWithURL : (NSURL *) URL {
    if ( [[UIApplication sharedApplication] canOpenURL:URL] ) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        Debug(@">> ERROR : 无法执行App跳转,请核查路径:%@",URL);
    }
}

@end
