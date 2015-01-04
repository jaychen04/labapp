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

@interface OSCTabBarController ()

@property (nonatomic, strong) UIView *bgView;
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
    
    // 功能键相关
    _optionButtons = [NSMutableArray new];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth  = [UIScreen mainScreen].bounds.size.width;
    _length = 70;        // 圆形按钮的直径
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    NSArray *buttonTitles = @[@"文字", @"相册", @"拍照", @"语音", @"扫一扫", @"便签"];
    NSArray *buttonImages = @[@"tweet_words", @"tweet_picture", @"tweet_shooting", @"tweet_sound", @"tweet_QRcode", @"tweet_note"];
    NSArray *buttonColors = @[[UIColor purpleColor], [UIColor greenColor], [UIColor yellowColor],
                              [UIColor brownColor],  [UIColor blueColor],  [UIColor redColor]];
    
    for (int i = 0; i < 6; i++) {
        OptionButton *optionButton = [[OptionButton alloc] initWithTitle:buttonTitles[i]
                                                                   image:[UIImage imageNamed:buttonImages[i]]
                                                                andColor:buttonColors[i]];
        
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
        [self addBackgroundView];
        
        [_animator removeAllBehaviors];
        for (int i = 0; i < 6; i++) {
            UIButton *button = _optionButtons[i];
            
            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:button
                                                                         attachedToAnchor:CGPointMake(_screenWidth/6 * (i%3*2+1),
                                                                                                      _screenHeight - 300 + i/3*125)];
            attachment.damping = 0.5;
            attachment.frequency = 4;
            attachment.length = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC * i), dispatch_get_main_queue(), ^{
                [_animator addBehavior:attachment];
            });
        }
    }
}

- (void)addBackgroundView
{
    _centerButton.enabled = NO;
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.alpha = 0.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
    [_bgView addGestureRecognizer:tap];
    
    [self.view insertSubview:_bgView belowSubview:self.tabBar];
    [UIView animateWithDuration:0.3
                     animations:^{_bgView.alpha = 0.9;}
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
        case 3: {break;}
        case 4: {break;}
        case 5: {break;}
        default: break;
    }
}




@end
