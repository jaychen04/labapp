//
//  TeamActivityDetailViewController.h
//  iosapp
//
//  Created by Holden on 15/5/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "BottomBarViewController.h"

@class TeamActivity;

@interface TeamActivityDetailViewController : BottomBarViewController

- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID;

@end
