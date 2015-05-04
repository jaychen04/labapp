//
//  TeamMemberViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 3/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamMemberViewController : UICollectionViewController

- (instancetype)initWithTeamID:(int)teamID;
- (void)switchToTeam:(int)teamID;

@end
