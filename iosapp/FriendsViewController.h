//
//  FriendsViewController.h
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface FriendsViewController : OSCObjsViewController

- (instancetype)initWithUserID:(int64_t)userID andFriendsRelation:(int)relation;

@end
