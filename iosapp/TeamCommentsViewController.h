//
//  TeamCommentsViewController.h
//  iosapp
//
//  Created by AeternChan on 5/19/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@class TeamActivity;
@class TeamReply;

@interface TeamCommentsViewController : OSCObjsViewController

@property (nonatomic, copy) UITableViewCell * (^detailCell)();
@property (nonatomic, copy) CGFloat (^detailCellHeight)();

@property (nonatomic, copy) void (^didReplySelected)(TeamReply *reply);
@property (nonatomic, copy) void (^didScroll)();


- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID;


@end
