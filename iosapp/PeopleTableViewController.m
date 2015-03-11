//
//  PeopleTableViewController.m
//  iosapp
//
//  Created by ChanAetern on 1/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "PersonCell.h"
#import "OSCUser.h"
#import "UserDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kPersonCellID = @"PersonCell";

@implementation PeopleTableViewController

- (instancetype)init
{
    self = [super init];
    if (!self) {return nil;}
    
    __weak PeopleTableViewController *weakSelf = self;
    self.generateURL = ^NSString * (NSUInteger page) {
        NSString *userName = [weakSelf.queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"%@%@?name=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_SEARCH_USERS, userName, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCUser class];
    
    return self;
}



- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"users"] childrenWithTag:@"user"];
}





#pragma mark - life cycle

- (void)viewDidLoad {
    self.needRefreshAnimation = NO;
    [super viewDidLoad];
    
    [self.tableView registerClass:[PersonCell class] forCellReuseIdentifier:kPersonCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row < self.objects.count) {
        OSCUser *user = self.objects[row];
        PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:kPersonCellID forIndexPath:indexPath];
        
        [cell.portrait loadPortrait:user.portraitURL];
        cell.nameLabel.text = user.name;
        cell.infoLabel.text = user.location;
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCUser *friend = self.objects[indexPath.row];
        self.label.text = friend.name;
        self.label.font = [UIFont systemFontOfSize:16];
        CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        self.label.text = friend.location;
        self.label.font = [UIFont systemFontOfSize:12];
        CGSize infoLabelSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        return nameSize.height + infoLabelSize.height + 21;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.objects.count) {
        OSCUser *user = self.objects[row];
        UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:user.userID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        [self fetchMore];
    }
}

@end
