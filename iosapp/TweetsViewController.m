//
//  TweetsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TweetsViewController.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import "OSCTweet.h"
#import "TweetCell.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString *kTweetCellID = @"TweetCell";



#pragma mark -

@interface TweetsViewController ()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL DidFinishLoad;

@property (nonatomic, strong) UITextView *textView;


@end

#pragma mark -



@implementation TweetsViewController

/*! Primary view has been loaded for this view controller
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"最新动弹";
    
    self.tweets = [NSMutableArray new];
    //NSLog(@"self.tweets的应用计数:%ld", CFGetRetainCount((__bridge CFTypeRef)self.tweets));
    //NSLog(@"self.tweets的应用计数:%ld", CFGetRetainCount((__bridge CFTypeRef)_tweets));
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:kTweetCellID];
    
    
    self.textView = [UITextView new];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.tweets.count > 0 || self.DidFinishLoad) {
        return;
    }
    
    [self loadTweetOnPage:1 refresh:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetCellID forIndexPath:indexPath];
    OSCTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    
    [cell.portrait sd_setImageWithURL:tweet.portraitURL placeholderImage:nil options:0]; //options:SDWebImageRefreshCached
    [cell.portrait setCornerRadius:5.0];
    
    [cell.authorLabel setText:tweet.author];
    [cell.timeLabel setText:[Utils intervalSinceNow:tweet.pubDate]];
    [cell.appclientLabel setText:[Utils getAppclient:tweet.appclient]];
    [cell.commentCount setText:[NSString stringWithFormat:@"评论：%d", tweet.commentCount]];
    
    [cell.contentText setText:tweet.body];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.tweets.count) {
        OSCTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
        [self.textView setText:tweet.body];
        
        CGSize size = [self.textView sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        
        return size.height + 64;
    } else {
        return 60;
    }
}


#pragma mark - 加载动弹

- (void)loadTweetOnPage:(NSUInteger)page refresh:(BOOL)refresh
{
#if 0
    if (![Tools isNetworkExist]) {
        if (refresh) {
            [self.refreshControl endRefreshing];
        } else {
            _isLoading = NO;
            if (_isFinishedLoad) {
                [_lastCell finishedLoad];
            } else {
                [_lastCell normal];
            }
        }
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.parentViewController.view];
        return;
    }
#endif
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:@"http://www.oschina.net/action/api/tweet_list?uid=0&pageIndex=0&pageSize=20"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             NSArray *tweetsXML = [[responseDocument.rootElement firstChildWithTag:@"tweets"] childrenWithTag:@"tweet"];
             
             for (ONOXMLElement *tweetXML in tweetsXML) {
                 OSCTweet *tweet = [[OSCTweet alloc] initWithXML:tweetXML];
                 [self.tweets addObject:tweet];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
                 //_isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
             });
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"网络异常，错误码：%ld", (long)error.code);
         }
     ];
}




@end
