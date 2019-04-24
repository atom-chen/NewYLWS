#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SLEUserData : NSObject
@property(atomic, retain, readwrite) NSString *userId;
@property(atomic, retain, readwrite) NSString *sessionId;
@property(atomic, retain, readwrite) NSString *account;
@end

@protocol SLEDelegate
// 登录回调
// resultCode：返回码0为成功 resultDesc：描述 userData：用户数据
- (void)onLogin:(int)resultCode resultDesc:(NSString *)resultDesc userData:(SLEUserData *)userData;
- (void)onLogout;// 登出回调
@end


@interface SLESDK : NSObject
+ (void)initSdk:(NSString *)appId appKey:(NSString *)appKey delegate:(id <SLEDelegate>)delegate;// 初始化
+ (void)setDebug:(BOOL)isDebug; // 设置是否调试状态，调试状态会有日志
+ (void)login;// 登录
+ (void)logout;// 登出
@end
