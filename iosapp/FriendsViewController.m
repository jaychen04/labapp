//
//  FriendsViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "FriendsViewController.h"
#import "OSCUser.h"
#import "FriendCell.h"
#import "UserDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kFriendCellID = @"FriendCell";

@interface FriendsViewController ()

@property (nonatomic, assign) int64_t uid;

@end

@implementation FriendsViewController

- (instancetype)initWithUserID:(int64_t)userID andFriendsRelation:(int)relation
{
    self = [super init];
    if (!self) {return nil;}
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?uid=%lld&relation=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_FRIENDS_LIST, userID, relation, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCUser class];
    
    return self;
}



- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"friends"] childrenWithTag:@"friend"];
}





#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[FriendCell class] forCellReuseIdentifier:kFriendCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source

// 图片的高度计算方法参考 http://blog.cocoabit.com/blog/2013/10/31/guan-yu-uitableview-zhong-cell-zi-gua-ying-gao-du-de-wen-ti/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row < self.objects.count) {
        OSCUser *friend = self.objects[row];
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellID forIndexPath:indexPath];
        
        [cell.portrait sd_setImageWithURL:friend.portraitURL placeholderImage:nil];
        cell.nameLabel.text = friend.name;
        cell.expertiseLabel.text = friend.expertise;
        
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
        
        self.label.text = friend.expertise;
        self.label.font = [UIFont systemFontOfSize:12];
        CGSize expertiseSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        return nameSize.height + expertiseSize.height + 21;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.objects.count) {
        OSCUser *friend = self.objects[row];
        UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:friend.userID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        [self fetchMore];
    }
}




@end
