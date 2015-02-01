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
#import "OptionButton.h"
#import "TweetEditingVC.h"
#import "UIView+Util.h"
#import "PersonSearchViewController.h"
#import "ScanViewController.h"
#import "ShakingViewController.h"
#import "SearchViewController.h"

#import <RESideMenu/RESideMenu.h>


@interface OSCTabBarController ()

@property (nonatomic, strong) UIImageView *blurView;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, strong) NSMutableArray *optionButtons;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGGlyph length;

@end

@implementation OSCTabBarController


- (void)viewDidLoad
{
    SwipeableViewController *newsSVC = [[SwipeableViewController alloc] initWithTitle:@"综合"
                                                                         andSubTitles:@[@"资讯", @"热点", @"博客", @"推荐"]
                                                                       andControllers:@[
                                                                                        [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews],
                                                                                        [[NewsViewController alloc]  initWithNewsListType:NewsListTypeAllTypeWeekHottest],
                                                                                        [[BlogsViewController alloc] initWithBlogsType:BlogTypeLatest],
                                                                                        [[BlogsViewController alloc] initWithBlogsType:BlogTypeRecommended]
                                                                                        ]];
    
    SwipeableViewController *tweetsSVC = [[SwipeableViewController alloc] initWithTitle:@"动弹"
                                                                           andSubTitles:@[@"最新动弹", @"热门动弹", @"我的动弹"]
                                                                         andControllers:@[
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeAllTweets],
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeHotestTweets],
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeOwnTweets]
                                                                                          ]];
    
    DiscoverTableVC *discoverTableVC = [DiscoverTableVC new];
    MyInfoViewController *myInfoVC = [[MyInfoViewController alloc] initWithUserID:[Config getOwnID]];
    
    UINavigationController *meNav = [[UINavigationController alloc] initWithRootViewController:myInfoVC];
    
    
    self.tabBar.translucent = NO;
    self.viewControllers = @[
                             [self addNavigationItemForViewController:newsSVC],
                             [self addNavigationItemForViewController:tweetsSVC],
                             [UIViewController new],
                             [self addNavigationItemForViewController:discoverTableVC],
                             meNav
                             ];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:0x15A230]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHex:0xE1E1E1]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:0x15A230]} forState:UIControlStateSelected];
    
    NSArray *titles = @[@"综合", @"动弹", @"", @"发现", @"我"];
    NSArray *images = @[@"tabbar-news", @"tabbar-tweet", @"", @"tabbar-discover", @"tabbar-me"];
    for (NSUInteger i = 0, count = [self.tabBar.items count]; i < count; i++) {
        [self.tabBar.items[i] setTitle:titles[i]];
        [self.tabBar.items[i] setImage:[UIImage imageNamed:images[i]]];
        [self.tabBar.items[i] setSelectedImage:[UIImage imageNamed:[images[i] stringByAppendingString:@"-selected"]]];
    }
    [self.tabBar.items[2] setEnabled:NO];
    
    [self addCenterButtonWithImage:[UIImage imageNamed:@"tabbar-more"]];
    
    [self.tabBar addObserver:self
                  forKeyPath:@"selectedItem"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
    
    // 功能键相关
    _optionButtons = [NSMutableArray new];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth  = [UIScreen mainScreen].bounds.size.width;
    _length = 70;        // 圆形按钮的直径
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    NSArray *buttonTitles = @[@"文字", @"相册", @"拍照", @"摇一摇", @"扫一扫", @"找人"];
    NSArray *buttonImages = @[@"tweetEditing", @"picture", @"shooting", @"sound", @"scan", @"search"];
    int buttonColors[] = {0xe69961, 0x0dac6b, 0x24a0c4, 0xe96360, 0x61b644, 0xf1c50e};
    
    for (int i = 0; i < 6; i++) {
        OptionButton *optionButton = [[OptionButton alloc] initWithTitle:buttonTitles[i]
                                                                   image:[UIImage imageNamed:buttonImages[i]]
                                                                andColor:[UIColor colorWithHex:buttonColors[i]]];
        
        optionButton.frame = CGRectMake((_screenWidth/6 * (i%3*2+1) - (_length+16)/2),
                                        _screenHeight + 150 + i/3*125,
                                        _length + 16,
                                        _length + [UIFont systemFontOfSize:17].lineHeight + 24);
        [optionButton.button setCornerRadius:_length/2];
        
        optionButton.tag = i;
        optionButton.userInteractionEnabled = YES;
        [optionButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOptionButton:)]];
        
        [self.view addSubview:optionButton];
        [_optionButtons addObject:optionButton];
    }
}


-(void)addCenterButtonWithImage:(UIImage *)buttonImage
{
    _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGPoint origin = [self.view convertPoint:self.tabBar.center toView:self.tabBar];
    CGSize buttonSize = CGSizeMake(self.tabBar.frame.size.width / 5 - 6, self.tabBar.frame.size.height - 4);
#if 0
    _centerButton.frame = CGRectMake(origin.x - buttonSize.width/2, origin.y - buttonSize.height/2, buttonSize.width, buttonSize.height);
    [_centerButton setCornerRadius:5.0];
#else
    _centerButton.frame = CGRectMake(origin.x - buttonSize.height/2, origin.y - buttonSize.height/2, buttonSize.height, buttonSize.height);
    [_centerButton setCornerRadius:buttonSize.height/2];
#endif
    [_centerButton setBackgroundColor:[UIColor colorWithHex:0x24a83d]];
    
    [_centerButton setImage:buttonImage forState:UIControlStateNormal];
    
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
    if (isPressed) {
        [self removeBlurView];
        
        [_animator removeAllBehaviors];
        for (int i = 0; i < 6; i++) {
            UIButton *button = _optionButtons[i];
            
            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:button
                                                                         attachedToAnchor:CGPointMake(_screenWidth/6 * (i%3*2+1),
                                                                                                      _screenHeight + 200 + i/3*125)];
            attachment.damping = 0.5;
            attachment.frequency = 4;
            attachment.length = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC * (5 - i)), dispatch_get_main_queue(), ^{
                [_animator addBehavior:attachment];
            });
        }
    } else {
        [self addBlurView];
        
        [_animator removeAllBehaviors];
        for (int i = 0; i < 6; i++) {
            UIButton *button = _optionButtons[i];
            [self.view bringSubviewToFront:button];
            
            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:button
                                                                         attachedToAnchor:CGPointMake(_screenWidth/6 * (i%3*2+1),
                                                                                                      _screenHeight - 250 + i/3*115)];
            attachment.damping = 0.5;
            attachment.frequency = 4;
            attachment.length = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC * i), dispatch_get_main_queue(), ^{
                [_animator addBehavior:attachment];
            });
        }
    }
}

- (void)addBlurView
{
    _centerButton.enabled = NO;
    _blurView = [[UIImageView alloc] initWithImage:[self.view updateBlur]];
    _blurView.userInteractionEnabled = YES;
    [self.view addSubview:_blurView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
    [_blurView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.25f
                     animations:nil
                     completion:^(BOOL finished) {
                         if (finished) {_centerButton.enabled = YES;}
                     }];
}


- (void)removeBlurView
{
    _centerButton.enabled = NO;
    
    [UIView animateWithDuration:0.25f
                     animations:nil
                     completion:^(BOOL finished) {
                         if(finished) {
                             [self.blurView removeFromSuperview];
                             self.blurView = nil;
                             _centerButton.enabled = YES;
                         }
                     }];
}



#pragma mark - 处理点击事件

- (void)onTapOptionButton:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.view.tag) {
        case 0: {
            TweetEditingVC *tweetEditingVC = [TweetEditingVC new];
            UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
            [self.selectedViewController presentViewController:tweetEditingNav animated:YES completion:nil];
            [self buttonPressed];
            break;
        }
        case 1: {break;}
        case 2: {break;}
        case 3: {
            ShakingViewController *shakingVC = [ShakingViewController new];
            UINavigationController *shakingNav = [[UINavigationController alloc] initWithRootViewController:shakingVC];
            [self.selectedViewController presentViewController:shakingNav animated:NO completion:nil];
            break;
        }
        case 4: {
            ScanViewController *scanVC = [ScanViewController new];
            UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
            [self.selectedViewController presentViewController:scanNav animated:NO completion:nil];
            break;
        }
        case 5: {
            PersonSearchViewController *personSearchVC = [PersonSearchViewController new];
            UINavigationController *personSearchNav = [[UINavigationController alloc] initWithRootViewController:personSearchVC];
            [self.selectedViewController presentViewController:personSearchNav animated:YES completion:nil];
            [self buttonPressed];
            break;
        }
        default: break;
    }
}


#pragma mark -

- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController
{
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    viewController.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-sidebar"]
                                                                                        style:UIBarButtonItemStylePlain
                                                                                       target:self action:@selector(onClickMenuButton)];
    
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-search"]
                                                                                        style:UIBarButtonItemStylePlain
                                                                                       target:self action:@selector(pushSearchViewController)];
    
    
    
    return navigationController;
}

- (void)onClickMenuButton
{
    _presentLeftMenuViewController();
}


#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (self.selectedIndex <= 1 && self.selectedIndex == [tabBar.items indexOfObject:item]) {
        SwipeableViewController *swipeableVC = (SwipeableViewController *)((UINavigationController *)self.selectedViewController).viewControllers[0];
        OSCObjsViewController *objsViewController = (OSCObjsViewController *)swipeableVC.viewPager.childViewControllers[swipeableVC.titleBar.currentIndex];
        
        [objsViewController.refreshControl beginRefreshing];
        [objsViewController.tableView setContentOffset:CGPointMake(0, -objsViewController.refreshControl.frame.size.height)
                                              animated:NO];
        
        [objsViewController performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:1];
    }
}

#pragma mark - 处理左右navigationItem点击事件

- (void)pushSearchViewController
{
    [(UINavigationController *)self.selectedViewController pushViewController:[SearchViewController new] animated:YES];
}




@end
