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
        
        CGFloat titleBarHeight = 36;
        _titleBar = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, titleBarHeight) andTitles:subTitles];
        _titleBar.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_titleBar];
        
        
        _viewPager = [[HorizonalTableViewController alloc] initWithViewControllers:controllers];
        _viewPager.view.frame = CGRectMake(0,  titleBarHeight, self.view.frame.size.width, self.view.frame.size.height - titleBarHeight);
        [self addChildViewController:self.viewPager];
        [self.view addSubview:_viewPager.view];
        
        
        __block TitleBarView *weakTitleBar = _titleBar;
        __block HorizonalTableViewController *weakViewPager = _viewPager;
        
        _viewPager.changeIndex = ^(NSUInteger index) {
            weakTitleBar.currentIndex = index;
            for (UIButton *button in weakTitleBar.titleButtons) {
                if (button.tag != index) {
                    [button setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
                    button.transform = CGAffineTransformIdentity;
                } else {
                    [button setTitleColor:[UIColor colorWithHex:0x009000] forState:UIControlStateNormal];
                    button.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }
            }
            [weakViewPager scrollToViewAtIndex:index];
        };
        
        _viewPager.scrollView = ^(CGFloat offsetRatio, NSUInteger focusIndex, NSUInteger animationIndex) {
            UIButton *titleFrom = weakTitleBar.titleButtons[animationIndex];
            UIButton *titleTo = weakTitleBar.titleButtons[focusIndex];
            CGFloat colorValue = (CGFloat)0x90 / (CGFloat)0xFF;
            
            [UIView transitionWithView:titleFrom duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [titleFrom setTitleColor:[UIColor colorWithRed:colorValue*(1-offsetRatio) green:colorValue blue:colorValue*(1-offsetRatio) alpha:1.0]
                                forState:UIControlStateNormal];
                titleFrom.transform = CGAffineTransformMakeScale(1 + 0.2 * offsetRatio, 1 + 0.2 * offsetRatio);
            } completion:nil];
            
            
            [UIView transitionWithView:titleTo duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [titleTo setTitleColor:[UIColor colorWithRed:colorValue*offsetRatio green:colorValue blue:colorValue*offsetRatio alpha:1.0]
                              forState:UIControlStateNormal];
                titleTo.transform = CGAffineTransformMakeScale(1 + 0.2 * (1-offsetRatio), 1 + 0.2 * (1-offsetRatio));
            } completion:nil];
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
