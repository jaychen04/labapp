//
//  TeamCommentsBVC.h
//  iosapp
//
//  Created by AeternChan on 5/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "BottomBarViewController.h"

@class TeamActivity;

@interface TeamCommentsBVC : BottomBarViewController

- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID;

@end
