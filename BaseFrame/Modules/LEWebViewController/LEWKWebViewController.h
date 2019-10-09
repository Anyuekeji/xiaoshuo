//
//  LEWKWebViewController.h
//  CallU
//
//  Created by Leaf on 16/6/20.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "LEAFViewController.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"

@class LEWKWebViewController;

/**
 *  LEWKWebView代理，注意：协议和子类重写方法同时存在，请选择一种方式控制
 */
@protocol LEWKWebViewDelegate <NSObject>

@optional
/**
 *  将要开始加载地址｜注意如果返回NO，将强制停止加载动作｜此协议优先级大于子类重写方法didStartLoadingURL的优先级
 */
- (BOOL)webBrowser:(LEWKWebViewController *)webBrowser didStartLoadingURL:(NSURL *)URL;
/**
 *  加载完成回调
 */
- (void)webBrowser:(LEWKWebViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL;
/**
 *  加载失败回调
 */
- (void)webBrowser:(LEWKWebViewController *)webBrowser didFailToLoadURL:(NSURL *)URL error:(NSError *)error;
/**
 *  将要执行跳转到其他App操作
 */
- (void)webBrowser:(LEWKWebViewController *)webBrowser didLaunchExternalAppWithURL:(NSURL *)URL;

@end

@interface LEWKWebViewController : LEAFViewController <WKNavigationDelegate, WKUIDelegate, UIWebViewDelegate, UIPopoverControllerDelegate>

#pragma mark - Public Properties
//代理
@property (nonatomic, weak) id <LEWKWebViewDelegate> delegate;
//进度条
@property (nonatomic, strong) UIProgressView *progressView;
//如果是iOS8将使用WKWebView
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) WKWebViewJavascriptBridge *wkWebViewBridge;
//如果是iOS7将使用UIWebView
@property (nonatomic, strong) UIWebView *uiWebView;
@property (nonatomic, strong) WebViewJavascriptBridge *uiWebViewBridge;
@property (nonatomic, assign) BOOL uiWebViewIsLoading;
//当前加载的请求地址
@property (nonatomic, readonly, strong) NSURL * URL;
//静态的标题|如果要固定标题不便请赋值此属性
@property (nonatomic, strong) NSString * staticTitle;

/** The array of data objects on which to perform the activity. */
@property (strong, nonatomic) NSArray *activityItems;
/** An array of UIActivity objects representing the custom services that your application supports. */
@property (strong, nonatomic) NSArray *applicationActivities;
/** The list of services that should not be displayed. */
@property (strong, nonatomic) NSArray *excludedActivityTypes;
/**
 * 是否显示工具栏，默认YES
 */
@property (assign, nonatomic) BOOL showsNavigationToolbar;
/**
 *  是否显示工具动作按钮
 */
@property (nonatomic, assign) BOOL actionButtonHidden;

#pragma mark - Static Initializers
- (id) initWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

#pragma mark - Public Interface
//注册被调用方法
- (void) registerHandleActions;
//初始化JS注入
- (void) setUpJavascript;
//加载一个请求
- (void) loadRequest:(NSURLRequest *)request;
//加载一个url链接
- (void) loadURL:(NSURL *)URL;
//加载一个url string地址链接
- (void) loadURLString:(NSString *)URLString;
//加载静态HTML文件
- (void) loadHTMLString:(NSString *)HTMLString;
//重新加载
- (void) reload;

#pragma mark - Override Interface
- (void) updateNavigationTitle;
- (BOOL) didStartLoadingURL : (NSURL *) URL;
- (void) didFinishLoadingURL : (NSURL *) URL;
- (void) didFailToLoadURL : (NSURL *) URL error : (NSError *) error;
- (void) didLaunchExternalAppWithURL : (NSURL *) URL;

@end
