//
//  ActivityDetailsViewController.h
//  iosapp
//
//  Created by ChanAetern on 1/26/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCActivity;

@interface ActivityDetailsViewController : UITableViewController

- (instancetype)initWithActivity:(OSCActivity *)activity;

@end
