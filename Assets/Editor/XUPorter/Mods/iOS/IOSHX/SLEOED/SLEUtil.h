#import <Foundation/Foundation.h>
#import "SLESDK.h"
#import "SLEUser.h"

#define DLog(fmt, ...) if (SDK_DEBUG) { NSLog(fmt, ##__VA_ARGS__); }

#define SLEPLISTDATA  [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SHUAI" ofType:@"plist"]]

extern BOOL SDK_DEBUG;

static const NSString *HTTP_DNS = @"https://sdk.haoxingame.com";//httpdns 域名解析
static const NSString *REGISTER_URL = @"https://sdk.haoxingame.com/player/register";//注册
static const NSString *REGONEKEY_URL = @"https://sdk.haoxingame.com/one_key/register";//一键注册
static const NSString *LOGIN_URL = @"https://sdk.haoxingame.com/HxSDK/login";// 登录
static const NSString *MODIFY_URL = @"https://sdk.haoxingame.com/reset/password";//修改密码
static const NSString *MESCODE_URL = @"https://sdk.haoxingame.com/Message/code";//绑定手机获取验证码
static const NSString *BINDPHONE_URL = @"https://sdk.haoxingame.com/bind/phone";//绑定手机
static const NSString *FOGETCODE_URL = @"https://sdk.haoxingame.com/reset/code";//重设密码获取验证码
static const NSString *RESET_URL = @"https://sdk.haoxingame.com/back/password";//重设密码


static const NSString *account_type_tourist = @"320010";
static const NSString *account_type_facebook = @"facebook";
static const NSString *account_type_google = @"google";
static const NSString *account_type_haoxin = @"haoxin";


@interface SLEUtil : NSObject
@property(atomic, copy, readwrite) NSString *appId;
@property(atomic, copy, readwrite) NSString *appKey;

@property(atomic, copy, readwrite) NSString *userId;
@property(atomic, copy, readwrite) NSString *curAccount;
@property(atomic, copy, readwrite) NSString *curPassword;

+ (SLEUtil *)getInstance;
- (void)initSdk:(NSString *)appId appKey:(NSString *)appKey delegate:(id <SLEDelegate>)delegate;
- (void)loginCallback:(int)resultCode resultDesc:(NSString *)resultDesc userData:(SLEUserData *)userData;
- (void)logoutCallback;


+ (NSString *)md5:(NSString *)str; //md5码加密
+ (NSString *)getPhoneUniqueId;  // 设备唯一id
+ (NSString *)checkAccount:(NSString *)account; //检查账号是否合法
+ (NSString *)checkPassword:(NSString *)passwrod; //检查密码是否合法
//+ (NSString *)checkPhoneNum:(NSString *)PhoneNum;
+ (NSString *)checkPhoneCode:(NSString *)PhoneCode;
+ (NSNumber *)getDictNumberValue:(NSDictionary *)dict key:(NSString *)key;//从字典中获取一个数
+ (NSString *)getDictStringValue:(NSDictionary *)dict key:(NSString *)key;//从字典中获取一个NSString


+ (void)updateAccountPassword:(NSString *)account password:(NSString *)password isLogin:(BOOL)isLogin;//更新用户列表
+ (void)deleteSLEUsersWithAccount:(NSString *)account;//删除某个登录的用户
+ (void)deleteALLSLEUsers;//删除所有登录用户
+ (NSMutableArray<SLEUser *> *)getALLSLEUsers;//获取所有登录过的用户
+ (void)saveSLEUsersWithdata:(id)data;//保存登录用户信息


- (NSString *)getSign:(NSString *)firstStr, ...NS_REQUIRES_NIL_TERMINATION;//参数
- (NSString *)getnoSign:(NSString *)firstStr, ...NS_REQUIRES_NIL_TERMINATION;//参数
- (NSArray *)getRegInfo:(NSString *)account password:(NSString *)password;//注册
- (NSArray *)getRegOneKeyInfo;//一键注册
- (NSArray *)getLoginInfo:(NSString *)account password:(NSString *)password;//登录
- (NSArray *)getModifyInfo:(NSString *)account oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;//修改密码
- (NSArray *)getPhoneCodeInfo:(NSString *)account Password:(NSString *)password PhoneNum:(NSString *)phoneNum;//绑定手机获取验证码
- (NSArray *)getBindPhoneInfo:(NSString *)account Password:(NSString *)password PhoneNum:(NSString *)phoneNum PhoneCode:(NSString *)phoneCode;//绑定手机
- (NSArray *)getFogetPhoneCodeInfo:(NSString *)account;//重设密码获取验证码
- (NSArray *)getFogetPhoneInfo:(NSString *)account Password:(NSString *)password PhoneCode:(NSString *)phoneCode;//重设密码

- (void)loginRequest:(NSString *)account password:(NSString *)password;

- (void)openAlert:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other;
- (void)closeAlert;

@end
