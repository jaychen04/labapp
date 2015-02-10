//
//  HorizonalTableViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-23.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorizonalTableViewController : UITableViewController

@property (nonatomic, copy) void (^changeIndex)(NSUInteger index);
@property (nonatomic, copy) void (^scrollView)(CGFloat offsetRatio, NSUInteger focusIndex, NSUInteger animationIndex);

- (instancetype)initWithViewControllers:(NSArray *)controllers;

- (void)scrollToViewAtIndex:(NSUInteger)index;

@end
