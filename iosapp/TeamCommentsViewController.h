//
//  TeamCommentsViewController.h
//  iosapp
//
//  Created by AeternChan on 5/19/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@class TeamActivity;

@interface TeamCommentsViewController : OSCObjsViewController

@property (nonatomic, copy) UITableViewCell * (^detailCell)();
@property (nonatomic, copy) CGFloat (^detailCellHeight)();


- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID;


@end
