//
//  IAPManager.m
//  IAPDemo
//
//  Created by Charles.Yao on 2016/10/31.
//  Copyright © 2016年 com.pico. All rights reserved.
//

#import "IAPManager.h"
#import "LESandBoxHelp.h"
#import "NSString+category.h"
#import "NSDate+category.h"

static NSString * const receiptKey = @"receipt_data";
static NSString * const dateKey = @"date_key";
static NSString * const userIdKey = @"userId_key";
static NSString * const locationKey = @"location_key";
static NSString * const bookIdKey = @"bookId_key";
static NSString * const chapterIdKey = @"chapterId_key";
static NSString * const payIdKey = @"payId_key";
static NSString * const friendIdKey = @"friendId_key";

dispatch_queue_t iap_queue()
{
    static dispatch_queue_t as_iap_queue;
    static dispatch_once_t onceToken_iap_queue;
    dispatch_once(&onceToken_iap_queue, ^{
        as_iap_queue = dispatch_queue_create("com.ayiap.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_iap_queue;
}

@interface IAPManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
    dispatch_queue_t _server_check_queue;
    dispatch_semaphore_t _server_check_semaphore;
}
@property (nonatomic, assign) BOOL goodsRequestFinished; //判断一次请求是否完成
@property (nonatomic, copy) NSString *receipt; //交易成功后拿到的一个64编码字符串
@property (nonatomic, copy) NSString *date; //交易时间

@property (nonatomic, copy) NSString *payId; //订单号

@property (nonatomic, copy) NSString *userId; //交易人
@property (nonatomic, copy) NSString *produceId; //内购产品id

@end

@implementation IAPManager

singleton_implementation(IAPManager)
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.goodsRequestFinished = YES;
        _server_check_queue = dispatch_queue_create("com.servercheck.queue", DISPATCH_QUEUE_CONCURRENT);
        _server_check_semaphore = dispatch_semaphore_create(1);
    }
    return self;
}
- (void)startManager { //开启监听

    dispatch_async(iap_queue(), ^{
        self.goodsRequestFinished = YES;
        /***
         内购支付两个阶段：
         1.app直接向苹果服务器请求商品，支付阶段；
         2.苹果服务器返回凭证，app向公司服务器发送验证，公司再向苹果服务器验证阶段；
         */
        /**
         阶段一正在进中,app退出。
         在程序启动时，设置监听，监听是否有未完成订单，有的话恢复订单。
         */
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        /**
         阶段二正在进行中,app退出。
         在程序启动时，检测本地是否有receipt文件，有的话，去二次验证。
         */
        [self checkIAPFiles:nil failure:nil];
    });
}

- (void)stopManager
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    });
}

#pragma mark 查询
- (void)requestProductWithId:(NSString *)productId
{
    _produceId = productId;
    if (self.goodsRequestFinished)
    {
        if ([SKPaymentQueue canMakePayments])
        { //用户允许app内购
            if (productId.length)
            {
                [self producePayIdFromServer:productId success:^{
                    AYLog(@"%@商品正在请求中",productId);
                    self.goodsRequestFinished = NO; //正在请求
                    NSArray *product = [[NSArray alloc] initWithObjects:productId, nil];
                    NSSet *set = [NSSet setWithArray:product];
                    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
                    productRequest.delegate = self;
                    [productRequest start];
                }
                failure:^(NSString *errorString)
                {
                    occasionalHint(AYLocalizedString(@"订单号生成失败"));
                }];
            }
            else
            {
                AYLog(@"商品为空");
                [self filedWithErrorCode:IAP_FILEDCOED_EMPTYGOODS error:nil];
                self.goodsRequestFinished = YES; //完成请求
            }
        }
        else
        {
            AYLog(@"没有权限购买");
            //没有权限
            [self filedWithErrorCode:IAP_FILEDCOED_NORIGHT error:nil];
            self.goodsRequestFinished = YES; //完成请求
        }
    }
    else
    {
        AYLog(@"上次请求还未完成，请稍等");
    }
}

#pragma mark SKProductsRequestDelegate 查询成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *product = response.products;
    if (product.count == 0) {
        AYLog(@"无法获取商品信息，请重试");
        [self filedWithErrorCode:IAP_FILEDCOED_CANNOTGETINFORMATION error:nil];
        self.goodsRequestFinished = YES; //失败，请求完成
    } else {
        //发起购买请求
        SKPayment *payment = [SKPayment paymentWithProduct:product[0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}
#pragma mark SKProductsRequestDelegate 查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [self filedWithErrorCode:IAP_FILEDCOED_APPLECODE error:[error localizedDescription]];
    self.goodsRequestFinished = YES; //失败，请求完成
}

#pragma Mark 购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions
{

    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing://正在交易
                AYLog(@"正在交易");
                break;
            case SKPaymentTransactionStatePurchased://交易完成
            {
                AYLog(@"交易完成");
                [self getReceipt]; //获取交易成功后的购买凭证
                [self saveReceipt]; //存储交易凭证
                [self checkIAPFiles:^{
                    [self completeTransaction:transaction];
                } failure:^(NSString *errorString) {
                    //服务器验证失败
                    [self serverCheckFailedTransaction:transaction];
                }];
            }
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    self.goodsRequestFinished = YES; //成功，请求完成
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self removeHelpFriendChargeInfo];
    if (self.delegate &&  [self.delegate respondsToSelector:@selector(paySuccess:)]) {
        [self.delegate paySuccess:self.payId];
    }
}
- (void)failedTransaction:(SKPaymentTransaction *)transaction {

    if (transaction) {
        AYLog(@"transaction.error.code = %ld", transaction.error.code);
        
        if(transaction.error.code != SKErrorPaymentCancelled) {
            
        }
        else
        {
            
            [self filedWithErrorCode:IAP_FILEDCOED_USERCANCEL error:nil];
        }
    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
   
    self.goodsRequestFinished = YES; //失败，请求完成
}
- (void)serverCheckFailedTransaction:(SKPaymentTransaction *)transaction
{
    [self filedWithErrorCode:IAP_FILEDCOED_SERVERCHEKFAILD error:nil];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    self.goodsRequestFinished = YES; //失败，请求完成
}
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    self.goodsRequestFinished = YES; //恢复购买，请求完成

}

#pragma mark 获取交易成功后的购买凭证

- (void)getReceipt
{
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    self.receipt = [receiptData base64EncodedStringWithOptions:0];
}

#pragma mark  持久化存储用户购买凭证(这里最好还要存储当前日期，用户id等信息，用于区分不同的凭证)
-(void)saveReceipt
{
    self.date = [NSDate chindDateFormate:[NSDate date]];
    NSString *fileName = [NSString uuid];
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@.plist", [LESandBoxHelp iapReceiptPath], fileName];
    
    //获取充值信息
    AYChargeLocationType chargeLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookType] intValue];
    int   bookId = 0;
    int   chapterId = 0;
    switch (chargeLocation) {
        case AYChargeLocationTypeCartoonChapter:
        case AYChargeLocationTypeFictionChapter:

        {
            bookId = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookId] intValue];
            chapterId  = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeSectionId] intValue];
        }
            break;
        case AYChargeLocationTypeCartoonReward:
        case AYChargeLocationTypeFictionReward:
            
        {
            bookId = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookId] intValue];
        }
            break;
            
        default:
            break;
    }
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                        self.receipt,receiptKey,
                        self.date, dateKey,@(chargeLocation), locationKey,@(bookId), bookIdKey,@(chapterId), chapterIdKey,self.payId, payIdKey,nil];
   NSNumber *friendId =  [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFriendChargeId];
    if (friendId) {
        [dic setObject:friendId forKey:friendIdKey];
    }
       AYLog(@"%@",savedPath);
    [dic writeToFile:savedPath atomically:YES];
}

#pragma mark 将存储到本地的IAP文件发送给服务端 验证receipt失败,App启动后再次验证
- (void)checkIAPFiles: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //搜索该目录下的所有文件和目录
    NSArray *cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:[LESandBoxHelp iapReceiptPath] error:&error];
    if (error == nil)
    {
        for (NSString *name in cacheFileNameArray)
        {
            if ([name hasSuffix:@".plist"])
            {
                //如果有plist后缀的文件，说明就是存储的购买凭证
                dispatch_async( _server_check_queue, ^{
                dispatch_semaphore_wait(self->_server_check_semaphore, DISPATCH_TIME_FOREVER);
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [LESandBoxHelp iapReceiptPath], name];
                    [self sendAppStoreRequestBuyPlist:filePath success:^{
                            dispatch_semaphore_signal(self->_server_check_semaphore);
                        [self removeReceipt:filePath];
                        if (completeBlock) {
                            completeBlock();
                        }
                    } failure:^(NSString *errorString) {
                        dispatch_semaphore_signal(self->_server_check_semaphore);
                        if (failureBlock) {
                            failureBlock([error localizedDescription]);
                        }
                    } ];
                });
  
            }

        }
    }
    else
    {
        if (failureBlock) {
            failureBlock([error localizedDescription]);
        }
        AYLog(@"AppStoreInfoLocalFilePath error:%@", [error domain]);
    }
}
//验证成功就从plist中移除凭证
-(void)removeReceipt:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}
-(void)removeHelpFriendChargeInfo
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFriendChargeId]) {
        //清除帮好友充值id 标记
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultFriendChargeId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - network -

-(void)sendAppStoreRequestBuyPlist:(NSString *)plistPath  success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    //这里的参数请根据自己公司后台服务器接口定制，但是必须发送的是持久化保存购买凭证
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [dic objectForKey:receiptKey],          receiptKey,
                                    [dic objectForKey:locationKey],          @"type",
                                    [dic objectForKey:bookIdKey],          @"book_id",
                                    [dic objectForKey:chapterIdKey],          @"section_id",
                                    [dic objectForKey:payIdKey],          @"order_num",
                                   nil];

    if (dic[friendIdKey]) {
        [params setObject:dic[friendIdKey] forKey:@"agent_id"];
    }
    self.payId =[dic objectForKey:payIdKey];
    //给服务器去验证
    [ZWNetwork post:dic[friendIdKey]?@"HTTP_Post_Friend_Charge":@"HTTP_Pay_Indentify" parameters:params success:^(id record)
     {
        // 同步本地余额
        NSString *myMoney = [record[@"remainder"] stringValue];
        if (myMoney)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserChargeSectionId];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserChargeBookId];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserChargeBookType];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [AYUserManager userItem].coinNum = myMoney;
                    [AYUserManager save];
        }
         if (completeBlock)
         {
             completeBlock();
         }
     }
     failure:^(LEServiceError type, NSError *error)
     {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}
//服务器生成订单号
-(void)producePayIdFromServer:(NSString *)productId success : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    //获取充值信息
    AYChargeLocationType chargeLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookType] intValue];
    int   bookId = 0;
    int   chapterId = 0;
    switch (chargeLocation) {
        case AYChargeLocationTypeCartoonChapter:
        case AYChargeLocationTypeFictionChapter:
            
        {
            bookId = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookId] intValue];
            chapterId  = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeSectionId] intValue];
        }
            break;
        case AYChargeLocationTypeCartoonReward:
        case AYChargeLocationTypeFictionReward:
            
        {
            bookId = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookId] intValue];
        }
            break;
            
        default:
            break;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:productId,@"applepayId",
                                   @(chargeLocation),@"type",
                                   @(bookId),@"book_id",
                                   @(chapterId),@"section_id",
                                   @(5),@"pay_type",
                                   nil];
    NSNumber *friendId =  [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFriendChargeId];
    if (friendId) {
        [params setObject:friendId forKey:@"agent_id"];
    }
    //给服务器去验证
    [ZWNetwork post:@"HTTP_Post_Product_PayId" parameters:params success:^(id record)
     {
         if ([record isKindOfClass:NSDictionary.class])
         {
             NSString *payId = record[@"order_num"];
             if (payId && payId.length>0)
             {
                 self.payId = payId;
                 if (completeBlock)
                 {
                     completeBlock();
                 }
             }
             else
             {
                 if (failureBlock)
                 {
                     failureBlock(@"error");
                 }
             }
         }
         else
         {
             if (failureBlock) {
                 failureBlock(@"error");
             }
         }
     }
     failure:^(LEServiceError type, NSError *error)
     {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}

//服务器生成订单号
-(void)sendPayFailFromServerWithStatus:(NSInteger)failType
{
    //获取充值信息
    AYChargeLocationType chargeLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookType] intValue];
    int   bookId = 0;
    int   chapterId = 0;
    switch (chargeLocation) {
        case AYChargeLocationTypeCartoonChapter:
        case AYChargeLocationTypeFictionChapter:
            
        {
            bookId = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookId] intValue];
            chapterId  = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeSectionId] intValue];
        }
            break;
        case AYChargeLocationTypeCartoonReward:
        case AYChargeLocationTypeFictionReward:
            
        {
            bookId = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserChargeBookId] intValue];
        }
            break;
            
        default:
            break;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.produceId,@"applepayId",
                                   @(chargeLocation),@"type",
                                   @(bookId),@"book_id",
                                   @(chapterId),@"section_id",
                                   self.payId,@"order_num",
                                   @(failType),@"pay_status",
                                   nil];
    //给服务器去验证
    [ZWNetwork post:@"HTTP_Post_Pay_Faild " parameters:params success:^(id record)
     {
         
     }
     failure:^(LEServiceError type, NSError *error)
     {
     
     }];
}
#pragma mark 错误信息反馈
- (void)filedWithErrorCode:(NSInteger)code error:(NSString *)error
{
    if (code == IAP_FILEDCOED_USERCANCEL  )
    {
        [self sendPayFailFromServerWithStatus:2];
    }
    else if(code !=IAP_FILEDCOED_SERVERCHEKFAILD)
    {
        [self sendPayFailFromServerWithStatus:3];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(filedWithErrorCode:andError:)]) {
        switch (code) {
            case IAP_FILEDCOED_APPLECODE:
                [self.delegate filedWithErrorCode:IAP_FILEDCOED_APPLECODE andError:error];
                break;

                case IAP_FILEDCOED_NORIGHT:
                [self.delegate filedWithErrorCode:IAP_FILEDCOED_NORIGHT andError:nil];
                break;

            case IAP_FILEDCOED_EMPTYGOODS:
                [self.delegate filedWithErrorCode:IAP_FILEDCOED_EMPTYGOODS andError:nil];
                break;

            case IAP_FILEDCOED_CANNOTGETINFORMATION:
                 [self.delegate filedWithErrorCode:IAP_FILEDCOED_CANNOTGETINFORMATION andError:nil];
                break;

            case IAP_FILEDCOED_BUYFILED:
                 [self.delegate filedWithErrorCode:IAP_FILEDCOED_BUYFILED andError:nil];
                break;

            case IAP_FILEDCOED_USERCANCEL:
                 [self.delegate filedWithErrorCode:IAP_FILEDCOED_USERCANCEL andError:nil];
                break;
            case IAP_FILEDCOED_SERVERCHEKFAILD:
                [self.delegate filedWithErrorCode:IAP_FILEDCOED_SERVERCHEKFAILD andError:nil];
                break;
            default:
                break;
        }
    }
    else{
        [self removeHelpFriendChargeInfo];
    }
}

@end
