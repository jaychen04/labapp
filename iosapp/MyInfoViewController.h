//
//  MyInfoViewController.h
//  iosapp
//
//  Created by ChanAetern on 12/10/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCUser;

@interface MyInfoViewController : UITableViewController

- (instancetype)initWithUser:(OSCUser *)user;
- (instancetype)initWithUserID:(int64_t)userID;

@end
