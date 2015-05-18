//
//  TeamIssueDetailCell.h
//  iosapp
//
//  Created by Holden on 15/5/4.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kteamIssueDetailCellNomal = @"teamIssueDetailCellNomal";
static NSString *kTeamIssueDetailCellRemark = @"teamIssueDetailCellRemark";
static NSString *kTeamIssueDetailCellSubChild = @"teamIssueDetailCellSubChild";

@interface TeamIssueDetailCell : UITableViewCell
@property (nonatomic,strong)UILabel *iconLabel;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *descriptionLabel;
@property (nonatomic,strong)UIScrollView *remarkSv;
@end
