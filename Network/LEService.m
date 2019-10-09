//
//  ViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.

#import "LEService.h"

#import "LEConfigurate.h"
#import "LEDataTaskManager.h"
#import "NSArray+YYAdd.h"
#import "NSObject+YYModel.h"

@interface LEService ()

@property (nonatomic, strong) LEConfigurate * configurate;
@property (nonatomic, assign) AFNetworkReachabilityStatus status;
@property (nonatomic, strong) NSMutableDictionary * httpHeaderDictionary;
@property (nonatomic, strong) AFHTTPSessionManager * sslManager;
@property (nonatomic, assign, getter=isRequestSerializerJSON) BOOL requestSerializerJson;

@end

@implementation LEService

- (void) dealloc {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    _configurate = nil;
    _httpHeaderDictionary = nil;
}

+ (id) sharedInstance {
    static LEService * _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (instancetype) init {
    if ( self = [super init] ) {
        [self setUp];
    }
    return self;
}

- (void) setUp {
    self.configurate = [LEConfigurate configurationWithEnvironment:LERunningEnvironment fileName:nil];

    [self setNetworkParams];

    //开启网络监听
    [self enableReachablility];
}
-(void)setNetworkParams
{
    //HTTPS请求配置
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;    //如果不用验证域名|YES:需要验证域名
   // AYLog(@"the url is %@",[self.configurate sslUrlPrefix]);
    NSString*url= [[self.configurate sslUrlPrefix] stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.sslManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    [self.sslManager setSecurityPolicy:securityPolicy];
    [self.sslManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [self.sslManager setRequestSerializer:
     [AFJSONRequestSerializer serializer]];
    [self.sslManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    //
    _requestSerializerJson = YES;
}
#pragma mark - 开始网络状态监听
- (void) enableReachablility {
    __weak LEService * weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        weakSelf.status = status;
        Debug(@"网络状态变更 : %@", AFStringFromNetworkReachabilityStatus(status));
        if ( status == AFNetworkReachabilityStatusNotReachable ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_NETWORK_NOTCONNECTION object:nil];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
     _status = AFNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL) isNetworkConnected {
    return _status != AFNetworkReachabilityStatusNotReachable;
}

#pragma mark - 网络请求辅助方法
/**
 *  关闭第三方请求中请求格式默认值为AFJSONRequestSerializer－>AFHTTPRequestSerializer
 *  此关闭方法只能生效一次，只对第三方请求生效
 */
+ (BOOL) requestSerializerCloseJson {
    [[self sharedInstance] setRequestSerializerJson:NO];
    return [[self sharedInstance] isRequestSerializerJSON];
}

+ (BOOL) openRequestSerializerJson {
    [[self sharedInstance] setRequestSerializerJson:YES];
    return YES;
}

+ (BOOL) isRequestSerializerJSON {
    return [[self sharedInstance] isRequestSerializerJSON];
}

+ (AFHTTPSessionManager *) manager {
    return [[self sharedInstance] sslManager];
}
/**
 *  错误提示生成
 */
+ (NSError *) errorWithLEServiceErrorType : (LEServiceError) type localizedDescriptionValue : (NSString *) description {
    NSString * localizedDescKey = @"";
    switch ( type ) {
        case LEServiceErrorNotConnected:
            localizedDescKey =AYLocalizedString(@"网络出现问题");
            break;
        case LEServiceErrorFeachedNone:
            localizedDescKey = @"服务器返回数据为空！";
            break;
        case LEServiceErrorRequestError:
            localizedDescKey = @"请求错误，未录入API接口！->";
            localizedDescKey = [localizedDescKey stringByAppendingString:description];
            break;
        case LEServiceErrorServerError:
            localizedDescKey = description != nil ? description : @"服务器报错，请检查返回值!";
            break;
        case LEServiceErrorNotMatchData:
            localizedDescKey = @"服务器返回的数据无法转译成NSDictionary!";
            break;
        case LERequestErrorCouldNotInit:
            localizedDescKey = description != nil ? description : @"构造请求失败！";
            break;
        case LERequestErrorUnknow:
            localizedDescKey = description != nil ? description :AYLocalizedString(@"未知错误");
        case LERequestErrorTokenExpire:
            localizedDescKey = description != nil ? description : @"token过期！";
            break;
        default:
            break;
    }
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               localizedDescKey, NSLocalizedDescriptionKey,
                               nil];
    return [NSError errorWithDomain:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
                               code:type
                           userInfo:userInfo];
}

+ (NSError *) errorFilter : (NSError *) error {
    if ( error && error.code == -1011 ) { //无法连接到服务器
        if ( error.userInfo && [error.userInfo.allKeys containsObject:@"com.alamofire.serialization.response.error.response"] ) {
            error = [NSError errorWithDomain:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] code:error.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Plista服务器已经收到过本条数据", NSLocalizedDescriptionKey, nil]];
        } else {
            error = [NSError errorWithDomain:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] code:error.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"无法连接服务器", NSLocalizedDescriptionKey, nil]];
        }
    }
    if ( error && error.code == -999 ) {
        error = nil;
    }
    return error;
}

/**
 *  设置http请求头
 */
- (void) setUpHttpHeader {
    if ( _httpHeaderDictionary ) {
        NSDictionary * headerDictionary = [NSDictionary dictionaryWithDictionary:_httpHeaderDictionary];
        [headerDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[self.sslManager requestSerializer] setValue:obj forHTTPHeaderField:key];
        }];
    }
}

/**
 *  DES加密同时加密请求地址
 */
+ (NSURL *) encodeRequestAbsoluteUrl : (NSString *) absoluteUrl {
    //子类重写
    return [NSURL URLWithString:absoluteUrl];
}

/**
 *  DES加密参数
 *
 *  @param parameters 请求参数
 *
 *  @return 已经加密的数据快
 */
+ (NSData *) encodeRequestWithPostParameters : (NSDictionary *) parameters {
    //子类重写
    return nil;
}

/**
 *  准备HTTP请求头
 */
+ (NSDictionary *) httpHeaderWithReqeustParams : (NSDictionary *) requestParams {
    return nil;
}
/**
 *  准备加密HTTP请求头
 */
+ (NSDictionary *) DESCHttpHeaderWithRequestParams : (NSDictionary *) parameters {
    return nil;
}

/**
 *  添加http请求头内容
 */
+ (void) addHttpHeaderKey:(NSString *)key value:(id)value {
    if ( [[self sharedInstance] httpHeaderDictionary] == nil ) {
        [[self sharedInstance] setHttpHeaderDictionary:[NSMutableDictionary dictionary]];
    }
    
    if ( key != nil && value != nil ) {
        [[[self sharedInstance] httpHeaderDictionary] setObject:value forKey:key];
    }
}

/**
 *  检查网络环境
 */
+ (BOOL) checkNetWorkStatusWithFailureBlock : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    if ( ![[self sharedInstance] isNetworkConnected] && failureBlock ) {
        failureBlock(LEServiceErrorNotConnected,
                     [LEService errorWithLEServiceErrorType:LEServiceErrorNotConnected localizedDescriptionValue:nil]);
        return NO;
    }
    return YES;
}

/**
 *  检查API是否存在
 */
+ (NSString *) checkAPIKey : (NSString *) key
          withFailureBlock : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    NSString * apiName = [[[self sharedInstance] configurate] api:key];
    if ( apiName == nil && failureBlock ) {
        failureBlock(LEServiceErrorRequestError,
                     [self errorWithLEServiceErrorType:LEServiceErrorRequestError localizedDescriptionValue:key]);
    }
    return apiName;
}

/**
 * 返回数据解析
 */
+ (void) analysisResponseObject : (id) responseObject request:(NSURLRequest *) request completion : (void(^)(id record)) completeBlock failure : (void(^)(LEServiceError type, NSError * error)) failedBlock {
    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    AYLog(@"request is %@ the response str is %@",(request?[[request URL] absoluteString]:@""),responseStr);
    responseObject = LEConvertDataToDictionary(responseObject);
    //AYLog(@"the responseObject is %@",responseObject);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doAnalysisResponseObject:responseObject completion:completeBlock failure:failedBlock];
    });
}

/**
 *  返回数据过滤
 */
+ (void) doAnalysisResponseObject : (id) responseObject completion : (void(^)(id record)) completeBlock failure : (void(^)(LEServiceError type, NSError * error)) failedBlock {
    //
}

/**
 *  地址传参形式的兼容，使用参数值替换占位符
 */
+ (NSString *) replaceUrlParams:(NSString *)apiName parameters:(NSDictionary *) parameters {
    if (!parameters || ![apiName containsString:@"{"] ) {
        return apiName;
    }
    
    __block NSString * url = apiName;
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]]) {
            NSString * value = nil;
            if ([obj isKindOfClass:[NSString class]]) {
                value = obj;
            } else {
                value = [NSString stringWithFormat:@"%@", obj];
            }
            url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:value];
        }
    }];
    return url;
}

#pragma mark - URLRquest
+ (NSMutableURLRequest *) requestWithApi : (NSString *) api parameters : (NSDictionary *) parameters method : (NSString *) method failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    NSError * error = nil;
    NSString * urlString = [[NSURL URLWithString:api relativeToURL:[self manager].baseURL] absoluteString];
    NSMutableURLRequest * request = [[self manager].requestSerializer requestWithMethod:method URLString:urlString parameters:parameters error:&error];
    if ( error ) {
        Debug(@">> <%@>构造请求Request对象失败：%@", api, error);
        if ( failureBlock ) failureBlock(LERequestErrorCouldNotInit, error);
    }
    
    AYLog(@"the request is url is %@",[request URL].absoluteString);
    //
    //重新拼凑http请求头
    [[self httpHeaderWithReqeustParams:parameters] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [request.allHTTPHeaderFields.allKeys containsObject:key] ) {
            [request setValue:obj forHTTPHeaderField:key];
        } else {
            [request addValue:obj forHTTPHeaderField:key];
        }
    }];
//    [manager.requestSerializersetValue:@"application/json"forHTTPHeaderField:@"Accept"];
   // [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

+ (NSMutableURLRequest *) requestPOSTWithApi : (NSString *) api parameters : (NSDictionary *) parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    NSError * error = nil;
    NSString * urlString = [[NSURL URLWithString:api relativeToURL:[self manager].baseURL] absoluteString];
    NSMutableURLRequest * request = [[self manager].requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:block error:&error];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    if ( error ) {
        Debug(@">> <%@>构造请求Request对象失败：%@", api, error);
        if ( failureBlock ) failureBlock(LERequestErrorCouldNotInit, error);
    }
    //重新拼凑http请求头
    [[self httpHeaderWithReqeustParams:parameters] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [request.allHTTPHeaderFields.allKeys containsObject:key] ) {
            [request setValue:obj forHTTPHeaderField:key];
        } else {
            [request addValue:obj forHTTPHeaderField:key];
        }
    }];
    //
    return request;
}

+ (NSDictionary *) requestParamsAnalysis : (NSDictionary *) requestParams {
    __block NSMutableDictionary * changedParams = nil;
    [requestParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [obj isKindOfClass:NSArray.class] ) {
            if ( !changedParams ) {
                changedParams = [NSMutableDictionary dictionaryWithCapacity:requestParams.count];
                [changedParams addEntriesFromDictionary:requestParams];
            }
            NSString * value = [obj modelToJSONString];
            if ( value ) {
                [changedParams setObject:value forKey:key];
            }
        }
    }];
    return changedParams ? changedParams : requestParams;
}

+ (void) sendRequest : (NSURLRequest *) request success : (void(^)(id record)) successBlock failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    [[LEDataTaskManager sharedManager] appendSessionDataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ( error ) {
            Debug(@">> request %@ 请求失败：%@",[request.URL absoluteString], [error localizedDescription]);
            error = [self errorFilter:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( failureBlock ) failureBlock(LEServiceErrorRequestError, error);
            });
        } else {
            [self analysisResponseObject:data request:request  completion:successBlock failure:failureBlock];
        }
    }];
}

#pragma mark - 各种网络请求
/**
 *  Get请求
 */
+ (void) get : (NSString *) urlKey
  parameters : (NSDictionary *) parameters
     success : (void(^)(id record)) successBlock
     failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    //地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    
    //3.构造requestURL
    NSMutableURLRequest * request = [self requestWithApi:apiName parameters:parameters method:@"GET" failure:failureBlock];
    if ( !request ) return ;
    
    //4.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

/**
 *  Get加密请求
 */
+ (void) DESGet : (NSString *) urlKey
     parameters : (NSDictionary *) parameters
        success : (void(^)(id record)) successBlock
        failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1 .检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2. 找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    // 地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    
    //3.构造requestURL
    NSError * error = nil;
    NSString * urlString = [[NSURL URLWithString:apiName relativeToURL:[self manager].baseURL] absoluteString];
    NSMutableURLRequest * request = [[self manager].requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:parameters error:&error];
    if ( error ) {
        Debug(@">> <%@>构造请求Request对象失败：%@", apiName, error);
        if ( failureBlock ) failureBlock(LERequestErrorCouldNotInit, error);
        return ;
    }
    //重新拼凑http请求头
    [[self DESCHttpHeaderWithRequestParams:parameters] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [request.allHTTPHeaderFields.allKeys containsObject:key] ) {
            [request setValue:obj forHTTPHeaderField:key];
        } else {
            [request addValue:obj forHTTPHeaderField:key];
        }
    }];
    if ( !request ) return ;
    //3.1 加密请求地址
    [request setURL:[self encodeRequestAbsoluteUrl:request.URL.absoluteString]];
    //3.2 改变contentType
    [request setValue:@"text/plain;charset=UTF-8" forHTTPHeaderField:@"content-type"];

    //4.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

/**
 *  Post请求1
 */
+ (void) post : (NSString *) urlKey
   parameters : (NSDictionary *) parameters
      success : (void(^)(id record)) successBlock
      failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    //地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];

    //3.构造requestURL
    NSMutableURLRequest * request = [self requestWithApi:apiName parameters:parameters method:@"POST" failure:failureBlock];
    if ( !request ) return  ;
    //4.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

/**
 * Post加密请求1
 */
+ (void) DESPost : (NSString *) urlKey
      parameters : (NSDictionary *) parameters
         success : (void(^)(id record)) successBlock
         failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1 .检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2. 找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    // 地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    
    //3.构造requestURL
    NSError * error = nil;
    NSString * urlString = [[NSURL URLWithString:apiName relativeToURL:[self manager].baseURL] absoluteString];
    NSMutableURLRequest * request = [[self manager].requestSerializer requestWithMethod:@"POST" URLString:urlString parameters:@{} error:&error];
    if ( error ) {
        Debug(@">> <%@>构造请求Request对象失败：%@", apiName, error);
        if ( failureBlock ) failureBlock(LERequestErrorCouldNotInit, error);
        return ;
    }
    //重新拼凑http请求头
    [[self DESCHttpHeaderWithRequestParams:parameters] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [request.allHTTPHeaderFields.allKeys containsObject:key] ) {
            [request setValue:obj forHTTPHeaderField:key];
        } else {
            [request addValue:obj forHTTPHeaderField:key];
        }
    }];
    
    if ( !request ) return ;
    //3.1 加密请求地址
    [request setURL:[self encodeRequestAbsoluteUrl:request.URL.absoluteString]];
    //3.2 加密参数
    [request setHTTPBody:[self encodeRequestWithPostParameters:parameters]];
    //3.3 改变contentType
    [request setValue:@"text/plain;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    //4.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

+ (void) afPost : (NSString *) urlKey
     parameters : (NSDictionary *) parameters
        success : (void(^)(id record)) successBlock
        failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    //地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    
    //
    [[self httpHeaderWithReqeustParams:parameters] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[self manager].requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    //3.开始请求
    [[self manager] POST:apiName
              parameters:parameters
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     [self analysisResponseObject:responseObject request:nil completion:successBlock failure:failureBlock];
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     error = [self errorFilter:error];
                     if ( failureBlock ) failureBlock(LEServiceErrorRequestError, error);
                 }];
}

/**
 *  Post请求2
 */
+ (void) post : (NSString *) urlKey
   parameters : (NSDictionary *) parameters
         body : (void(^)(id<AFMultipartFormData> formData)) bodyBlock
      success : (void(^)(id record)) successBlock
      failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    //地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    
    //3.构造requestURL
    NSMutableURLRequest * request = [self requestPOSTWithApi:apiName parameters:parameters constructingBodyWithBlock:bodyBlock failure:failureBlock];
    if ( !request ) return ;
    
    //4.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

/**
 *  Post请求3(不能加密)
 */
+ (void) post : (NSString *) urlKey
urlRequestBlock : (void(^)(NSMutableURLRequest * request)) requestBlock
      success : (void(^)(id record)) successBlock
      failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    
    //3.构造requestURL
    NSMutableURLRequest * request = [self requestWithApi:apiName parameters:nil method:@"POST" failure:failureBlock];
    if ( !request ) return ;

    //4.改变request
    if ( requestBlock ) requestBlock(request);

    //5.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

/**
 * Put请求
 */
+ (void) put : (NSString *) urlKey
  parameters : (NSDictionary *) parameters
     success : (void(^)(id record)) successBlock
     failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    //地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    
    //3.构造requestURL
    NSMutableURLRequest * request = [self requestWithApi:apiName parameters:parameters method:@"PUT" failure:failureBlock];
    if ( !request ) return ;
    
    //4.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

/**
 * Delete请求
 */
+ (void) Delete : (NSString *) urlKey
     parameters : (NSDictionary *) parameters
        success : (void(^)(id record)) successBlock
        failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![self checkNetWorkStatusWithFailureBlock:failureBlock] )  return ;    //如果网络不通直接结束方法
    //1.1 参数重设
    parameters = [self requestParamsAnalysis:parameters];
    
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil )   return ;    //如果未找到接口名字，直接结束方法
    //地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    
    //3.构造requestURL
    NSMutableURLRequest * request = [self requestWithApi:apiName parameters:parameters method:@"DELETE" failure:failureBlock];
    if ( !request ) return ;
    
    //4.开始请求
    [self sendRequest:request success:successBlock failure:failureBlock];
}

+ (void) queue : (NSArray<NSDictionary<NSURLRequest *, void (^)(NSData *data, NSURLResponse *response, NSError *error)> *> * (^)()) constructBlock completeBlock : (void(^)(NSError * error)) completion {
    //1. 检查网络状态
    if ( ![[self sharedInstance] isNetworkConnected] ) {
        DPrintf("ERROR>>Queue: Network not in connected !\n");
        if ( completion ) completion([LEService errorWithLEServiceErrorType:LEServiceErrorNotConnected localizedDescriptionValue:nil]);
        return ;    //如果网络不通直接结束方法
    }
    //
    //2. 如果线程创建方式不存在
    if ( constructBlock == nil ) {
        DPrintf("ERROR>>Queue: constructBlock can not be nil!\n");
        if ( completion ) completion([LEService errorWithLEServiceErrorType:LERequestErrorCouldNotInit localizedDescriptionValue:nil]);
        return ;
    }
    //
    //3. 开始构造请求组
    NSArray * constructedList = constructBlock();
    //3.1 重新组合数据
    NSMutableDictionary * requestPair = [NSMutableDictionary dictionaryWithCapacity:constructedList.count];
    //3.2 如果里面的对象有一个是NSNull就要停止
    __block BOOL checked = YES;
    [constructedList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [obj isKindOfClass:NSNull.class] ) {
            checked = NO;
            *stop = YES;
        } else {
            [requestPair setValuesForKeysWithDictionary:obj];
        }
    }];
    //3.2 如果检查失败
    if ( !checked || !constructedList || constructedList.count == 0 ) {
        DPrintf("ERROR>>Queue: 网络请求组构建失败,有请求初始化失败返回了[NSNull null]对象或没有数据请求组!\n");
        completion([LEService errorWithLEServiceErrorType:LEServiceErrorNotConnected localizedDescriptionValue:nil]);
        return ;
    }

    //4. 可以执行请求了
    [[LEDataTaskManager sharedManager] queue:requestPair complete:completion];

}

+ (id) requestPairWithURLKey : (NSString *) urlKey requestMethod : (NSString *) requestMethod parameters : (NSDictionary *) parameters success : (void(^)(id record)) successBlock failure : (void(^)(LEServiceError type, NSError * error)) failureBlock {
    //1.参数重设
    parameters = [self requestParamsAnalysis:parameters];
    //
    //2.找API接口
    NSString * apiName = [self checkAPIKey:urlKey withFailureBlock:failureBlock];
    if ( apiName == nil ) {
        Debug(@">> 网络请求组构建失败:API<%@>Method<%@> 无法找到apiName", urlKey, requestMethod);
        return [NSNull null];    //如果未找到接口名字，直接结束方法
    }
    //地址传参形式的兼容
    apiName = [self replaceUrlParams:apiName parameters:parameters];
    //
    //3.构造requestURL
    NSMutableURLRequest * request = [self requestWithApi:apiName parameters:parameters method:requestMethod failure:failureBlock];
    if ( !request ) {
        Debug(@">> 网络请求组构建失败:API<%@>Method<%@> 无法构建URLRequest对象", urlKey, requestMethod);
        return [NSNull null];
    }
    //
    //4.构造回调
    void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = ^(NSData * data, NSURLResponse * response, NSError * error) {
        if ( error ) {
            Debug(@">> 请求失败：%@", error);
            error = [self errorFilter:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( failureBlock ) failureBlock(LEServiceErrorRequestError, error);
            });
        } else {
            [self analysisResponseObject:data request:request  completion:successBlock failure:failureBlock];
        }
    };
    //
    //返回数据
    if ( request && completionBlock ) {
        return @{request : completionBlock};
    }
    return [NSNull null];
}
/**
 * 非客户端api，第三方api请求｜注意：不会解析操作
 */
+ (void) requestWithAbsoluteUrlKey : (NSString *) absoluteUrlString
                     requestMethod : (NSString *) requestMethod
                  headerParameters : (NSDictionary *) headerParameters
                        parameters : (NSDictionary *) parameters
                           success : (void(^)(id responseObject)) successBlock
                           failure : (void(^)(NSError * error)) failureBlock {
    //1.检查网络状态
    if ( ![[self sharedInstance] isNetworkConnected] ) {
        DPrintf("ERROR>>Queue: Network not in connected !\n");
        return ;    //如果网络不通直接结束方法
    }
    //2.构造Manager
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone]];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;    //关闭域名验证
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    if ( ![self isRequestSerializerJSON] ) {
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [self openRequestSerializerJson];
    }
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    //3.构造URLRequest
    NSError * error = nil;
    NSMutableURLRequest * request = [manager.requestSerializer requestWithMethod : requestMethod
                                                                       URLString : absoluteUrlString
                                                                      parameters : parameters
                                                                           error : &error];
    if ( error && failureBlock ) {
        failureBlock(error);
        return ;
    }
    if ( headerParameters ) {
        [headerParameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ( [request.allHTTPHeaderFields.allKeys containsObject:key] ) {
                [request setValue:obj forHTTPHeaderField:key];
            } else {
                [request addValue:obj forHTTPHeaderField:key];
            }
        }];
    }
    //4.开始请求
    [[LEDataTaskManager sharedManager] appendSessionDataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ( error ) {
            Debug(@">> 请求失败：%@", error);
            error = [self errorFilter:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( failureBlock ) failureBlock(error);
            });
        } else if ( successBlock ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(data);
            });
        }
    }];
}

/**
 *  登出操作，停止所有请求
 */
+ (void) logoutAction {
    [[[[self sharedInstance] sslManager] operationQueue] cancelAllOperations];
}

/** 网络状态是否正常 */
+ (BOOL) isNetworkAvaliable {
    return [[self sharedInstance] isNetworkConnected];
}

#pragma mark - 读取配置内容部分
/**
 *  主机地址
 */
+ (NSString *) apiHost {
    return [[[self sharedInstance] configurate] sslUrlPrefix];
}

/**
 *  图片地址
 */
+ (NSString *) imageHost {
    return [[[self sharedInstance] configurate] imageUrlPrefix];
}
+ (void) setApiHost:(NSString*)newUrl
{
    LEService *server =[LEService sharedInstance];
    if (newUrl && newUrl.length>1) {
        [server.configurate setSslUrlPrefix:newUrl];
        [server.configurate setImageUrlPrefix:newUrl];
    }
    [server setNetworkParams];
}
/**
 *  当前网络环境字符串
 */
+ (NSString *) currentReachabilityString {
    switch ( [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] ) {
        case AFNetworkReachabilityStatusUnknown:
            return NSLocalizedString(@"Unknow", @"");
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return NSLocalizedString(@"No Connection", @"");
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedString(@"Cellular", @"");
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedString(@"WiFi", @"");
            break;
    }
}

+ (NSInteger) currentReachabilityCode {
    return [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
}

@end

UIKIT_EXTERN id LEConvertDataToDictionary(id data) {
    if ( [data isKindOfClass:[NSData class]] ) {
        @try {
            data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        } @catch (NSException *exception) {
            //
        } @finally {
            //
        }
    }
    return data;
}

UIKIT_EXTERN id LERequestPair(NSString * urlKey,
                              NSString * method,
                              NSDictionary * params,
                              void(^success)(id record),
                              void(^failure)(LEServiceError type, NSError * error)) {
    return [LEService requestPairWithURLKey:urlKey requestMethod:method parameters:params success:success failure:failure];
}

UIKIT_EXTERN void LEQueueRequest(NSArray * (^constructBlock)(void),
                                 void (^completion)(NSError * error)) {
    [LEService queue:constructBlock completeBlock:completion];
}
