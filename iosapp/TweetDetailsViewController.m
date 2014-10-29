//
//  TweetDetailsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "OSCTweet.h"
#import "TweetCell.h"

@interface TweetDetailsViewController ()

@property (nonatomic, strong) OSCTweet *tweet;

@end

@implementation TweetDetailsViewController

- (instancetype)initWithTweet:(OSCTweet *)tweet
{
    self = [super initWithCommentsType:CommentsTypeTweet andID:tweet.tweetID];
    
    if (self) {
        self.tweet = tweet;
        
        __weak TweetDetailsViewController *weakSelf = self;
        self.otherSectionCell = ^(NSIndexPath *indexPath) {
            TweetCell *cell = [TweetCell new];
            
            [cell setContentWithTweet:tweet];
            
            return cell;
        };
        
        self.heightForOtherSectionCell = ^(NSIndexPath *indexPath) {
            [weakSelf.label setText:weakSelf.tweet.body];
            
            CGSize size = [weakSelf.label sizeThatFits:CGSizeMake(weakSelf.tableView.frame.size.width - 16, MAXFLOAT)];
            
            return size.height + 65;
        };
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0? 0 : 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%d条评论", self.tweet.commentCount];
    }
}





@end
