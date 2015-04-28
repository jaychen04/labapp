//
//  TeamCenter.m
//  iosapp
//
//  Created by AeternChan on 4/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamCenter.h"
#import "TeamTeam.h"
#import "TeamHomePage.h"
#import "TeamIssueController.h"
#import "TeamMemberViewController.h"
#import "TeamCell.h"

static CGFloat teamCellHeight = 35;
static CGFloat pickerWidth = 140;
static NSString * kTeamCellID = @"TeamCell";

@interface TeamCenter () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) UITableView *teamPicker;

@end

@implementation TeamCenter

- (instancetype)initWithTeams:(NSArray *)teams
{
    self = [super initWithTitle:@"Team"
                   andSubTitles:@[@"主页", @"任务", @"成员"]
                 andControllers:@[
                                  [TeamHomePage new],
                                  [TeamIssueController new],
                                  [TeamMemberViewController new]
                                  ]];
    
    if (self) {
        _teams = teams;
        
        UIButton *dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dropdownButton setTitle:((TeamTeam *)_teams[0]).name forState:UIControlStateNormal];
        [dropdownButton addTarget:self action:@selector(navButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = dropdownButton;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _teamPicker = [[UITableView alloc] initWithFrame:CGRectMake((screenSize.width - pickerWidth)/2, 0, pickerWidth, _teams.count * teamCellHeight + 20)];
        [_teamPicker registerClass:[TeamCell class] forCellReuseIdentifier:kTeamCellID];
        _teamPicker.dataSource = self;
        _teamPicker.delegate = self;
        _teamPicker.hidden = YES;
        
        _teamPicker.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_teamPicker setCornerRadius:3];
        _teamPicker.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _teamPicker.backgroundColor = [UIColor colorWithHex:0x555555];
        [self.view addSubview:_teamPicker];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if 0
    UIButton *dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropdownButton setTitle:((TeamTeam *)_teams[0]).name forState:UIControlStateNormal];
    [dropdownButton addTarget:self action:@selector(navButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = dropdownButton;
    
    _teamPicker = [[TeamPickerViewController alloc] initWithTeams:_teams];
    [self addChildViewController:_teamPicker];
    [self.view addSubview:_teamPicker.view];
    _teamPicker.view.hidden = YES;
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_teamPicker selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navButtonTapped
{
    _teamPicker.hidden = !_teamPicker.hidden;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _teams.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithHex:0x555555];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithHex:0x555555];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return teamCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamCell *cell = [tableView dequeueReusableCellWithIdentifier:kTeamCellID forIndexPath:indexPath];
    [cell setCornerRadius:3];
    cell.backgroundColor = [UIColor colorWithHex:0x555555];
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = [UIColor colorWithHex:0x333333];
    cell.selectedBackgroundView = selectedBackground;
    
    cell.textLabel.text = ((TeamTeam *)_teams[indexPath.row]).name;
    cell.textLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    
    return cell;
}


@end
