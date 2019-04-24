//
//  PPSDKWrapper.h
//  Unity-iPhone
//
//  Created by haoxin on 15/6/1.
//
//


#import <Foundation/Foundation.h>
#import "HXSDK.h"
#import "UnityAppController.h"

@interface APPSSDKWrapper : NSObject<HXSDKDelegate>//<iAppPayOpenIdDelegate>

@property(nonatomic,  copy) NSString *Aibeiappid;
@property(nonatomic,  copy) NSString *Aibeisiyao;
@property(nonatomic,  copy) NSString *Aibeigongyao;

@property(nonatomic,  copy) NSString *abProuductId;//爱贝商品ID
@property(nonatomic,  copy) NSString *abNotityurl;//爱贝回调地址

@property(nonatomic,assign) int price;//价格
@property(nonatomic,  copy) NSString *openuid;//第三方登录成功返回的ID
@property(nonatomic,  copy) NSString *order;//订单号
@property(nonatomic,  copy) NSString *prouductId;//苹果的商品ID


@end
