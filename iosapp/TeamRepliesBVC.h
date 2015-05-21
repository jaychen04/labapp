//
//  TeamRepliesBVC.h
//  iosapp
//
//  Created by AeternChan on 5/21/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "BottomBarViewController.h"

@class TeamReply;
@class TeamActivity;

@interface TeamRepliesBVC : BottomBarViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

- (instancetype)initWIthActivity:(TeamActivity *)activity andTeamID:(int)teamID;

- (void)fetchRepliesOnPage:(NSUInteger)page;

@end
