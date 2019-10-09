//
//  ViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.

#import "Constants+Network.h"
//HTTPS配置
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFNetworking.h"

#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES

@class LEQueueHelper;

/**
 * 对应环境变量
 * LEDistribution      =   0,       正式环境
 * LEGrayEnvironment   =   1,       灰度环境
 * LEDevelopment       =   2,       测试环境
 * LEPersonal          =   3,       个人环境
 */
#define LERunningEnvironment SERVER_TYPE

#define  TOKEN_EXPIRE_CODE 40001

typedef NS_ENUM(NSInteger, LEServiceError) {
    LEServiceErrorNotConnected      =   -1000,  /*  没有网络 */
    LEServiceErrorRequestError      =   -1001,  /*  请求错误,没有配置API或者请求出错 */
    LEServiceErrorFeachedNone       =   -1002,  /*  没有数据返回 */
    LEServiceErrorNotMatchData      =   -1003,  /*  返回数据不符合格式 */
    LEServiceErrorServerError       =   -1004,  /*  服务器报错 */
    LERequestErrorCouldNotInit      =   -1005,  /*  无法构造请求 */
    LERequestErrorTokenExpire      =   -1006,  /*  token过期 */

    LERequestErrorUnknow      =   -1089,  /*  未知错误 */

};  /*之所以要负数，因为要在NSError中抛出，避免与系统内置冲突*/

static NSString * const API_RCODE_KEY                  = @"code";               /*服务器返回编码*/
static NSString * const API_RMES_KEY                  = @"msg";             /*服务器提示信息*/
static NSString * const API_RSTATUSE_KEY               = @"status";            /*请求结果状态编码*/
static NSString * const API_REDIT_KEY                  = @"account.edit";       /*请求成功并处于编辑状态编码*/
static NSString * const API_RBANDING_KEY               = @"account.banding";    /*请求成功并处于绑定账号状态编码*/
static NSString * const API_SUBSCRIPTION_OFFLINE_KEY   = @"account.status.offline";    /*请求成功但对方处于下线状态（暂只用于关注与取消关注接口）*/
static NSInteger  const API_RTOKEN_EXPIRED_KEY         = 2;                     /*错误编码：请求token失效*/
static NSString * const NOTI_TOKEN_EXPIRED             = @"NOTI_TOKEN_EXPIRED"; /*token失效后将发送本通知，请在程序中添加对应逻辑*/
static NSString * const NOTI_DESKEY_LOST               = @"NOTI_DESKEY_LOST";   /*用户丢失了加密私钥*/
static NSString * const NOTI_USER_PICKOUT              = @"NOTI_TOKEN_PICKOUT"; /*用户被踢出*/
static NSString * const NOTI_NETWORK_NOTCONNECTION     = @"NOTI_NETWORK_NOTCONNECTION"; /*网络连接中断之后会发送本通知*/

/**-----------------------------------------------------------------------------
 * @name LEService
 * -----------------------------------------------------------------------------
 * 网络请求服务
 * 注意：
 * 1.iOS9需要在Info.plist中加入 NSAppTransportSecurity : @{ NSAllowsArbitraryLoads : YES}
 * 2.需要改变LERunningEnvironment确定当前环境，可以移植到其他文件但是必须被本文件导入
 */
@interface LEService : NSObject

+ (id) sharedInstance;

#pragma mark - 可重写
/**
 *  解析结构
 *
 *  @param responseObject jsonObject
 *  @param completeBlock  成功回调
 *  @param failedBlock    失败回调
 */
+ (void) doAnalysisResponseObject : (id) responseObject completion : (void(^)(id record)) completeBlock failure : (void(^)(LEServiceError type, NSError * error)) failedBlock;

/**
 *  地址传参形式的兼容，使用参数值替换占位符｜可以重写本方法用来适用更多情况
 *
 *  @param apiName      api后缀
 *  @param failedBlock  参数
 */
+ (NSString *) replaceUrlParams:(NSString *)apiName parameters:(NSDictionary *) parameters;

/**
 *  准备HTTP请求头
 */
+ (NSDictionary *) httpHeaderWithReqeustParams : (NSDictionary *) requestParams;
/**
 *  准备加密HTTP请求头
 */
+ (NSDictionary *) DESCHttpHeaderWithRequestParams : (NSDictionary *) parameters;

/**
 *  DES加密同时加密请求地址
 *
 *  @param absoluteUrl 未加密的请求地址
 *
 *  @return 已经加密的请求地址
 */
+ (NSURL *) encodeRequestAbsoluteUrl : (NSString *) absoluteUrl;

/**
 *  DES加密参数
 *
 *  @param parameters 请求参数
 *
 *  @return 已经加密的数据快
 */
+ (NSData *) encodeRequestWithPostParameters : (NSDictionary *) parameters;

/**
 *  错误提示生成
 */
+ (NSError *) errorWithLEServiceErrorType : (LEServiceError) type localizedDescriptionValue : (NSString *) description;

#pragma mark - HTTP 请求部分
/**
 *  添加http请求头内容
 */
+ (void) addHttpHeaderKey : (NSString *) key value : (id) value;

/**
 *  网络链接是否正常
 */
- (BOOL) isNetworkConnected;

/**
 *  关闭第三方请求中请求格式默认值为AFJSONRequestSerializer－>AFHTTPRequestSerializer
 *  此关闭方法只能生效一次，只对第三方请求生效
 */
+ (BOOL) requestSerializerCloseJson;

/**
 *  Get请求
 */
+ (void) get : (NSString *) urlKey
  parameters : (NSDictionary *) parameters
     success : (void(^)(id record)) successBlock
     failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 *  Get加密请求
 */
+ (void) DESGet : (NSString *) urlKey
     parameters : (NSDictionary *) parameters
        success : (void(^)(id record)) successBlock
        failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 *  Post请求1
 */
+ (void) post : (NSString *) urlKey
   parameters : (NSDictionary *) parameters
      success : (void(^)(id record)) successBlock
      failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

+ (void) afPost : (NSString *) urlKey
     parameters : (NSDictionary *) parameters
        success : (void(^)(id record)) successBlock
        failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 * Post加密请求1
 */
+ (void) DESPost : (NSString *) urlKey
      parameters : (NSDictionary *) parameters
         success : (void(^)(id record)) successBlock
         failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 *  Post请求2
 */
+ (void) post : (NSString *) urlKey
   parameters : (NSDictionary *) parameters
         body : (void(^)(id<AFMultipartFormData> formData)) bodyBlock
      success : (void(^)(id record)) successBlock
      failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 *  Post请求3(不能加密)
 */
+ (void) post : (NSString *) urlKey
urlRequestBlock : (void(^)(NSMutableURLRequest * request)) requestBlock
      success : (void(^)(id record)) successBlock
      failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 * Put请求
 */
+ (void) put : (NSString *) urlKey
  parameters : (NSDictionary *) parameters
     success : (void(^)(id record)) successBlock
     failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 * Delete请求
 */
+ (void) Delete : (NSString *) urlKey
     parameters : (NSDictionary *) parameters
        success : (void(^)(id record)) successBlock
        failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 * QUEUE队列并发
 */
+ (void) queue : (NSArray<NSDictionary<NSURLRequest *, void (^)(NSData *data, NSURLResponse *response, NSError *error)> *> * (^)()) constructBlock completeBlock : (void(^)(NSError * error)) completion;

/**
 * 请求操作，用于添加到队列中执行｜未开始，请不要用此方法构造分离的请求
 */
+ (NSDictionary<NSURLRequest *, void (^)(NSData *data, NSURLResponse *response, NSError *error)> *) requestPairWithURLKey : (NSString *) urlKey requestMethod : (NSString *) requestMethod parameters : (NSDictionary *) parameters success : (void(^)(id record)) successBlock failure : (void(^)(LEServiceError type, NSError * error)) failureBlock;

/**
 * 非客户端api，第三方api请求｜注意：不会走基本解析过滤操作
 */
+ (void) requestWithAbsoluteUrlKey : (NSString *) absoluteUrlString
                     requestMethod : (NSString *) requestMethod
                  headerParameters : (NSDictionary *) headerParameters
                        parameters : (NSDictionary *) parameters
                           success : (void(^)(id responseObject)) successBlock
                           failure : (void(^)(NSError * error)) failureBlock;

/**
 *  登出操作，停止所有请求
 */
+ (void) logoutAction;

/** 网络状态是否正常 */
+ (BOOL) isNetworkAvaliable;

#pragma mark - 读取配置内容部分
/**
 *  主机地址
 */
+ (NSString *) apiHost;

/**
 *  图片地址
 */
+ (NSString *) imageHost;

/**
 *  当前网络环境字符串
 */
+ (NSString *) currentReachabilityString;
/**
 *  设置主机地址
 */
+ (void) setApiHost:(NSString*)newUrl;
/**
 * 当前网络环境状态枚举值
 * Unknown = -1,
 * NotReachable = 0,
 * WWAN = 1,
 * WiFi = 2,
 */
+ (NSInteger) currentReachabilityCode;
@end

#define API_HOST                [LEService apiHost]
#define API_IMAGE_HOST          [LEService imageHost]

/*
 * 转换数据对象到字典或者数组
 */
UIKIT_EXTERN id LEConvertDataToDictionary(id data);

/*
 * 简易构造请求组
 */
UIKIT_EXTERN id LERequestPair(NSString * urlKey,
                              NSString * method,
                              NSDictionary * params,
                              void(^success)(id record),
                              void(^failure)(LEServiceError type, NSError * error));

/*
 * 简易队列请求
 */
UIKIT_EXTERN void LEQueueRequest(NSArray * (^constructBlock)(),
                                 void (^completion)(NSError * error));
