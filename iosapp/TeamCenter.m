//
//  TeamCenter.m
//  iosapp
//
//  Created by AeternChan on 4/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamCenter.h"
#import "Config.h"
#import "TeamAPI.h"
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

#import <MBProgressHUD.h>

static CGFloat teamCellHeight = 35;
static CGFloat pickerWidth = 140;
static NSString * kTeamCellID = @"TeamCell";

@interface TeamCenter () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *teams;
@property (nonatomic, strong) TeamTeam *currentTeam;
@property (nonatomic, strong) UITableView *teamPicker;

@property (nonatomic, strong) UIButton *dropdownButton;
@property (nonatomic, strong) UIView *clearView;

@property (nonatomic, assign) BOOL arrowUp;

@property (nonatomic, strong) MBProgressHUD *HUD;


@end

@implementation TeamCenter

- (instancetype)init
{
    int teamID = [Config teamID];
    NSArray *controllers;
    if (teamID) {
        controllers = @[
                        [[TeamHomePage alloc] initWithTeamID:teamID],
                        [[TeamIssueController alloc] initWithTeamID:teamID],
                        [[TeamMemberViewController alloc] initWithTeamID:teamID]
                        ];
    } else {
        controllers = @[
                        [UIViewController new],
                        [UIViewController new],
                        [UIViewController new]
                        ];
    }
    
    self = [super initWithTitle:@"Team"
                   andSubTitles:@[@"主页", @"任务", @"成员"]
                 andControllers:controllers];
    
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"team-create"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(createIssue)];
    
    _dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dropdownButton.titleLabel.textColor = [UIColor whiteColor];
    [_dropdownButton addTarget:self action:@selector(toggleTeamPicker) forControlEvents:UIControlEventTouchUpInside];
    _dropdownButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_dropdownButton setTitle:@"" forState:UIControlStateNormal];
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
    
    if (![Config teamID]) {
        _HUD = [Utils createHUD];
        _HUD.userInteractionEnabled = NO;
        _HUD.labelText = @"正在获取团队信息";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
        [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_LIST]
          parameters:@{@"uid": @([Config getOwnID])}
             success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                 NSArray *teamsXML = [[responseObject.rootElement firstChildWithTag:@"teams"] childrenWithTag:@"team"];
                 _teams = [NSMutableArray new];
                 
                 if (teamsXML.count == 0) {
                     self.titleBar.hidden = YES;
                     self.navigationItem.rightBarButtonItem = nil;
                     self.navigationItem.titleView = nil;
                     _HUD.color = [UIColor themeColor];
                     _HUD.mode = MBProgressHUDModeCustomView;
                     _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page_icon_empty"]];
                     _HUD.labelText = @" ";
                     _HUD.detailsLabelColor = [UIColor colorWithHex:0x888888];
                     _HUD.detailsLabelText = @"你还没有加入任何团队";
                     
                     return;
                 }
                 
                 for (ONOXMLElement *teamXML in teamsXML) {
                     TeamTeam *team = [[TeamTeam alloc] initWithXML:teamXML];
                     [_teams addObject:team];
                 }
                 
                 [Config saveTeams:_teams];
                 
                 _currentTeam = _teams[0];
                 [Config setTeamID:_currentTeam.teamID];
                 
                 [self updateTeam];
                 [self updateTitle];
                 [self updateTeamPicker];
                 
                 [_HUD hide:YES];
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 _HUD.mode = MBProgressHUDModeCustomView;
                 _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                 _HUD.detailsLabelText = @"加载团队信息失败";
             }];
    } else {
        _teams = [Config teams];
        
        int currentTeamID = [Config teamID];
        for (TeamTeam *team in _teams) {
            if (team.teamID == currentTeamID) {
                _currentTeam = team;
                break;
            }
        }
        
        [self updateTitle];
        [self updateTeamPicker];
        
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
        [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_LIST]
          parameters:@{@"uid": @([Config getOwnID])}
             success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                 NSArray *teamsXML = [[responseObject.rootElement firstChildWithTag:@"teams"] childrenWithTag:@"team"];
                 [_teams removeAllObjects];
                 
                 for (ONOXMLElement *teamXML in teamsXML) {
                     TeamTeam *team = [[TeamTeam alloc] initWithXML:teamXML];
                     [_teams addObject:team];
                 }
                 
                 [Config saveTeams:_teams];
                 
                 [self updateTeamPicker];
                 
                 [_HUD hide:YES];
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 _HUD.mode = MBProgressHUDModeCustomView;
                 _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                 _HUD.detailsLabelText = @"加载团队信息失败";
             }];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hide:NO];
    [super viewWillDisappear:animated];
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


- (void)updateTeamPicker
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat pickerHeight = (_teams.count > 5 ? 5 * teamCellHeight : _teams.count * teamCellHeight) + 16;
    _teamPicker.frame = CGRectMake((screenSize.width - pickerWidth)/2, 0, pickerWidth, pickerHeight);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_teamPicker reloadData];
        
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
    });
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
    TeamTeam *team = _teams[indexPath.row];
    
    cell.textLabel.text = team.name;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentTeam = _teams[indexPath.row];
    [Config setTeamID:_currentTeam.teamID];
    
    [self toggleTeamPicker];
    
    [self updateTeam];
}


- (void)updateTeam
{
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
    if ([self.view viewWithTag:1023]) {
        [[self.view viewWithTag:1023] removeFromSuperview];
    } else {
        [self addNewView];
    }
}


-(void)addNewView
{
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth([[UIScreen mainScreen] bounds])-110, 0, 110, 81)];
    [newView setCornerRadius:3];
    newView.backgroundColor = [UIColor colorWithHex:0x555555];
    newView.tag = 1023;
    for (int j=0; j<2; j++) {
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
        newButton.frame = CGRectMake(0, j*(CGRectGetHeight(newView.frame)/2+1), CGRectGetWidth(newView.frame), CGRectGetHeight(newView.frame)/2);
        newButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [newButton setTitle:j==0?@"新建团队动弹":@"新建团队任务" forState:UIControlStateNormal];
        [newButton addTarget:self action:@selector(newAction:) forControlEvents:UIControlEventTouchUpInside];
        newButton.tag = j;
        [newView addSubview:newButton];
        if(j == 0) {
            UIView *separationLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(newButton.frame), CGRectGetWidth(newView.frame), 1)];
            separationLine.backgroundColor = [UIColor blackColor];
            [newView addSubview:separationLine];
        }
    }
    [self.view addSubview:newView];
}

-(void)newAction:(UIButton*)btn
{
    if (btn.tag == 0) {
        [self.navigationController pushViewController:[[TweetEditingVC alloc] initWithTeamID:[Config teamID]] animated:YES];
    } else {
        [self.navigationController pushViewController:[NewTeamIssueViewController new] animated:YES];
    }
    
    [btn.superview removeFromSuperview];
}


@end
