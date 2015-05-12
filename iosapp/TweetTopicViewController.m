//
//  TweetTopicViewController.m
//  iosapp
//
//  Created by 李萍 on 15/5/4.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TweetTopicViewController.h"
#import "Config.h"
#import "OSCTweet.h"
#import "TweetCell.h"

#import "TweetDetailsWithBottomBarViewController.h"
#import "UserDetailsViewController.h"
#import "TweetsLikeListViewController.h"
#import "ImageViewerController.h"
#import "OSCUser.h"
#import "TweetEditingVC.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

static NSString * const kTweetTopiccCommentCellID = @"TweetCell";

@interface TweetTopicViewController ()

@property (nonatomic, assign) int64_t uid;
@property (nonatomic, strong) NSString *topicName;

@end

@implementation TweetTopicViewController

- (instancetype)initWithTopic:(NSString *)topic
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _topicName = topic;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *URL = [NSString stringWithFormat:@"%@%@?title=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_TWEET_TOPIC_LIST, topic, (unsigned long)page, OSCAPI_SUFFIX];
            URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            return URL;
        };
        
        self.objClass = [OSCTweet class];
    }
    
    return self;
    
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"tweets"] childrenWithTag:@"tweet"];
}

- (void)viewDidLoad {
    self.needRefreshAnimation = NO;
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"#%@#", [self limitTopicString]];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:kTweetTopiccCommentCellID];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(TopicEditing)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    
    
}

#pragma mark - 限制标题长度
- (NSString *)limitTopicString
{
    if (_topicName.length < 10) {
        return _topicName;
    } else {
        NSString *string = [NSString stringWithFormat:@"%@...", [_topicName substringWithRange:NSMakeRange(0, 5)]];
        return string;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 取消
- (void)cancelButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 编辑
- (void)TopicEditing
{
    TweetEditingVC *tweetEditingVC = [[TweetEditingVC alloc] initWithTopic:_topicName];
    UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
    [self.navigationController presentViewController:tweetEditingNav animated:NO completion:nil];
    
}
#pragma mark - uitableview delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row < self.objects.count) {
        TweetCell *cell = [TweetCell new];
        OSCTweet *tweet = self.objects[row];
        
        [cell setContentWithTweet:tweet];
        
        
        cell.portrait.tag = row; cell.authorLabel.tag = row;
        [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
        
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCTweet *tweet = self.objects[indexPath.row];
        
        self.label.font = [UIFont boldSystemFontOfSize:14];
        [self.label setText:tweet.author];
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;
        
        [self.label setAttributedText:[Utils emojiStringFromRawString:tweet.body]];
        height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;
        
        if (tweet.likeCount) {
            [self.label setAttributedText:tweet.likersString];
            self.label.font = [UIFont systemFontOfSize:12];
            height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height + 6;
        }
        
        if (tweet.hasAnImage) {
#if 0
            UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:tweet.smallImgURL.absoluteString];
            if (!image) {image = [UIImage imageNamed:@"loading"];}
            height += image.size.height + 5;
#else
            height += 86;
#endif
        }
        
        return height + 39;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
   if (row < self.objects.count) {
        OSCTweet *tweet = self.objects[row];
        TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
        [self.navigationController pushViewController:tweetDetailsBVC animated:YES];
    } else {
        [self fetchMore];
    }
}


#pragma mark - scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_didScroll) {_didScroll();}
}


#pragma mark - 下载图片

- (void)downloadImageThenReload:(NSURL *)imageURL
{
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:imageURL
                                                        options:SDWebImageDownloaderUseNSURLCache
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                          [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL.absoluteString toDisk:NO];
                                                          
                                                          // 单独刷新某一行会有闪烁，全部reload反而较为顺畅
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.tableView reloadData];
                                                          });
                                                      }];
}




#pragma mark - 跳转到用户详情页

- (void)pushDetailsView:(UITapGestureRecognizer *)recognizer
{
    OSCTweet *tweet = self.objects[recognizer.view.tag];
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:tweet.authorID];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}


#pragma mark - 加载大图

- (void)loadLargeImage:(UITapGestureRecognizer *)recognizer
{
    OSCTweet *tweet = self.objects[recognizer.view.tag];
    ImageViewerController *imageViewerVC = [[ImageViewerController alloc] initWithImageURL:tweet.bigImgURL];
    
    [self presentViewController:imageViewerVC animated:YES completion:nil];
}


#pragma mark - 点赞功能
- (void)togglePraise:(UIButton *)button
{
    OSCTweet *tweet = self.objects[button.tag];
    
    [self toPraise:tweet];
}

- (void)toPraise:(OSCTweet *)tweet
{
    
    NSString *postUrl;
    if (tweet.isLike) {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_UNLIKE];
    } else {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    [manager POST:postUrl
       parameters:@{
                    @"uid": @([Config getOwnID]),
                    @"tweetid": @(tweet.tweetID),
                    @"ownerOfTweet": @( tweet.authorID)
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
              
              if (errorCode == 1) {
                  if (tweet.isLike) {
                      //取消点赞
                      for (OSCUser *user in tweet.likeList) {
                          if ([user.name isEqualToString:[Config getOwnUserName]]) {
                              [tweet.likeList removeObject:user];
                              break;
                          }
                      }
                      tweet.likeCount--;
                  } else {
                      //点赞
                      OSCUser *user = [OSCUser new];
                      user.userID = [Config getOwnID];
                      user.name = [Config getOwnUserName];
                      user.portraitURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Config getPortrait]]];
                      [tweet.likeList insertObject:user atIndex:0];
                      tweet.likeCount++;
                  }
                  tweet.isLike = !tweet.isLike;
                  tweet.likersString = nil;
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
                  
              } else {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  
                  [HUD hide:YES afterDelay:1];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabelText = error.userInfo[NSLocalizedDescriptionKey];
              
              [HUD hide:YES afterDelay:1];
          }];
}

@end
