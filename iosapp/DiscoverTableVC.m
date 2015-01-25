//
//  DiscoverTableVC.m
//  iosapp
//
//  Created by chenhaoxiang on 11/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "DiscoverTableVC.h"
#import "UIColor+Util.h"
#import "EventsViewController.h"
#import "PersonSearchViewController.h"
#import "ScanViewController.h"
#import "ShakingViewController.h"
#import "SearchViewController.h"
#import "ActivitiesViewController.h"
#import "Config.h"

@interface DiscoverTableVC ()

@end

@implementation DiscoverTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"发现";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushSearchViewController)];
    self.view.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.bounces = NO;
    
    //self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1; break;
        case 1:
            return 2; break;
        case 2:
            return 2; break;
        default:
            return 0; break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"好友圈";
            break;
        case 1:
            cell.textLabel.text = @[@"找人", @"活动"][indexPath.row];
            break;
        case 2:
            cell.textLabel.text = @[@"扫一扫", @"摇一摇"][indexPath.row];
            break;
        default:
            
            break;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            [self.navigationController pushViewController:[EventsViewController new] animated:YES];
            break;
        case 1:
            if (indexPath.row == 0) {
                [self.navigationController pushViewController:[PersonSearchViewController new] animated:YES];
                break;
            } else if (indexPath.row == 1) {
                SwipeableViewController *activitySVC = [[SwipeableViewController alloc] initWithTitle:@"活动"
                                                                                         andSubTitles:@[@"近期活动", @"我的活动"]
                                                                                       andControllers:@[[[ActivitiesViewController alloc] initWithUID:0],
                                                                                                        [[ActivitiesViewController alloc] initWithUID:[Config getOwnID]]]];
                [self.navigationController pushViewController:activitySVC animated:YES];
                break;
            }
        case 2:
            if (indexPath.row == 0) {
                ScanViewController *scanVC = [ScanViewController new];
                UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
                [self.navigationController presentViewController:scanNav animated:NO completion:nil];
                break;
            } else if (indexPath.row == 1) {
                [self.navigationController pushViewController:[ShakingViewController new] animated:YES];
            }
            
        default:
            break;
    }
}


- (void)pushSearchViewController
{
    [self.navigationController pushViewController:[SearchViewController new] animated:YES];
}




@end
