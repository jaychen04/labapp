//
//  AppDelegate.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-13.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "AppDelegate.h"
#import "OSCThread.h"
#import "Config.h"
#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "OSCTabBarController.h"
#import "SideMenuViewController.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

#import <RESideMenu/RESideMenu.h>


@interface AppDelegate () <UIApplicationDelegate, UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    OSCTabBarController *tabBarController = [OSCTabBarController new];
    tabBarController.delegate = self;
    
    RESideMenu *sideMenuTabBarViewController = [[RESideMenu alloc] initWithContentViewController:tabBarController
                                                                          leftMenuViewController:[SideMenuViewController new]
                                                                         rightMenuViewController:nil];
    sideMenuTabBarViewController.scaleContentView = NO;
    sideMenuTabBarViewController.contentViewScaleValue = 0.95;
    sideMenuTabBarViewController.scaleMenuView = NO;
    sideMenuTabBarViewController.contentViewShadowEnabled = YES;
    sideMenuTabBarViewController.contentViewShadowRadius = 4.5;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = sideMenuTabBarViewController;
    [self.window makeKeyAndVisible];
    
    
    /************ 控件外观设置 **************/
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHex:0x15A230]];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:0x15A230]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHex:0xE1E1E1]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x15A230]} forState:UIControlStateSelected];
    
    
    [UISearchBar appearance].tintColor = [UIColor colorWithHex:0x15A230];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setCornerRadius:14.0];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAlpha:0.6];
    
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xDCDCDC];
    pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    
    
    /************ 检测通知 **************/
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    /*if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
    }*/
    if ([Config getOwnID] != 0) {[OSCThread startPollingNotice];}
    
    
    /************ 友盟分享组件 **************/
    
    [UMSocialData setAppKey:@"54c9a412fd98c5779c000752"];
    [UMSocialWechatHandler setWXAppId:@"wx41be5fe48092e94c" appSecret:@"0101b0595ffe2042c214420fac358abc" url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setQQWithAppId:@"100942993" appKey:@"8edd3cc7ca8dcc15082d6fe75969601b" url:@"http://www.umeng.com/social"];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}



@end
