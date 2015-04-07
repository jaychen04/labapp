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
#import "UserDetailsViewController.h"
#import "Config.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

@interface TweetDetailsViewController () <UIWebViewDelegate>

@property (nonatomic, readwrite, assign) int64_t objectAuthorID;

@property (nonatomic, strong) OSCTweet *tweet;
@property (nonatomic, assign) int64_t tweetID;

@property (nonatomic, assign) BOOL isLoadingFinished;
@property (nonatomic, assign) CGFloat webViewHeight;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation TweetDetailsViewController

- (instancetype)initWithTweetID:(int64_t)tweetID
{
    self = [super initWithCommentType:CommentTypeTweet andObjectID:tweetID];
    
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _tweetID = tweetID;
        
        __weak TweetDetailsViewController *weakSelf = self;
        self.otherSectionCell = ^UITableViewCell * (NSIndexPath *indexPath) {
            TweetDetailsCell *cell = [TweetDetailsCell new];
            
            if (weakSelf.tweet) {
                [cell.portrait loadPortrait:weakSelf.tweet.portraitURL];
                [cell.authorLabel setText:weakSelf.tweet.author];
                
                [cell.portrait    addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(pushUserDetails)]];
//                [cell.authorLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(pushUserDetails)]];
                [cell.likeButton addTarget:weakSelf action:@selector(togglePraise) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.timeLabel setAttributedText:weakSelf.tweet.attributedTimes];
                if (weakSelf.tweet.isLike) {
                    [cell.likeButton setImage:[UIImage imageNamed:@"ic_liked"] forState:UIControlStateNormal];
                } else {
                    [cell.likeButton setImage:[UIImage imageNamed:@"ic_unlike"] forState:UIControlStateNormal];
                }
                [cell.appclientLabel setAttributedText:[Utils getAppclient:weakSelf.tweet.appclient]];
                cell.webView.delegate = weakSelf;
                [cell.webView loadHTMLString:weakSelf.tweet.body baseURL:nil];
            }
            
            return cell;
        };
        
        self.heightForOtherSectionCell = ^CGFloat (NSIndexPath *indexPath) {
            return weakSelf.webViewHeight + 60;
        };
    }
    
    return self;
}


- (void)viewDidLoad {
    self.needRefreshAnimation = NO;
    [super viewDidLoad];
    
    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    _HUD.dimBackground = YES;
    
    [self getTweetDetails];
}

- (void)getTweetDetails
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_TWEET_DETAIL, _tweetID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *tweetDetailsXML = [responseObject.rootElement firstChildWithTag:@"tweet"];
             
             _tweet = [[OSCTweet alloc] initWithXML:tweetDetailsXML];
             self.objectAuthorID = _tweet.authorID;
             _tweet.body = [NSString stringWithFormat:@"<style>a{color:#087221; text-decoration:none;}</style>\
                            <font size=\"3\"><strong>%@</strong></font>\
                            <br/>",
                            _tweet.body];
             
             if (_tweet.hasAnImage) {
                 _tweet.body = [NSString stringWithFormat:@"%@<a href='%@'>\
                                <img style='max-width:300px;\
                                margin-top:10px;\
                                margin-bottom:15px'\
                                src='%@'/>\
                                </a>", _tweet.body, _tweet.bigImgURL, _tweet.bigImgURL];
             }
             
             _tweet.body = [NSString stringWithFormat:@"%@%@",
                            _tweet.body, _tweet.likersDetailString];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_HUD hide:YES];
         }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hide:YES];
    [super viewWillDisappear:animated];
}





#pragma mark - tableView

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
        if (_tweet.commentCount) {
            title = [NSString stringWithFormat:@"%d 条评论", self.allCount];
        } else {
            title = @"没有评论";
        }
        return title;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return YES;
}


#pragma mark - 头像点击事件处理

- (void)pushUserDetails
{
    [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithUserID:_tweet.authorID] animated:YES];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_isLoadingFinished) {
        [_HUD hide:YES];
        return;
    }
    
    _webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        //设置为已经加载完成
        _isLoadingFinished = YES;
    });
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [Utils analysis:[request.URL absoluteString] andNavController:self.navigationController];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

#pragma mark - 点赞功能
- (void)togglePraise
{
    [self toPraise:_tweet];
}

- (void)toPraise:(OSCTweet *)tweet
{
    MBProgressHUD *HUD = [Utils createHUD];
    NSString *postUrl;
    if (tweet.isLike) {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_UNLIKE];
    } else {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE];
    }
    tweet.isLike = !tweet.isLike;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager POST:postUrl
       parameters:@{
                    @"uid": @([Config getOwnID]),
                    @"tweetid": @(tweet.tweetID),
                    @"ownerOfTweet": @(tweet.authorID)
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  if (tweet.isLike) {
                      HUD.labelText = @"点赞成功";
                  } else {
                      HUD.labelText = @"取消点赞成功";
                  }
                  [self getTweetDetails];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
              } else {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = error.userInfo[NSLocalizedDescriptionKey];
              
              [HUD hide:YES afterDelay:1];
          }];
}




@end
