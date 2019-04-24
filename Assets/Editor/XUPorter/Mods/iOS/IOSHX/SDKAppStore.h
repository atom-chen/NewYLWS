#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "NSQueue.h"

@interface SDKAppStore : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property (nonatomic,retain)NSString* urlStr;
@property (nonatomic,retain)NSQueue* receiptQueue;
@property (nonatomic,retain)NSArray *products;

+ (instancetype)sharedInstance;
- (void)checkUnchekReceipt;
- (void)buyRequest:(NSString *)productIdentifier order:(NSString*)order;
- (void)addAppStoreObserver;
- (void)initAppstore:(NSString *)bundleId payNotifyUrl:(NSString *)payNotifyUrl;
@end