//
//  ActivityDetailsViewController.h
//  iosapp
//
//  Created by ChanAetern on 1/26/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityDetailsWithBarViewController;

@class OSCActivity;

@interface ActivityDetailsViewController : UITableViewController

@property (nonatomic, weak) ActivityDetailsWithBarViewController *bottomBarVC;

- (instancetype)initWithActivity:(OSCActivity *)activity;

@end
