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
#import "TeamPickerViewController.h"


@interface TeamCenter ()

@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) UIPopoverController *teamPicker;
@property (nonatomic, strong) UITableView *teamTableView;

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
    
    //if (self) {_teams = teams;}
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if 0
    UIButton *dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropdownButton setTitle:((TeamTeam *)_teams[0]).name forState:UIControlStateNormal];
    [dropdownButton addTarget:self action:@selector(navButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dropdownButton.frame = CGRectMake(0, 0, 44, 32);
    self.navigationItem.titleView = dropdownButton;
    
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:[[TeamPickerViewController alloc] initWithTeams:_teams]];
    self.preferredContentSize = CGSizeMake(150, 25 * _teams.count);
    
    
    [self.view addSubview:_teamTableView];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navButtonTapped
{
    BOOL toggle = (_teamTableView.frame.origin.y == 64) ? YES : NO;
    [self toggleDropdownView:toggle animated:YES];
}


- (void)toggleDropdownView:(BOOL)toggle animated:(BOOL)animated
{
    CGRect destination = _teamTableView.frame;
    
    destination.origin.y = (toggle) ? -destination.size.height+64 : 64;
    NSTimeInterval duration = (animated) ? 0.4 : 0;
    [UIView animateWithDuration:duration animations:^{
        _teamTableView.frame = destination;

    }];
    [_teamTableView reloadData];
}



@end
