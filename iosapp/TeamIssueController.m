
//
//  TeamIssueController.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamIssueController.h"
#import "TeamAPI.h"
#import "TeamIssue.h"
#import "TeamIssueCell.h"
#import "Utils.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

#import "TeamIssueDetailController.h"

static NSString * const kIssueCellID = @"IssueCell";

@interface TeamIssueController ()

@property (nonatomic, assign) int teamID;

@end

@implementation TeamIssueController


//uid 用户id
//teamid 团队id
//projectid 项目id :当<=0或不设置时，查询非项目的任务列表
//source 项目类型："Git@OSC","GitHub"(只有设置了projectid值，这里才需要设置该值)
- (instancetype)initWithTeamID:(int)teamID
{
    self = [super init];
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url = [NSString stringWithFormat:@"%@%@?teamid=%d&project=-1&pageIndex=%lu", TEAM_PREFIX, TEAM_ISSUE_LIST, teamID, (unsigned long)page];
            return url;
        };
        
        self.objClass = [TeamIssue class];
    }
    
    return self;
}

- (instancetype)initWithTeamId:(int)teamId ProjectId:(int)projectId userId:(int64_t)userId source:(NSString*)source catalogId:(int64_t)catalogId
{
    self = [super init];
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url = [NSString stringWithFormat:@"%@%@?uid=%lldll&teamid=%d&projectid=%d&source=%@&catalogid=%llu", TEAM_PREFIX, TEAM_ISSUE_LIST,userId,teamId,projectId,source,catalogId];
            return url;
        };
        
        self.objClass = [TeamIssue class];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[TeamIssueCell class] forCellReuseIdentifier:kIssueCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"issues"] childrenWithTag:@"issue"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row < self.objects.count) {
        UILabel *label = [UILabel new];
        TeamIssue *issue = self.objects[indexPath.row];
        
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.text = issue.title;
        
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
        
        return height + 63;
    } else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        TeamIssueCell *cell = [tableView dequeueReusableCellWithIdentifier:kIssueCellID forIndexPath:indexPath];
        TeamIssue *issue = self.objects[indexPath.row];
        
        [cell setContentWithIssue:issue];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    TeamIssueDetailController *teamIssueDetailVC = [TeamIssueDetailController new];
//    [self.navigationController pushViewController:teamIssueDetailVC animated:YES];
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        
    }else {
        [self fetchMore];
    }
}


#pragma mark - 切换团队

- (void)switchToTeam:(int)teamID
{
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?teamid=%d&project=-1&pageIndex=%lu", TEAM_PREFIX, TEAM_ISSUE_LIST, teamID, (unsigned long)page];
    };
    
    [self refresh];
}


@end
