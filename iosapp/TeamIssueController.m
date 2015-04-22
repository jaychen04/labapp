
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

static NSString * const kIssueCellID = @"IssueCell";

@interface TeamIssueController ()

@property (nonatomic, strong) NSMutableArray *issues;

@end

@implementation TeamIssueController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[TeamIssueCell class] forCellReuseIdentifier:kIssueCellID];
    self.tableView.backgroundColor = [UIColor themeColor];
    
    _issues = [NSMutableArray new];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_ISSUE_LIST]
      parameters:@{
                   @"teamid": @(12375),
                   @"project": @"-1"
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             NSArray *issuesXML = [[responseObject.rootElement firstChildWithTag:@"issues"] childrenWithTag:@"issue"];
             
             for (ONOXMLElement *issueXML in issuesXML) {
                 [_issues addObject:[[TeamIssue alloc] initWithXML:issueXML]];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _issues.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = [UILabel new];
    TeamIssue *issue = _issues[indexPath.row];
    
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.text = issue.title;
    
    CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
    
    return height + 63;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamIssueCell *cell = [tableView dequeueReusableCellWithIdentifier:kIssueCellID forIndexPath:indexPath];
    TeamIssue *issue = _issues[indexPath.row];
    
    [cell setContentWithissue:issue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




@end
