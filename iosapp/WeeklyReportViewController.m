//
//  WeeklyReportViewController.m
//  iosapp
//
//  Created by AeternChan on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportViewController.h"
#import "Utils.h"
#import "WeeklyReportTableViewController.h"
#import "WeeklyReportTitleBar.h"
#import "WeeklyReportContentViewController.h"

@interface WeeklyReportViewController ()

@property (nonatomic, assign) int teamID;
@property (nonatomic, strong) WeeklyReportTitleBar *titleBar;
@property (nonatomic, strong) WeeklyReportContentViewController *weeklyReportHVC;

@end

@implementation WeeklyReportViewController

- (instancetype)initWithTeamID:(int)teamID
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.title = @"团队周报";
        
        _teamID = teamID;
        
        NSDate *date = [NSDate date];
        NSDateComponents *dateComps = [Utils getDateComponentsFromDate:date];
        
        CGFloat barHeight = 36;
        _titleBar = [[WeeklyReportTitleBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, barHeight) andWeek:dateComps.weekOfYear - 1];
        
        
        _weeklyReportHVC = [[WeeklyReportContentViewController alloc] initWithTeamID:_teamID];
        _weeklyReportHVC.view.frame = CGRectMake(0, barHeight, self.view.bounds.size.width, self.view.bounds.size.height - barHeight - 64);
        
        __weak typeof(self) weakSelf = self;
        _weeklyReportHVC.changeIndex = ^ (NSUInteger index) {
            WeeklyReportTableViewController *vc = weakSelf.weeklyReportHVC.controllers[index];
            [weakSelf.titleBar updateWeek:vc.week];
        };
        
        
        [self addChildViewController:_weeklyReportHVC];
        [self.view addSubview:_weeklyReportHVC.view];
        [self.view addSubview:_titleBar];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
