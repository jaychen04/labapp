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
#import "Utils.h"

@interface OSCTabBarController ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL isPressed;

@end

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
    
    [self addCenterButtonWithImage:nil andHighlightImage:nil];
    
    [self.tabBar addObserver:self
                  forKeyPath:@"selectedItem"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
}


-(void)addCenterButtonWithImage:(UIImage *)buttonImage andHighlightImage:(UIImage *)highlightImage
{
    _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGPoint origin = [self.view convertPoint:self.tabBar.center toView:self.tabBar];
    CGSize buttonSize = CGSizeMake(self.tabBar.frame.size.width / 5 - 6, self.tabBar.frame.size.height - 4);
    _centerButton.frame = CGRectMake(origin.x - buttonSize.width/2, origin.y - buttonSize.height/2, buttonSize.width, buttonSize.height);
    [_centerButton setBackgroundColor:[UIColor orangeColor]];
    [_centerButton setCornerRadius:5.0];
    
    [_centerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_centerButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    [_centerButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:_centerButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedItem"]) {
        if(self.isPressed) {[self buttonPressed];}
    }
}


- (void)buttonPressed
{
    [self changeTheButtonStateAnimatedToOpen:_isPressed];
    
    _isPressed = !_isPressed;
}


- (void)changeTheButtonStateAnimatedToOpen:(BOOL)isPressed
{
    if(isPressed) {
        [self removeBackgroundView];
    } else {
        [self addBackgroundView];
    }
}

- (void)addBackgroundView
{
    _centerButton.enabled = NO;
    _bgView = [[UIView alloc] initWithFrame:self.tabBar.superview.bounds];
    _bgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                               UIViewAutoresizingFlexibleHeight     | UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin;
    [_bgView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
    [_bgView addGestureRecognizer:tap];
    
    [self.view insertSubview:_bgView belowSubview:self.tabBar];
    [UIView animateWithDuration:0.3
                     animations:^{_bgView.alpha = 0.7;}
                     completion:^(BOOL finished) {
                         if (finished) {_centerButton.enabled = YES;}
                     }];
}


- (void)removeBackgroundView
{
    _centerButton.enabled = NO;
    [UIView animateWithDuration:0.3
                     animations:^{self.bgView.alpha = 0.0;}
                     completion:^(BOOL finished) {
                         if(finished) {
                             [self.bgView removeFromSuperview];
                             self.bgView = nil;
                             _centerButton.enabled = YES;
                         }
                     }];
}


@end
