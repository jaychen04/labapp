//
//  TeamCenter.m
//  iosapp
//
//  Created by AeternChan on 4/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamCenter.h"
#import "Config.h"
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
@property (nonatomic, assign) int currentTeamID;

@property (nonatomic, strong) UIButton *dropdownButton;
@property (nonatomic, strong) UIView *clearView;

@end

@implementation TeamCenter

- (instancetype)initWithTeams:(NSArray *)teams
{
    TeamTeam *team = teams[0];
    [Config setTeamID:team.teamID];
    
    self = [super initWithTitle:@"Team"
                   andSubTitles:@[@"主页", @"任务", @"成员"]
                 andControllers:@[
                                  [[TeamHomePage alloc] initWithTeamID:team.teamID],
                                  [[TeamIssueController alloc] initWithTeamID:team.teamID],
                                  [[TeamMemberViewController alloc] initWithTeamID:team.teamID]
                                  ]];
    
    if (self) {
        _teams = teams;
        
        _dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dropdownButton setTitle:((TeamTeam *)_teams[0]).name forState:UIControlStateNormal];
        [_dropdownButton addTarget:self action:@selector(toggleTeamPicker) forControlEvents:UIControlEventTouchUpInside];
        _dropdownButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.navigationItem.titleView = _dropdownButton;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat pickerHeight = (_teams.count > 5 ? 5 * teamCellHeight : _teams.count * teamCellHeight) + 16;
        _teamPicker = [[UITableView alloc] initWithFrame:CGRectMake((screenSize.width - pickerWidth)/2, 0, pickerWidth, pickerHeight)];
        [_teamPicker registerClass:[TeamCell class] forCellReuseIdentifier:kTeamCellID];
        _teamPicker.dataSource = self;
        _teamPicker.delegate = self;
        _teamPicker.alpha = 0;
        
        _teamPicker.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_teamPicker setCornerRadius:3];
        _teamPicker.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _teamPicker.backgroundColor = [UIColor colorWithHex:0x555555];
        [self.view addSubview:_teamPicker];
        
        _clearView = [[UIView alloc] initWithFrame:self.view.bounds];
        _clearView.backgroundColor = [UIColor clearColor];
        [_clearView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTeamPicker)]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)toggleTeamPicker
{
    [UIView animateWithDuration:0.2f animations:^{
        //_teamPicker.hidden = !_teamPicker.hidden;
        [_teamPicker setAlpha:1.0f - _teamPicker.alpha];
    } completion:^(BOOL finished) {
        if (_teamPicker.alpha <= 0.0f) {
            [_clearView removeFromSuperview];
        } else {
            [self.view addSubview:_clearView];
            [self.view bringSubviewToFront:_teamPicker];
        }
    }];
}


#pragma mark - teamPicker

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
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return teamCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamCell *cell = [tableView dequeueReusableCellWithIdentifier:kTeamCellID forIndexPath:indexPath];
    
    cell.textLabel.text = ((TeamTeam *)_teams[indexPath.row]).name;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamTeam *team = _teams[indexPath.row];
    [_dropdownButton setTitle:team.name forState:UIControlStateNormal];
    [_dropdownButton sizeToFit];
    _currentTeamID = team.teamID;
    
    [self toggleTeamPicker];
    [Config setTeamID:_currentTeamID];
    
    for (id vc in self.viewPager.controllers) {
        [vc switchToTeam:_currentTeamID];
    }
}


@end
