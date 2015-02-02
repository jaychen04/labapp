//
//  SideMenuViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/31/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "SideMenuViewController.h"
#import "Utils.h"
#import "SwipeableViewController.h"
#import "PostsViewController.h"
#import "BlogsViewController.h"
#import "SoftwareCatalogVC.h"
#import "SoftwareListVC.h"

#import <RESideMenu.h>

@interface SideMenuViewController ()

@property (nonatomic, strong) UIViewController *reservedViewController;

@end

@implementation SideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [UIView new];
    
    headerView.backgroundColor = [UIColor colorWithHex:0x15A230];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    cell.textLabel.text = @[@"技术问答", @"开源软件", @"博客区", @"注销"][indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            SwipeableViewController *newsSVC = [[SwipeableViewController alloc] initWithTitle:@"技术问答"
                                                                                 andSubTitles:@[@"提问", @"分享", @"综合", @"职业", @"站务"]
                                                                               andControllers:@[
                                                                                                [[PostsViewController alloc] initWithPostsType:PostsTypeQA],
                                                                                                [[PostsViewController alloc] initWithPostsType:PostsTypeShare],
                                                                                                [[PostsViewController alloc] initWithPostsType:PostsTypeSynthesis],
                                                                                                [[PostsViewController alloc] initWithPostsType:PostsTypeCaree],
                                                                                                [[PostsViewController alloc] initWithPostsType:PostsTypeSiteManager]
                                                                                                ]];
            
            [self setMenuContentViewController:newsSVC];
            
            break;
        }
        case 1: {
            SwipeableViewController *softwaresSVC = [[SwipeableViewController alloc] initWithTitle:@"开源软件"
                                                                                      andSubTitles:@[@"分类", @"推荐", @"最新", @"热门", @"国产"]
                                                                                    andControllers:@[
                                                                                                     [[SoftwareCatalogVC alloc] initWithTag:0],
                                                                                                     [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeRecommended],
                                                                                                     [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeNewest],
                                                                                                     [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeHottest],
                                                                                                     [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeCN]
                                                                                                     ]];
            
            [self setMenuContentViewController:softwaresSVC];
            
            break;
        }
        case 2: {
            SwipeableViewController *blogsSVC = [[SwipeableViewController alloc] initWithTitle:@"博客区"
                                                                                  andSubTitles:@[@"最新博客", @"推荐阅读"]
                                                                                andControllers:@[
                                                                                                 [[BlogsViewController alloc] initWithBlogsType:BlogTypeLatest],
                                                                                                 [[BlogsViewController alloc] initWithBlogsType:BlogTypeRecommended]
                                                                                                 ]];
            
            [self setMenuContentViewController:blogsSVC];
            
            break;
        }
        case 3: {
            
        }
        default:
            break;
    }
}


- (void)setMenuContentViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self action:@selector(backToHomePage)];
    
    _reservedViewController = self.sideMenuViewController.contentViewController;
    [self.sideMenuViewController setContentViewController:navigationController];
    [self.sideMenuViewController hideMenuViewController];
}


- (void)backToHomePage
{
    [self.sideMenuViewController setContentViewController:_reservedViewController animated:NO];
    [self.sideMenuViewController hideMenuViewController];
}


@end
