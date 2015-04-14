//
//  TweetsLikeListViewController.m
//  iosapp
//
//  Created by 李萍 on 15/4/3.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TweetsLikeListViewController.h"
#import "OSCUser.h"
#import "TweetLikeUserCell.h"
#import "UserDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kTweetLikeUserCellID = @"TweetLikeUserCell";

@interface TweetsLikeListViewController ()

@end

@implementation TweetsLikeListViewController

- (instancetype)initWithtweetID:(int64_t)tweetID
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?tweetid=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE_LIST, tweetID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCUser class];
    }
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"likeList"] childrenWithTag:@"user"];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    self.navigationItem.title = @"点赞列表";
    
    [super viewDidLoad];
    
    [self.tableView registerClass:[TweetLikeUserCell class] forCellReuseIdentifier:kTweetLikeUserCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row < self.objects.count) {
        OSCUser *likesUser = self.objects[row];
        TweetLikeUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetLikeUserCellID forIndexPath:indexPath];
        
        [cell.portrait loadPortrait:likesUser.portraitURL];
        cell.userNameLabel.text = likesUser.name;
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCUser *likesUser = self.objects[indexPath.row];
        self.label.text = likesUser.name;
        self.label.font = [UIFont systemFontOfSize:16];
        CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        return nameSize.height + 32;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.objects.count) {
        OSCUser *likesUser = self.objects[row];
        UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:likesUser.userID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        [self fetchMore];
    }
}


@end
