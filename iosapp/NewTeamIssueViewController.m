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

#import "NSString+FontAwesome.h"
#import "TeamCalendarView.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

static NSString *kteamIssueTitleCell = @"teamIssueTitleCell";

@interface NewTeamIssueViewController ()<DatePickViewDelegate>

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

@property (nonatomic,strong) CheckboxTableCell *calendarCell;
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
    

    self.tableView.bounces = NO;
    [self.tableView registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:kteamIssueDetailCellNomal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//是否同步到gitHub或gitOsc
-(void)selectSyncOption:(UITapGestureRecognizer*)tap
{
    UIView *syncView = tap.view;
    UILabel *flagLabel = (UILabel*)[syncView viewWithTag:108];
    flagLabel.text = [flagLabel.text isEqualToString:@"\uf046"]?@"\uf096":@"\uf046";
}
//footerView
-(UIView*)setupSyncView
{
    UIView *syncView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, CGRectGetWidth([[UIScreen mainScreen] bounds]), 60)];
    [syncView setBackgroundColor:[UIColor themeColor]];
    
    UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(15, 0, CGRectGetWidth(syncView.frame), .5)];
    topLineView.backgroundColor = [UIColor lightGrayColor];
    [syncView addSubview:topLineView];
    
    syncView.userInteractionEnabled = YES;
    [syncView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSyncOption:)]];
    
    UILabel *syncTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, CGRectGetHeight(syncView.frame))];
    syncTitleLabel.textColor = [UIColor colorWithHex:0x555555];
    syncTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    syncTitleLabel.text = @"同步到GitHub";
    [syncView addSubview:syncTitleLabel];
    
    UILabel *syncFlagLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth([[UIScreen mainScreen] bounds])-35, 0, 25, 25)];
    syncFlagLabel.center = CGPointMake(syncFlagLabel.center.x, syncTitleLabel.center.y);
    syncFlagLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
    syncFlagLabel.textColor = [UIColor grayColor];
    syncFlagLabel.tag = 108;
    syncFlagLabel.text = @"\uf096";
    [syncView addSubview:syncFlagLabel];
    
    UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(15, CGRectGetHeight(syncView.frame)-.5, CGRectGetWidth(syncView.frame), .5)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [syncView addSubview:bottomLineView];
    
    return syncView;
}
#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (5<=indexPath.row || indexPath.row<=6) {
        self.tableView.tableFooterView = [self setupSyncView];
    }
}

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
        if (_selectedRow == 4) {return 256;}
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
        } else if (_selectedRow == 3) {
            [cell setContentWithDataSource:_members ofType:DataSourceTypeMember];
        }else if (_selectedRow == 4) {
            TeamCalendarView *calendarView = [[TeamCalendarView alloc] initWithSelectedDate:[self getDateWithString:_calendarCell.descriptionLabel.text]];
            calendarView.delegate = self;
            [cell.contentView addSubview:calendarView];
            return cell;
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
                break;
            }
            case 4: {
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                
                _calendarCell =  (CheckboxTableCell*)[tableView cellForRowAtIndexPath:indexPath];
                
            }
                break;
                
            default: break;
        }
    }
}
#pragma mark -- NSString<---->NSDate
-(NSDate*)getDateWithString:(NSString*)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[formatter dateFromString:dateStr];
    return date;
}
-(NSString*)getDateStringWithDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
#pragma mark -- DatePickerViewDelegate
-(void)didSelectDate:(NSDate *)date
{
    _calendarCell.descriptionLabel.text = [self getDateStringWithDate:date];
    
    [self removeCalendarViewCell];
}
-(void)clearSelectedDate
{
    _calendarCell.descriptionLabel.text = @"";

    [self removeCalendarViewCell];
}
-(void)removeCalendarView
{
    [self removeCalendarViewCell];
}
#pragma mark -- 移除日历cell
-(void)removeCalendarViewCell
{
    if (_selectedRow > 0) {
        NSInteger preRow = _selectedRow;
        _selectedRow = -2;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:preRow + 1 inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        return;
    } else {
        _selectedRow = [self.tableView indexPathForCell:_calendarCell].row;
    }
}
@end
