//
//  SwipeableViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-19.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "SwipeableViewController.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "TweetsViewController.h"
#import "PostsViewController.h"

@interface SwipeableViewController ()  <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *controllers;

@end



@implementation SwipeableViewController

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers
{
    self = [super init];
    if (self) {
        if (title) {self.title = title;}
        
        CGFloat titleBarHeight = 43;
        _titleBar = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, titleBarHeight) andTitles:subTitles];
        _titleBar.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_titleBar];
        
        
        _viewPager = [[HorizonalTableViewController alloc] initWithViewControllers:controllers];
        _viewPager.view.frame = CGRectMake(0,  titleBarHeight, self.view.frame.size.width, self.view.frame.size.height - titleBarHeight);
        [self addChildViewController:self.viewPager];
        [self.view addSubview:_viewPager.view];
        
        
        __weak TitleBarView *weakTitleBar = _titleBar;
        __weak HorizonalTableViewController *weakViewPager = _viewPager;
        _viewPager.changeIndex = ^(NSUInteger index) {
#if 1
            weakTitleBar.currentIndex = index;
            for (UIButton *button in weakTitleBar.titleButtons) {
                if (button.tag != index) {
                    [button setTitleColor:[UIColor colorWithHex:0x808080] forState:UIControlStateNormal];
                } else {
                    [button setTitleColor:[UIColor colorWithHex:0x808080] forState:UIControlStateNormal];
                }
            }
#else
            UIButton *titleFrom = weakTitleBar.titleButtons[weakTitleBar.currentIndex];
            [titleFrom setTitleColor:[UIColor colorWithHex:0x808080] forState:UIControlStateNormal];
            
            weakTitleBar.currentIndex = index;
            UIButton *titleTo = weakTitleBar.titleButtons[weakTitleBar.currentIndex];
            [titleTo setTitleColor:[UIColor colorWithHex:0x008000] forState:UIControlStateNormal];
#endif
            [weakViewPager scrollToViewAtIndex:index];
        };
        _viewPager.scrollView = ^(CGFloat offsetRatio, NSUInteger index) {
            UIButton *titleFrom = weakTitleBar.titleButtons[weakTitleBar.currentIndex];
            [titleFrom setTitleColor:[UIColor colorWithRed:0.5*(1-offsetRatio) green:0.5 blue:0.5*(1-offsetRatio) alpha:1.0]
                            forState:UIControlStateNormal];
            
            UIButton *titleTo = weakTitleBar.titleButtons[index];
            [titleTo setTitleColor:[UIColor colorWithRed:0.5*offsetRatio green:0.5*(1-offsetRatio) blue:0*offsetRatio alpha:1.0]
                          forState:UIControlStateNormal];
        };
        _titleBar.titleButtonClicked = ^(NSUInteger index) {
            [weakViewPager scrollToViewAtIndex:index];
        };
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor themeColor];
}




#pragma mark - <TitleBarDelegate>

- (void)selectTitleAtIndex:(NSUInteger)index
{
    [_viewPager scrollToViewAtIndex:index];
}


@end
