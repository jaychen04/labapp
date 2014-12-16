//
//  TabBarCenterButton.h
//  iosapp
//
//  Created by chenhaoxiang on 12/15/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarCenterButton : UIButton

@property (nonatomic, readonly, assign) BOOL pressed;

- (instancetype)initWithTabBar:(UITabBar *)tabBar;

@end
