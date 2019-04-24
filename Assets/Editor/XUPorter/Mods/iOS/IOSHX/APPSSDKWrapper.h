//
//  PPSDKWrapper.h
//  Unity-iPhone
//
//  Created by haoxin on 15/6/1.
//
//


#import <Foundation/Foundation.h>
#import "SLEOED/SLESDK.h"
#import "SLEOED/SLESDKAppStore.h"
#import "UnityAppController.h"
#import "SLEOED/SLEUtil.h"

@interface APPSSDKWrapper : NSObject<SLEDelegate,SLESDKDelegate,UIWebViewDelegate>



@property(nonatomic,assign) int amount;//价格

@property(nonatomic,  copy) NSString *price;//价格
@property(nonatomic,  copy) NSString *openuid;//第三方登录成功返回的ID
@property(nonatomic,  copy) NSString *order;//订单号
@property(nonatomic,  copy) NSString *prouductId;//苹果的商品ID
@property(nonatomic,  copy) NSString *Content;

@end
