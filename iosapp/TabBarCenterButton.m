//
//  TabBarCenterButton.m
//  iosapp
//
//  Created by chenhaoxiang on 12/15/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TabBarCenterButton.h"
#import "OSCTabBarController.h"
#import <ReactiveCocoa.h>

@interface TabBarCenterButton ()

@property (nonatomic, readwrite, assign) BOOL isPressed;
@property (nonatomic, strong) UITabBar *tabBar;
@property (nonatomic, strong) UIView *blackView;

@end

@implementation TabBarCenterButton

- (instancetype)initWithTabBar:(UITabBar *)tabBar
{
    if (self = [super init]) {
        _tabBar = tabBar;
        _isPressed = NO;
        //self.backgroundColor = [UIColor greenColor];
        
        [self installTheButton];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin;
        self.translatesAutoresizingMaskIntoConstraints = YES;
    }
    return self;
}

- (void)installTheButton
{
    CGPoint pointToSuperview = [self buttonLocaitonForIndex:2];
    CGRect myRect = CGRectMake(pointToSuperview.x,
                               pointToSuperview.y,
                               60, 60);
    self.frame = myRect;
    self.center = pointToSuperview;
    self.backgroundColor = [UIColor orangeColor];
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
    [_tabBar.superview addSubview:self];
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.tabBar addObserver:self
                  forKeyPath:@"selectedItem"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
}


- (CGPoint)buttonLocaitonForIndex:(NSUInteger)index {
    UITabBarItem *item = [self.tabBar.items objectAtIndex:index];
    UIView *view = [item valueForKey:@"view"];
    CGPoint pointToSuperview = [self.tabBar.superview
                                convertPoint:view.center
                                fromView:self.tabBar];
    return pointToSuperview;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if([keyPath isEqualToString:@"selectedItem"]) {
        if(self.isPressed) {
            [self buttonPressed];
        }
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
        [self removeBlackView];
    } else {
        [self addBlackView];
    }
}

- (void)addBlackView
{
    self.enabled = NO;
    _blackView = [[UIView alloc] initWithFrame:self.tabBar.superview.bounds];
    _blackView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    [_blackView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    _blackView.backgroundColor = [UIColor blackColor];
    _blackView.alpha = 0.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackViewPressed)];
    [_blackView addGestureRecognizer:tap];
    
    [self.tabBar.superview insertSubview:_blackView belowSubview:self.tabBar];
    [UIView animateWithDuration:0.3
                     animations:^{_blackView.alpha = 0.7;}
                     completion:^(BOOL finished) {
                         if(finished) {self.enabled = YES;}
                     }];
}


- (void)removeBlackView {
    
    self.enabled = NO;
    [UIView animateWithDuration:0.3
                     animations:^{self.blackView.alpha = 0.0;}
                     completion:^(BOOL finished) {
                         if(finished) {
                             [self.blackView removeFromSuperview];
                             self.blackView = nil;
                             self.enabled = YES;
                         }
                     }];
}


- (void)blackViewPressed {
    [self buttonPressed];
}



@end
