//
//  TeamIssueController.h
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface TeamIssueController : OSCObjsViewController

- (instancetype)initWithTeamID:(int)teamID;
- (void)switchToTeam:(int)teamID;

@end
