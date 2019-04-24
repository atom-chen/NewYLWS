#import <Foundation/Foundation.h>

@interface SLEUser : NSObject<NSCoding>

@property(atomic, retain, readwrite) NSString *account;
@property(atomic, retain, readwrite) NSString *password;
@property(atomic, readwrite) BOOL isLogin;

+ (SLEUser *)getCurrentUserWithAccount:(NSString *)account;

@end


