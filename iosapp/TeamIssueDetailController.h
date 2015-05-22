//
//  TeamIssueDetailController.h
//  iosapp
//
//  Created by Holden on 15/4/30.
//  Copyright (c) 2015年 oschina. All rights reserved.
//


#import "BottomBarViewController.h"
@interface TeamIssueDetailController : BottomBarViewController
@property (nonatomic,copy)NSString *projectName;
- (instancetype)initWithTeamId:(int)teamId andIssueId:(int)issueId;
@end
