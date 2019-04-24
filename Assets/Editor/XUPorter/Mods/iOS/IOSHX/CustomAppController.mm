//
//  AppDelegate.m
//  IOSDemo
//
//  Created by 雪鲤鱼 on 15/6/29.
//  Copyright (c) 2015年 yijie. All rights reserved.
//

#import "CustomAppController.h"


@interface CustomAppController ()

@end

IMPL_APP_CONTROLLER_SUBCLASS (CustomAppController)

@implementation CustomAppController

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation NS_AVAILABLE_IOS(4_2){
    
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [super applicationDidEnterBackground : application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
   [super applicationWillEnterForeground : application];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [super application: application didFinishLaunchingWithOptions : launchOptions];
    return YES;

}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
 
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return   (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
    | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return YES;
}

@end
