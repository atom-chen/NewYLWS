#import <StoreKit/StoreKit.h>
#import "NSQueue.h"
#import "SDKAppStore.h"

@implementation SDKAppStore

#pragma mark - 获取单例
+ (instancetype)sharedInstance {
    static SDKAppStore* instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[SDKAppStore alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self.receiptQueue = [[NSQueue alloc] init];
    return self;
}

-(void) requestProductData:(NSString *)bundleId{
    NSLog(@"requestProductData");
    NSString *productIdentifiers = [NSString stringWithFormat:@"%@.t30g2220\t%@.t5g315\t%@.t50g3880\t%@.t1g60\t%@.t60g8100\t%@.t15g1060\t%@.m1t4g300\t%@.m1t10g680", bundleId, bundleId, bundleId, bundleId, bundleId, bundleId, bundleId, bundleId];
    NSArray *idArray = [productIdentifiers componentsSeparatedByString:@"\t"];
    NSSet *idSet = [NSSet setWithArray:idArray];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:idSet];
    request.delegate = self;
    [request start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"productsRequest");
    self.products = response.products;
    
    for(NSString *invalidProductId in response.invalidProductIdentifiers){
        NSLog(@"Invalid product id:%@",invalidProductId);
    }
    
}

#pragma mark - appstore回调 请求商品信息回调
- (void)buyRequest:(NSString *)productIdentifier order:(NSString*)order{

    SKProduct *myProduct = nil;
    
    for(id item in self.products){
        SKProduct *product = item;
        if (![productIdentifier compare:product.productIdentifier]){
            myProduct = product;
            break;
        }
    }
    
    if (myProduct) {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:myProduct];
        payment.applicationUsername = order;
        //添加付款请求到队列
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        //无法获取商品信息
        NSLog(@"无法获取商品信息");
    }   
}

#pragma mark - appstore回调 付款请求回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction {
    for(SKPaymentTransaction *tran in transaction){

        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                //购买中
                //[self.appStoreDelegate sdkAppStorePaying];
                break;
            case SKPaymentTransactionStateDeferred:
                //购买中 交易被推迟
                //[self.appStoreDelegate sdkAppStorePaying];
                break;
            case SKPaymentTransactionStateFailed:
                //购买监听 交易失败
                [self failedTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchased:
                //购买监听 交易完成
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStateRestored:
                //购买监听 恢复成功
                [self restoreTransaction:tran];
                break;
            default:
                break;
        }
    }
}

#pragma mark - 交易事务处理
// 交易成功
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self checkReceipt:transaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}
// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [self finishTransaction:transaction wasSuccessful:NO];
}
// 交易恢复
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self finishTransaction:transaction wasSuccessful:YES];
}
//结束交易事务
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    //获取订单号，从userdefult
    NSString *orderId = transaction.payment.applicationUsername;
    if (orderId) {
        //删除订单号,从userdeful
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:orderId];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)checkReceipt:(SKPaymentTransaction *)transaction{
    NSData* receipt = [self receiptWithTransaction:transaction];
    //NSString *encodingReceipt = [receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *encodingReceipt = [self encode:(uint8_t *)receipt.bytes length:receipt.length];
    
    NSString *urlParas = [NSString stringWithFormat:@"order=%@&receipt=%@" , transaction.payment.applicationUsername ,encodingReceipt];
    [self connectServer:self.urlStr urlParas:urlParas];
}

-(NSString *)encode:(const uint8_t *)input length:(NSInteger) length{
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length+2)/3)*4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for(NSInteger i=0; i<length; i+=3){
        NSInteger value = 0;
        for (NSInteger j= i; j<(i+3); j++) {
            value<<=8;
            
            if(j<length){
                value |=(0xff & input[j]);
            }
        }
        
        NSInteger index = (i/3)*4;
        output[index + 0] = table[(value>>18) & 0x3f];
        output[index + 1] = table[(value>>12) & 0x3f];
        output[index + 2] = (i+1)<length ? table[(value>>6) & 0x3f] : '=';
        output[index + 3] = (i+2)<length ? table[(value>>0) & 0x3f] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

#pragma mark - 获取票据信息
- (NSData*)receiptWithTransaction:(SKPaymentTransaction*)transaction {
    NSData *receipt = nil;
    /*if ([[NSBundle mainBundle] respondsToSelector:@selector(appStoreReceiptURL)]) {
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        receipt = [NSData dataWithContentsOfURL:receiptUrl];
    } else {
        if ([transaction respondsToSelector:@selector(transactionReceipt)]) {
            //Works in iOS3 - iOS8, deprected since iOS7, actual deprecated (returns nil) since iOS9
            receipt = [transaction transactionReceipt];
        }
    }*/
    receipt = transaction.transactionReceipt;
    return receipt;
}
	
	#pragma mark - 连接服务器
- (void)connectServer:(NSString*)urlStr urlParas:(NSString*)urlParas {
    //向服务器发送验证请求
    
    [self.receiptQueue enqueue:urlParas];
    
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:urlStr];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [urlParas dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSDictionary *content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];//转换数据格式
    NSLog(@"RESPONSE　DATA: %@", content);//打印结果
    
    [self.receiptQueue removeReceiptFromQueue];
    //再请求
    [self checkUnchekReceipt];
    
    NSNumber *code = content[@"code"];
    if (code.intValue == 1) {
        NSLog(@"交易验证成功");
        //先写到这里了，后面用delegate,在APPSSDKWrapper.mm中处理，leijunfeng20160829
        UnitySendMessage("PlatformListener", "PayCallback", "ret=0");
    } else {
        NSLog(@"交易验证失败");
    }
}

//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
}

//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
    //再请求
    [self checkUnchekReceipt];
}

#pragma mark - 验证遗漏的票据
- (void)checkUnchekReceipt {
    NSString *receipt = [self.receiptQueue dequeue];
    if (!receipt)
    {
        return;
    }
    [self connectServerForUncheckReceipt:receipt urlStr:self.urlStr];
}

- (void)connectServerForUncheckReceipt:(NSString*)urlPara urlStr:(NSString*)urlStr {
    //向服务器发送验证请求
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:urlStr];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [urlPara dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

#pragma mark - 添加交易队列观察者
- (void)addAppStoreObserver {
    NSLog(@"addAppStoreObserver");
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)setPayNotifyUrl:(NSString *)payNotifyUrl{
    self.urlStr = payNotifyUrl;
}

#pragma mark - 添加交易队列观察者
- (void)initAppstore:(NSString *)bundleId payNotifyUrl:(NSString *)payNotifyUrl {
    NSLog(@"initAppstore");
    [self setPayNotifyUrl:payNotifyUrl];
    [self addAppStoreObserver];
    [self checkUnchekReceipt];
    [self requestProductData:bundleId];
}
@end
