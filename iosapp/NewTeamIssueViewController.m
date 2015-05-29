//
//  NewTeamIssueViewController.m
//  iosapp
//
//  Created by Holden on 15/5/21.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "NewTeamIssueViewController.h"
#import "TeamIssueDetailCell.h"
#import "TeamAPI.h"
#import "Config.h"
#import "Utils.h"
#import "CheckboxTableCell.h"
#import "TeamMember.h"
#import "TeamProject.h"
#import "TeamIssueList.h"
#import "TableViewCell.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

static NSString *kteamIssueTitleCell = @"teamIssueTitleCell";

@interface NewTeamIssueViewController ()

@property (nonatomic, strong) NSArray *iconArray;
@property (nonatomic, strong) NSArray *titlteArray;
@property (nonatomic, strong) NSArray *valueArray;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) TeamProject *selectedProject;
@property (nonatomic, strong) NSMutableArray *issueGroups;

@end

@implementation NewTeamIssueViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _members = [NSMutableArray new];
        _projects = [NSMutableArray new];
        _issueGroups = [NSMutableArray new];
        _selectedRow = -2;
        
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"新团队任务";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStylePlain target:self action:nil];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor themeColor];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.bounces = NO;
    [self.tableView registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:kteamIssueDetailCellNomal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectedRow < 0? 5 : 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedRow + 1) {
        if (_selectedRow == 1) {return _projects.count > 4? 200 : _projects.count * 40;}
        if (_selectedRow == 2) {return _issueGroups.count > 4? 200 : _issueGroups.count * 40;}
        if (_selectedRow == 3) {return _members.count > 4? 200 : _members.count * 40;}
        return 200;
    } else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row;
    if (indexPath.row <= _selectedRow || _selectedRow <= 0) {
        row = indexPath.row;
    } else if (indexPath.row == _selectedRow + 1) {
        row = _selectedRow + 1;
    } else {
        row = indexPath.row - 1;
    }
    
    if (row == 0) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor themeColor];
        _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, CGRectGetWidth([[UIScreen mainScreen] bounds])-40, CGRectGetHeight(cell.frame)-10)];
        _titleTextField.placeholder = @"任务标题";
        [cell addSubview:_titleTextField];
        
        return cell;
    } else if (row == _selectedRow + 1) {
        TableViewCell *cell = [TableViewCell new];
        
        if (_selectedRow == 1) {
            [cell setContentWithDataSource:_projects ofType:DataSourceTypeProject];
        } else if (_selectedRow == 2) {
            [cell setContentWithDataSource:_issueGroups ofType:DataSourceTypeIssueGroup];
        } else {
            [cell setContentWithDataSource:_members ofType:DataSourceTypeMember];
        }
        
        return cell;
    } else {
        CheckboxTableCell *cell = [[CheckboxTableCell alloc] initWithCellType:row - 1];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_titleTextField resignFirstResponder];
    
    if (indexPath.row != 0) {        
        if (_selectedRow > 0) {
            NSInteger preRow = _selectedRow;
            _selectedRow = -2;
            
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:preRow + 1 inSection:0]]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            
            return;
        } else {
            _selectedRow = indexPath.row;
        }
        
        switch (indexPath.row) {
            case 1: {
                if (_projects.count) {
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                } else {
                    [_manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_PROJECT_LIST]
                       parameters:@{@"teamid": @([Config teamID])}
                          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                              NSArray *projectsXML = [[responseObject.rootElement firstChildWithTag:@"projects"] childrenWithTag:@"project"];
                              
                              for (ONOXMLElement *projectXML in projectsXML) {
                                  TeamProject *teamProject = [[TeamProject alloc] initWithXML:projectXML];
                                  [_projects addObject:teamProject];
                              }
                              
                              [tableView beginUpdates];
                              [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationFade];
                              [tableView endUpdates];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              
                          }];
                }
            }
                break;
            case 2: {
                if (_issueGroups.count) {
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                } else {
                    [_manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_PROJECT_CATALOG_LIST]
                       parameters:@{
                                    @"uid": @([Config getOwnID]),
                                    @"teamid": @([Config teamID]),
                                    @"projectid": @(0)
                                    }
                          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                              NSArray *issueGroupsXML = [[responseObject.rootElement firstChildWithTag:@"catalogs"] childrenWithTag:@"catalog"];
                              
                              for (ONOXMLElement *issueGroupXMl in issueGroupsXML) {
                                  TeamIssueList *issueGroup = [[TeamIssueList alloc] initWithXML:issueGroupXMl];
                                  [_issueGroups addObject:issueGroup];
                              }
                              
                              [tableView beginUpdates];
                              [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationFade];
                              [tableView endUpdates];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              
                          }];
                }
            }
                break;
            case 3: {
                if (_members.count) {
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                } else {
                    [_manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_PROJECT_MEMBER_LIST]
                       parameters:@{
                                    @"uid": @([Config getOwnID]),
                                    @"teamid": @([Config teamID])
                                    }
                          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                              NSArray *membersXML = [[responseObject.rootElement firstChildWithTag:@"members"] childrenWithTag:@"member"];
                              
                              for (ONOXMLElement *memberXML in membersXML) {
                                  TeamMember *teamMember = [[TeamMember alloc] initWithXML:memberXML];
                                  [_members addObject:teamMember];
                              }
                              
                              [tableView beginUpdates];
                              [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationFade];
                              [tableView endUpdates];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              
                          }];
                }
            }
                break;
            default: break;
        }
    }
}




@end
