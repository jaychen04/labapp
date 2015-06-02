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
#import "NewTeamIssueViewController.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

#import "TweetEditingVC.h"
#import "NewTeamIssueViewController.h"

static CGFloat teamCellHeight = 35;
static CGFloat pickerWidth = 140;
static NSString * kTeamCellID = @"TeamCell";

@interface TeamCenter () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) TeamTeam *currentTeam;
@property (nonatomic, strong) UITableView *teamPicker;
@property (nonatomic, assign) int currentTeamID;

@property (nonatomic, strong) UIButton *dropdownButton;
@property (nonatomic, strong) UIView *clearView;

@property (nonatomic, assign) BOOL arrowUp;

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
        _currentTeam = _teams[0];
        
        _dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dropdownButton.titleLabel.textColor = [UIColor whiteColor];
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
        
        [self updateTitle];
        
        __block NSInteger row = 0;
        int teamID = [Config teamID];
        [_teams enumerateObjectsUsingBlock:^(TeamTeam *team, NSUInteger idx, BOOL *stop) {
            if (team.teamID == teamID) {
                row = idx;
                *stop = YES;
            }
        }];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [_teamPicker selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"team-create"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(editTweet)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)toggleTeamPicker
{
    [self updateTitle];
    
    [UIView animateWithDuration:0.15f animations:^{
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
    _currentTeam = _teams[indexPath.row];
    
    [self toggleTeamPicker];
    [Config setTeamID:_currentTeam.teamID];
    
    int teamID = [Config teamID];
    
    [self.viewPager.controllers removeAllObjects];
    [self.viewPager.controllers addObjectsFromArray:@[
                                                      [[TeamHomePage alloc] initWithTeamID:teamID],
                                                      [[TeamIssueController alloc] initWithTeamID:teamID],
                                                      [[TeamMemberViewController alloc] initWithTeamID:teamID]
                                                      ]];
    for (UIViewController *vc in self.viewPager.controllers) {
        [self.viewPager addChildViewController:vc];
    }
    
    [self.viewPager.tableView reloadData];
}



#pragma mark - change title

- (void)updateTitle
{
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", _currentTeam.name]];
    
    if (_teams.count > 1) {
        NSString *arrow = [NSString fontAwesomeIconStringForEnum:_arrowUp? FAAngleUp : FAAngleDown];
        _arrowUp = !_arrowUp;
        
        [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:arrow
                                                                                       attributes:@{
                                                                                                    NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:16],
                                                                                                    NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                                                    }]];
    }
    
    [_dropdownButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [_dropdownButton sizeToFit];
}


#pragma mark - create

- (void)createIssue
{
    [self.navigationController pushViewController:[NewTeamIssueViewController new] animated:YES];
}

- (void)editTweet
{
    [self.navigationController pushViewController:[[TweetEditingVC alloc] initWithTeamID:[Config teamID]] animated:YES];
}


@end
