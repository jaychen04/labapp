//
//  TeamIssueListViewController.m
//  iosapp
//
//  Created by Holden on 15/4/29.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueListViewController.h"
#import "TeamIssueController.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamIssueListCell.h"
#import "TeamIssueList.h"
static NSString *kTeamIssueListCellID = @"teamIssueListCell";
@interface TeamIssueListViewController ()
@property (nonatomic)int projectId;
@property (nonatomic,copy)NSString *source;
@end

@implementation TeamIssueListViewController
- (instancetype)initWithProjectId:(int)projectId source:(NSString*)source
{
    
//    uid 用户id
//    teamid 团队id
//    projectid 项目id :当<=0或不设置时，查询非项目的任务列表
//    source 项目类型："Git@OSC","GitHub"(只有设置了projectid值，这里才需要设置该值)
    
    if (self = [super init]) {
        self.projectId = projectId;
        self.source = source;
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&teamid=12375&projectid=%d&source=%@", OSCAPI_PREFIX, TEAM_PROJECT_CATALOG_LIST,[Config getOwnID],projectId,source];
        };
        
        __weak typeof(self) weakSelf = self;
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            [weakSelf.lastCell statusFinished];
        };
        
        self.objClass = [TeamIssueList class];
    }
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"catalogs"] childrenWithTag:@"catalog"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[TeamIssueListCell class] forCellReuseIdentifier:kTeamIssueListCellID];
}

#pragma mark - tableView things

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        TeamIssueListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kTeamIssueListCellID forIndexPath:indexPath];
        TeamIssueList *list = self.objects[indexPath.row];
        
        [cell.titleLabel setText:list.listTitle];
        [cell.detailLabel setText:[list.listDescription length]<=0?@"暂无描述":list.listDescription];
        [cell.countLabel setText:[NSString stringWithFormat:@"%d/%d",list.openedIssueCount,list.allIssueCount]];
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        return 52;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    TeamIssueList *list = self.objects[indexPath.row];
    TeamIssueController * issueVc = [[TeamIssueController alloc]  init];
//    TeamIssueController * issueVc = [[TeamIssueController alloc]  initWithProjectId:_projectId userId:[Config getOwnID] source:_source catalogId:list.listId];
    [self.navigationController pushViewController:issueVc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
