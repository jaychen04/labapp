//
//  TeamMyIssueViewController.h
//  iosapp
//
//  Created by Holden on 15/5/13.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "SwipableViewController.h"
#import "TeamIssueController.h"
@class TeamIssueController;

@interface TeamMyIssueViewController : SwipableViewController
- (instancetype)initWithIssueState:(IssueState)state;
@end
