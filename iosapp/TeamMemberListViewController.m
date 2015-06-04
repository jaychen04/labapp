//
//  TeamMemberListViewController.m
//  iosapp
//
//  Created by AeternChan on 6/2/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamMemberListViewController.h"
#import "Utils.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamMember.h"
#import "TweetEditingVC.h"

static NSString * const kReuseID = @"reuseID";

@interface TeamMemberListViewController ()

@end

@implementation TeamMemberListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d", OSCAPI_PREFIX, TEAM_MEMBER_LIST, [Config teamID]];
        };
        
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            weakSelf.lastCell.status = LastCellStatusFinished;
        };
        
        self.objClass = [TeamMember class];
    }
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"members"] childrenWithTag:@"member"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor themeColor];
    
    TeamMember *member = self.objects[indexPath.row];
    
    [cell.imageView setCornerRadius:5.0];
    [cell.imageView loadPortrait:member.portraitURL];
    cell.textLabel.text = member.name;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TeamMember *member = self.objects[indexPath.row];
    
    TweetEditingVC *vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    [vc insertString:member.name andSelect:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
