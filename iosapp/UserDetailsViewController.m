//
//  UserDetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "OSCUser.h"
#import "Utils.h"
#import "Config.h"
#import "BlogsViewController.h"
#import "SwipeableViewController.h"
#import "FriendsViewController.h"
#import "OSCEvent.h"
#import "EventCell.h"
#import "UserHeaderCell.h"
#import "UserOperationCell.h"

#import <Ono.h>

@interface UserDetailsViewController ()

@property (nonatomic, strong) OSCUser *user;

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation UserDetailsViewController


#pragma mark - init method

- (instancetype)initWithUserID:(int64_t)userID
{
    self = [super initWithUserID:userID];
    self.hidesBottomBarWhenPushed = YES;
    if (!self) {return self;}
    
    __block UserDetailsViewController *weakSelf = self;
    self.parseExtraInfo = ^(ONOXMLDocument *XML) {
        ONOXMLElement *userXML = [XML.rootElement firstChildWithTag:@"user"];
        weakSelf.user = [[OSCUser alloc] initWithXML:userXML];
    };
    
    return self;
}

- (instancetype)initWithUserName:(NSString *)userName
{
    self = [super initWithUserName:userName];
    self.hidesBottomBarWhenPushed = YES;
    if (!self) {return self;}
    
    __block UserDetailsViewController *weakSelf = self;
    self.parseExtraInfo = ^(ONOXMLDocument *XML) {
        ONOXMLElement *userXML = [XML.rootElement firstChildWithTag:@"user"];
        weakSelf.user = [[OSCUser alloc] initWithXML:userXML];
    };
    
    return self;
}



#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"用户中心";
    self.tableView.bounces = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0? 2 : self.objects.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 158;
        } else {
            return 105;
        }
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UserHeaderCell *cell = [UserHeaderCell new];
            
            [cell setContentWithUser:_user];
            
            [cell.followsButton addTarget:self action:@selector(pushFriendsSVC) forControlEvents:UIControlEventTouchUpInside];
            [cell.fansButton addTarget:self action:@selector(pushFriendsSVC) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        } else {
            UserOperationCell *cell = [UserOperationCell new];
            if (_user) {
                cell.loginTimeLabel.text = [NSString stringWithFormat:@"上次登录：%@", [Utils intervalSinceNow:_user.latestOnlineTime]];
                [cell setFollowButtonByRelationship:_user.relationship];
            }
            
            return cell;
        }
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}




#pragma mark - Layout

- (void)pushFriendsSVC
{
    SwipeableViewController *friendsSVC = [[SwipeableViewController alloc] initWithTitle:@"关注/粉丝"
                                                                            andSubTitles:@[@"关注", @"粉丝"]
                                                                          andControllers:@[
                                                                                           [[FriendsViewController alloc] initWithUserID:_user.userID andFriendsRelation:1],
                                                                                           [[FriendsViewController alloc] initWithUserID:_user.userID andFriendsRelation:0]
                                                                                           ]];
    friendsSVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:friendsSVC animated:YES];
}



@end
