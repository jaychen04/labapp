//
//  TeamIssueController.h
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface TeamIssueController : OSCObjsViewController

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID userID:(int64_t)userID source:(NSString*)source andCatalogID:(int64_t)catalogID;
- (instancetype)initWithTeamID:(int)teamID;

- (void)switchToTeam:(int)teamID;

@end
