//
//  UserDetailsViewController.h
//  iosapp
//
//  Created by ChanAetern on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCUser;

@interface UserDetailsViewController : UIViewController

- (instancetype)initWithUser:(OSCUser *)user;
- (instancetype)initWithUserID:(int64_t)userID;

@end
