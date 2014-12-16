//
//  OSCTabBarController.m
//  iosapp
//
//  Created by chenhaoxiang on 12/15/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCTabBarController.h"
#import "SwipeableViewController.h"
#import "TweetsViewController.h"
#import "PostsViewController.h"
#import "NewsViewController.h"
#import "BlogsViewController.h"
#import "LoginViewController.h"
#import "DiscoverTableVC.h"
#import "MyInfoViewController.h"
#import "Config.h"
#import "TabBarCenterButton.h"

@implementation OSCTabBarController


- (void)viewDidLoad
{
    SwipeableViewController *newsSVC = [[SwipeableViewController alloc] initWithTitle:@"资讯"
                                                                         andSubTitles:@[@"最新资讯", @"本周热点", @"本月热点"]
                                                                       andControllers:@[
                                                                                        [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews],
                                                                                        [[NewsViewController alloc] initWithNewsListType:NewsListTypeAllTypeWeekHottest],
                                                                                        [[NewsViewController alloc] initWithNewsListType:NewsListTypeAllTypeMonthHottest]
                                                                                        ]];
    
    SwipeableViewController *tweetsSVC = [[SwipeableViewController alloc] initWithTitle:@"动弹"
                                                                           andSubTitles:@[@"最新动弹", @"热门动弹", @"我的动弹"]
                                                                         andControllers:@[
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeAllTweets],
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeHotestTweets],
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeOwnTweets]
                                                                                          ]];
    
    DiscoverTableVC *discoverTableVC = [DiscoverTableVC new];
    
    UINavigationController *meNav;
    if ([Config getOwnID] > 0) {
        MyInfoViewController *myInfoVC = [[MyInfoViewController alloc] initWithUserID:[Config getOwnID]];
        meNav = [[UINavigationController alloc] initWithRootViewController:myInfoVC];
    } else {
        LoginViewController *loginVC = [LoginViewController new];
        meNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    }
    
    
    UINavigationController *newsNav = [[UINavigationController alloc] initWithRootViewController:newsSVC];
    UINavigationController *tweetsNav = [[UINavigationController alloc] initWithRootViewController:tweetsSVC];
    UINavigationController *discoverNav = [[UINavigationController alloc] initWithRootViewController:discoverTableVC];
    
    self.tabBar.translucent = NO;
    self.viewControllers = @[newsNav, tweetsNav, [UIViewController new], discoverNav, meNav];
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithHex:0xE1E1E1]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHex:0xE1E1E1]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:0x007F00]} forState:UIControlStateSelected];
    
    NSArray *titles = @[@"资讯", @"动弹", @"", @"发现", @"我"];
    for (NSUInteger i = 0, count = [self.tabBar.items count]; i < count; i++) {
        [self.tabBar.items[i] setTitle:titles[i]];
    }
    [self.tabBar.items[2] setEnabled:NO];
    
    TabBarCenterButton *centerBtn = [[TabBarCenterButton alloc] initWithTabBar:self.tabBar];
}



@end
