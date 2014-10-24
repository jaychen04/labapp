//
//  SwipeableViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-19.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarView.h"

@interface SwipeableViewController : UIViewController

- (instancetype)initWithTitles:(NSArray *)titles andControllers:(NSArray *)controllers;

@end
