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
#import "TableViewCell.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

#import "MZDayPicker.h"
#import "TeamCalendarView.h"

static NSString *kteamIssueTitleCell = @"teamIssueTitleCell";

@interface NewTeamIssueViewController ()<MZDayPickerDelegate, MZDayPickerDataSource>
@property (nonatomic,strong)MZDayPicker *dayPicker;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSArray *iconArray;
@property (nonatomic, strong) NSArray *titlteArray;
@property (nonatomic, strong) NSArray *valueArray;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) NSMutableArray *projects;
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

    //self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [UIView new];
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
        cell.backgroundColor = [UIColor themeColor];
        _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, CGRectGetWidth([[UIScreen mainScreen] bounds])-40, CGRectGetHeight(cell.frame)-10)];
        _titleTextField.placeholder = @"任务标题";
        [cell addSubview:_titleTextField];
        
        return cell;
    } else if (row == _selectedRow + 1) {
        TableViewCell *cell = [TableViewCell new];
        [cell setContentWithDataSource:_members];
        
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [self setupDayPickerViewWithFrame:CGRectMake(0, CGRectGetMaxY(cell.frame), CGRectGetWidth([UIScreen mainScreen].bounds), 60)];
    
    TeamCalendarView *cv = [[TeamCalendarView alloc]initTeamCalendarViewWithFrame:CGRectMake(0, CGRectGetMaxY(cell.frame), CGRectGetWidth([UIScreen mainScreen].bounds), 90)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:cv];
    });
    
    return;
    
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
        
        if (_members.count) {
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        } else {
            [_manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_MEMBER_LIST]
               parameters:@{@"teamid": @([Config teamID])}
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
}


-(void)setupDayPickerViewWithFrame:(CGRect)frame{
    
    self.dayPicker = [[MZDayPicker alloc]initWithFrame:frame dayCellSize:CGSizeMake(60, 60) dayCellFooterHeight:20];
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    
    self.dayPicker.dayNameLabelFontSize = 12.0f;
    self.dayPicker.dayLabelFontSize = 18.0f;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-M"];
        
    [self.dayPicker setStartDate:[NSDate date] endDate:[NSDate dateFromDay:28 month:10 year:2113]];
    
    [self.dayPicker setCurrentDate:[NSDate date] animated:NO];
    
    [self.view addSubview:self.dayPicker];
    
    //    UIToolbar *toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dayPicker.frame)+10,CGRectGetWidth(self.bounds), 40)];
    //    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    //    leftItem.tintColor = [UIColor blackColor];
    //    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
    //    rightItem.tintColor = [UIColor blackColor];
    //
    //    toolbar.items=@[leftItem,centerSpace,rightItem];
    //    [self addSubview:toolbar];
}

#pragma mark --MZDayPickerDataSource
- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
    return [self.dateFormatter stringFromDate:day.date];
}

#pragma mark --MZDayPickerDelegate
- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
    NSLog(@"Did select day %@",day.day);
}

- (void)dayPicker:(MZDayPicker *)dayPicker willSelectDay:(MZDay *)day
{
    NSLog(@"Will select day %@",day.day);
}

- (void)viewDidUnload {
    [self setDayPicker:nil];
}
@end
