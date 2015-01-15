//
//  TweetDetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "OSCTweet.h"
#import "TweetCell.h"
#import "UserDetailsViewController.h"
#import "ImageViewerController.h"
#import "TweetDetailsCell.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

@interface TweetDetailsViewController () <UIWebViewDelegate>

@property (nonatomic, strong) OSCTweet *tweet;

@property (nonatomic, assign) BOOL isLoadingFinished;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, copy) NSString *HTML;

@end

@implementation TweetDetailsViewController

- (instancetype)initWithTweet:(OSCTweet *)tweet
{
    self = [super initWithCommentsType:CommentsTypeTweet andID:tweet.tweetID];
    
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _tweet = tweet;
        
        __weak TweetDetailsViewController *weakSelf = self;
        self.otherSectionCell = ^UITableViewCell * (NSIndexPath *indexPath) {
            TweetDetailsCell *cell = [TweetDetailsCell new];
            cell.webView.delegate = weakSelf;
            
            [cell.portrait loadPortrait:tweet.portraitURL];
            [cell.authorLabel setText:tweet.author];
            [cell.timeLabel setText:[Utils intervalSinceNow:tweet.pubDate]];
            [cell.appclientLabel setText:[Utils getAppclient:tweet.appclient]];
            [cell.webView loadHTMLString:weakSelf.HTML baseURL:nil];
            
            return cell;
        };
        
        self.heightForOtherSectionCell = ^CGFloat (NSIndexPath *indexPath) {
            return weakSelf.webViewHeight + 60;
        };
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_TWEET_DETAIL, _tweet.tweetID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *tweetDetails = [responseObject.rootElement firstChildWithTag:@"tweet"];
             NSString *text = [[tweetDetails firstChildWithTag:@"body"] stringValue];
             
             NSString *imageURL = [[tweetDetails firstChildWithTag:@"imgBig"] stringValue];
             
             
             _HTML = [NSString stringWithFormat:@"<font size=\"3\"><strong>%@</strong></font>\
                                                  <br/><a href='%@'><img style='max-width:300px;' src='%@'/></a>",
                                                text,  imageURL, imageURL];
             _tweet.commentCount = [[[tweetDetails firstChildWithTag:@"commentCount"] numberValue] intValue];
             
             [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                   withRowAnimation:UITableViewRowAnimationNone];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"wrong");
         }];
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
        NSString *title;
        if (self.tweet.commentCount) {
            title = [NSString stringWithFormat:@"%d 条评论", self.allCount];
        } else {
            title = @"没有评论";
        }
        return title;
    }
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_isLoadingFinished) {
        webView.hidden = NO;
        return;
    }
    
    _webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    
    //设置为已经加载完成
    _isLoadingFinished = YES;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [Utils analysis:[request.URL absoluteString] andNavController:self.navigationController];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}




@end
