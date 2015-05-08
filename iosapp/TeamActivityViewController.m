//
//  TeamActivityViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamActivityViewController.h"
#import "TeamAPI.h"
#import "TeamActivity.h"
#import "TeamActivityCell.h"

#import <TTTAttributedLabel.h>

#import "TeamActivityDetailViewController.h"
static NSString * const kActivityCellID = @"TeamActivityCell";

@interface TeamActivityViewController ()

@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic,assign) int teamID;
@end

@implementation TeamActivityViewController

- (instancetype)initWithTeamID:(int)teamID
{
    if (self = [super init]) {
        _teamID = teamID;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d&type=all&pageIndex=%lu", TEAM_PREFIX, TEAM_ACTIVITY_LIST, teamID, (unsigned long)page];
        };
        
        self.objClass = [TeamActivity class];
        self.needCache = YES;
    }
    
    return self;
}

#pragma mark --某个团队项目的动态

- (instancetype)initWithTeamID:(int)teamID ProjectID:(int)projectID
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d&projectid=%d&source=Git@OSC&type=all&pageIndex=%lu", TEAM_PREFIX, TEAM_PROJECT_ACTIVE_LIST,teamID, projectID, (unsigned long)page];
        };
        _teamID = teamID;
        self.objClass = [TeamActivity class];
        self.needCache = YES;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"团队动态";
    [self.tableView registerClass:[TeamActivityCell class] forCellReuseIdentifier:kActivityCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"actives"] childrenWithTag:@"active"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        TeamActivity *activity = self.objects[indexPath.row];
        
        self.label.attributedText = activity.attributedTitle;
        
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        
        return height + 63;
    } else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        TeamActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kActivityCellID forIndexPath:indexPath];
        TeamActivity *activity = self.objects[indexPath.row];
        
        [cell setContentWithActivity:activity];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        TeamActivity *activity = self.objects[indexPath.row];
        TeamActivityDetailViewController *detailVC = [[TeamActivityDetailViewController alloc] initWithActivity:activity andTeamID:_teamID];
        [self.navigationController pushViewController:detailVC animated:YES];
    }else {
        [self fetchMore];
    }
}





@end
