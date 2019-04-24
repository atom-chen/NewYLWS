//
//  PPSDKWrapper.m
//  Unity-iPhone
//
//  Created by haoxin on 15/6/1.
//
//
#import "APPSSDKWrapper.h"

//#ifdef DEBUG
//#define DLog(...)NSLOG(__VA_ARGS__)
//#else
//#define NSLog(...) {}
//#endif


@implementation APPSSDKWrapper
+ (instancetype)sharedInstance {
    static APPSSDKWrapper* instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[APPSSDKWrapper alloc] init];
    });
    return instance;
}



- (void)HxAppInitWithAPPID:(NSString *)appid Hxappkey:(NSString *)appkey
{

    [SLESDK initSdk:appid appKey:appkey delegate:self];//XXSG
    UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"InitSDKComplete\",\"packageName\":\"IOSHX\"}");
}
-(void)SLEonAsk:(int)resultCode
{
    if (resultCode == 0) {//0到账
        UnitySendMessage("PlatformListener", "PayCallback", "ret=0");
    }else{
        UnitySendMessage("PlatformListener", "PayCallback", "ret=-1");
    }
}
-(void)HxCheckWithBundleId:(NSString *)bundleId HxInAppPurchaseNotifUrl:(NSString *)InAppPurchaseNotifyUrl{
    [[SLESDKAppStore sharedInstance] initAppstore:@"com.tsuki.field" selNotifyUrl:InAppPurchaseNotifyUrl delegate:self];
    [[SLESDKAppStore sharedInstance] SLE_aCheckForRec];
    UnitySendMessage("PlatformListener", "CheckCallback", "");
}

- (void)HxLogin
{

    [SLESDK login];
}

- (void)HxInAppPurchaseWithPayway:(NSString *)InAppPurchaseWayway HxProuductId:(NSString *)appProuductId Hxprice:(NSString *)productPrice Hxorder:(NSString *)order HxContent:(NSString *)Content Hxjt:(NSString *)urlStr
{
    self.order = order;
    self.price = productPrice;
    self.Content=Content;
    self.prouductId = [self HxprouductIdWithStr:appProuductId];
    
    NSLog(@"order == %@,appProuductId == %@,InAppPurchaseWayway==%@",order,self.prouductId,InAppPurchaseWayway);
    
    [[SLESDKAppStore sharedInstance] SLE_AskRequest:self.prouductId order:self.order];
}
-(NSString *)HxprouductIdWithStr:(NSString *)prouductId
{
    if ([prouductId hasPrefix:@"com.lqzt.field."]) {
        prouductId = [prouductId stringByReplacingOccurrencesOfString:@"com.lqzt.field." withString:@"com.tsuki.field."];
    }
    return prouductId;
}

#pragma mark-- 充值回调 XYPayDelegate

- (void)onLogin:(int)resultCode resultDesc:(NSString *)resultDesc userData:(SLEUserData *)userData
{
    NSString* token = userData.sessionId;       // token
    self.openuid = userData.userId;   // uid
    UnitySendMessage("SDKHelper", "SDKCallLua", [[NSString stringWithFormat:@"{\"methodName\":\"LoginCallback\",\"platform_id\":\"%@\",\"token\":\"%@\"}", self.openuid, token] UTF8String]);
}
- (void)HxonLogout
{
}


@end


#if defined(__cplusplus)
extern "C"{
#endif
    void LuaCallIOS(const char *msg)
    {
        NSString *jsonContent = [NSString stringWithUTF8String:msg];
        NSData * data = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *methodName = [dict objectForKey:@"methodName"];
        if ([methodName isEqualToString:@"HXInit"])
        {
            [[APPSSDKWrapper sharedInstance] HxAppInitWithAPPID:[NSString stringWithUTF8String:"512991"] Hxappkey:[NSString stringWithUTF8String:"MQ2NSKPGMNAP7JZZIUMARSGXCW9IMRQA"]];
        }
        else if ([methodName isEqualToString:@"HXLogin"])
        {
            [[APPSSDKWrapper sharedInstance] HxLogin];
        }
        else if ([methodName isEqualToString:@"HXSwitchAccount"])
        {
            UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"LogoutCallback\"}");
        }
        else if ([methodName isEqualToString:@"HXPay"])
        {
            //                NSString *channelUserId = [dict objectForKey:@"channelUserId"];
            //                double moneyAmount = [[dict objectForKey:@"moneyAmount"] doubleValue];
            //                NSString *productName = [dict objectForKey:@"productName"];
            //                NSString *productId = [dict objectForKey:@"productId"];
            //                NSString *exchangeRate = [dict objectForKey:@"exchangeRate"];
            //                NSString *notifyUri = [dict objectForKey:@"notifyUri"];
            //                NSString *appName = [dict objectForKey:@"appName"];
            //                NSString *appUserName = [dict objectForKey:@"appUserName"];
            //                NSString *appUserId = [dict objectForKey:@"appUserId"];
            //                NSString *appUserLevel = [dict objectForKey:@"appUserLevel"];
            //                NSString *appOrderId = [dict objectForKey:@"appOrderId"];
            //                NSString *serverId = [dict objectForKey:@"serverId"];
            //                NSString *payExt1 = [dict objectForKey:@"payExt1"];
            //                NSString *payExt2 = [dict objectForKey:@"payExt2"];
            //                NSString *submitTime = [dict objectForKey:@"submitTime"];
            
            //                NSLog(@"productPrice--%f",moneyAmount);
            //[[APPSSDKWrapper sharedInstance] HxInAppPurchaseWithPayway:@"APPSTORE" HxProuductId:[NSString stringWithUTF8String:prouductId] Hxprice:[NSString stringWithFormat:@"%.f",moneyAmount] Hxorder:[NSString stringWithUTF8String:InAppPurchaseExt] HxContent:/[NSString stringWithUTF8String:Content] Hxjt:[NSString stringWithUTF8String:sdkUrl]];
        }
        else if ([methodName isEqualToString:@"DownLoadGame"])
        {
            NSString *downloadUrl = [dict objectForKey:@"url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
        }
    }
        
    void APPSInitJTZLWS()
    {
       
    }
    
    void APPSCheck(const char *bundleId,const char *InAppPurchaseNotifyUrl)
    {
        [[APPSSDKWrapper sharedInstance] HxCheckWithBundleId:[NSString stringWithUTF8String:bundleId] HxInAppPurchaseNotifUrl:[NSString stringWithUTF8String:InAppPurchaseNotifyUrl]];
    }
    
//    void APPSInAppPurchase(const char *str,const int serverId, const char *prouductId,  const double productPrice, const char *InAppPurchaseExt, const char *Content, const char *sdkUrl)
//    {
//        NSLog(@"productPrice--%f",productPrice);
//        [[APPSSDKWrapper sharedInstance] HxInAppPurchaseWithPayway:@"APPSTORE" HxProuductId:[NSString stringWithUTF8String:prouductId] Hxprice:[NSString stringWithFormat:@"%.f",productPrice] Hxorder:[NSString stringWithUTF8String:InAppPurchaseExt] HxContent:[NSString stringWithUTF8String:Content] Hxjt:[NSString stringWithUTF8String:sdkUrl]];
//    }

#if defined(__cplusplus)
}
#endif

