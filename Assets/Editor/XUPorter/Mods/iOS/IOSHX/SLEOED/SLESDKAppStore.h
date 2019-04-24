#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SLENSQueue.h"

@protocol SLESDKDelegate

// 登录回调
// resultCode：返回码0为成功 resultDesc：描述 userData：用户数据
- (void)SLEonAsk:(int)resultCode;

@end

@interface SLESDKAppStore : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic,retain)NSString* urlStr;
@property (nonatomic,retain)SLENSQueue* receiptQueue;
@property (nonatomic,retain)NSArray *products;
@property (nonatomic,assign)float price;
@property (nonatomic,assign) id <SLESDKDelegate>delegate;

+ (instancetype)sharedInstance;
- (void)checkUnchekReceipt;
- (void)SLE_AskRequest:(NSString *)productIdentifier order:(NSString*)order;
- (void)addAppStoreObserver;
- (void)initAppstore:(NSString *)bundleId selNotifyUrl:(NSString *)selNotifyUrl delegate:(id<SLESDKDelegate>)delegate;
- (void)SLE_aCheckForRec;
@end
