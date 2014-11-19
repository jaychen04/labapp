//
//  BottomBarViewController.h
//  iosapp
//
//  Created by ChanAetern on 11/19/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BottomBar;

@interface BottomBarViewController : UIViewController

@property (nonatomic, strong) BottomBar *bottomBar;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@end
