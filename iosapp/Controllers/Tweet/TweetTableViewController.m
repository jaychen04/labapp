//
//  TweetTableViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetTableViewController.h"
#import "NewTweetCell.h"
#import "NewMultipleTweetCell.h"
#import "Config.h"
#import "OSCUser.h"

#import "TweetEditingVC.h"
#import "ImageViewerController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import "UserDetailsViewController.h"
#import "TweetDetailNewTableViewController.h"

#import <UITableView+FDTemplateLayoutCell.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

static NSString * const reuseIdentifier = @"NewTweetCell";
static NSString* const reuseIdentifier_Multiple = @"NewMultipleTweetCell";

@interface TweetTableViewController () <UITextViewDelegate,networkingJsonDataDelegate>

@property (nonatomic, assign) int64_t uid;
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, copy) NSString *nextToken;

@end

@implementation TweetTableViewController

#pragma mark - init method
-(instancetype)initTweetListWithType:(NSInteger)type {
    self = [super init];
    if (self) {
        self.netWorkingDelegate = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@tweets",OSCAPI_V2_PREFIX];
        };
        self.isJsonDataVc = YES;
        
        self.parametersDic = @{@"type":@(1),
                               @"pageToken":@""
                               };
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}

- (instancetype)initWithTweetsType:(NewTweetsType)type
{
    self = [super init];
    if (self) {
        switch (type) {
            case NewTweetsTypeAllTweets:
                _uid = 0; break;
            case NewTweetsTypeHotestTweets:
                _uid = -1; break;
            case NewTweetsTypeOwnTweets:
                _uid = [Config getOwnID];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRefreshHandler:)  name:@"TweetUserUpdate" object:nil];
                if (_uid == 0) {
                    // 显示提示页面
                }
                break;
            default:
                break;
        }
        
        self.needAutoRefresh = type != NewTweetsTypeOwnTweets;
        self.refreshInterval = 3600;
        self.kLastRefreshTime = [NSString stringWithFormat:@"TweetsRefreshInterval-%ld", type];
        
        [self setBlockAndClass];
    }
    
    return self;
}

- (instancetype)initWithUserID:(int64_t)userID
{
    self = [super init];
    if (!self) {return nil;}
    
    _uid = userID;
    [self setBlockAndClass];
    
    return self;
}

- (instancetype)initWithSoftwareID:(int64_t)softwareID
{
    self = [super init];
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?project=%lld&pageIndex=%lu&%@&clientType=android", OSCAPI_PREFIX, OSCAPI_SOFTWARE_TWEET_LIST, softwareID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCTweet class];
    }
    
    return self;
}

- (instancetype)initWithTopic:(NSString *)topic
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _topic = topic;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *URL = [NSString stringWithFormat:@"%@%@?title=%@&pageIndex=%lu&%@&clientType=android", OSCAPI_PREFIX, OSCAPI_TWEET_TOPIC_LIST, topic, (unsigned long)page, OSCAPI_SUFFIX];
            return [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        };
        
        self.objClass = [OSCTweet class];
        
        self.navigationItem.title = topic;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(topicEditing)];
    }
    
    return self;
    
}



- (void)setBlockAndClass
{
    __weak TweetTableViewController *weakSelf = self;
    self.tableWillReload = ^(NSUInteger responseObjectsCount) {
        if (weakSelf.uid == -1) {weakSelf.lastCell.status = LastCellStatusFinished;}
        else {responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);}
    };
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?uid=%lld&pageIndex=%lu&%@&clientType=android", OSCAPI_PREFIX, OSCAPI_TWEETS_LIST, weakSelf.uid, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCTweet class];
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"tweets"] childrenWithTag:@"tweet"];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self.tableView registerClass:[NewTweetCell class] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerClass:[NewMultipleTweetCell class] forCellReuseIdentifier:reuseIdentifier_Multiple];
    self.tableView.estimatedRowHeight = 160;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [NewTweetCell initContetTextView:_textView];
    [self.view addSubview:_textView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- networking Delegate
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh{//yes 下拉 no 上拉
    if (isRefresh) {

    }
    
    NSMutableDictionary* paraMutableDic = self.parametersDic.mutableCopy;
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    [self.manager GET:self.generateUrl()
           parameters:paraMutableDic.copy
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if([responseObject[@"code"]integerValue] == 1) {
//                      _systemDate = responseObject[@"time"];
                      
                      NSDictionary* resultDic = responseObject[@"result"];
                      NSArray* items = resultDic[@"items"];
//                      NSArray* modelArray = [OSCInformation mj_objectArrayWithKeyValuesArray:items];
                      if (isRefresh) {//上拉得到的数据
//                          [self.dataModels removeAllObjects];
                      }
//                      [self.dataModels addObjectsFromArray:modelArray];
                      self.nextToken = resultDic[@"nextPageToken"];
//                      dispatch_async(dispatch_get_main_queue(), ^{
//                          self.lastCell.status = items.count < 20 ? LastCellStatusFinished : LastCellStatusMore;
//                          if (self.tableView.mj_header.isRefreshing) {
//                              [self.tableView.mj_header endRefreshing];
//                          }
//                          [self.tableView reloadData];
//                      });
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
                  
                  [HUD hideAnimated:YES afterDelay:1];
                  
                  self.lastCell.status = LastCellStatusError;
                  if (self.tableView.mj_header.isRefreshing) {
                      [self.tableView.mj_header endRefreshing];
                  }
                  [self.tableView reloadData];
              }
     ];
}



#pragma mark - 处理消息通知

- (void)userRefreshHandler:(NSNotification *)notification
{
    _uid = [Config getOwnID];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.objects.count > 0) {
        return self.objects.count;
    }
    return 0;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (self.objects.count > 0) {
        OSCTweet *tweet = self.objects[indexPath.row];
        
        
        if (!cell.descTextView.delegate) {
            cell.descTextView.delegate = self;
            [cell.descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCellContentText:)]];
        }
        cell.descTextView.tag = indexPath.row;
        
        cell.backgroundColor = [UIColor newCellColor];
        
        [self setBlockForCommentCell:cell];
        cell.tweet = tweet;
        
        if (tweet.hasAnImage) {
            cell.tweetImageView.hidden = NO;
            
            UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:tweet.smallImgURL.absoluteString];
            
            // 有图就加载，无图则下载并reload tableview
            if (!image) {
                [cell.tweetImageView setImage:[UIImage imageNamed:@"loading"]];
                [self downloadThumbnailImageThenReload:tweet];
            } else {
                [cell.tweetImageView setImage:image];
            }
        } else {cell.tweetImageView.hidden = YES;}
        
        cell.userPortrait.tag = indexPath.row;
        cell.nameLabel.tag = indexPath.row;
        cell.tweetImageView.tag = indexPath.row;
        cell.likeCountButton.tag = indexPath.row;
        cell.nameLabel.textColor = [UIColor newTitleColor];
        cell.descTextView.textColor = [UIColor newTitleColor];
        
        [cell.userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetailsView:)]];
        [cell.tweetImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImage:)]];
        [cell.likeCountButton addTarget:self action:@selector(togglePraise:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.contentView.backgroundColor = [UIColor newCellColor];
        cell.backgroundColor = [UIColor themeColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCTweet *tweet = self.objects[indexPath.row];

    TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
    [self.navigationController pushViewController:tweetDetailsBVC animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(copyText:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if (_didScroll) {_didScroll();}
}

- (void)setBlockForCommentCell:(NewTweetCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            
            OSCTweet *tweet = self.objects[indexPath.row];
            
            return tweet.authorID == [Config getOwnID];
        }
        
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCTweet *tweet = self.objects[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"正在删除动弹";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_DELETE]
           parameters:@{
                        @"uid": @([Config getOwnID]),
                        @"tweetid": @(tweet.tweetID)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"动弹删除成功";
                      
                      [self.objects removeObjectAtIndex:indexPath.row];
                      self.allCount--;

                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  } else {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}



#pragma mark - 下载图片

- (void)downloadThumbnailImageThenReload:(OSCTweet*)tweet
{
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:tweet.smallImgURL
                                                        options:SDWebImageDownloaderUseNSURLCache
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                          [[SDImageCache sharedImageCache] storeImage:image forKey:tweet.smallImgURL.absoluteString toDisk:NO];
                                                          
                                                          // 单独刷新某一行会有闪烁，全部reload反而较为顺畅
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              tweet.cellHeight = 0;
                                                              [self.tableView reloadData];
                                                          });
                                                      }];
    
}


#pragma mark - 跳转到用户详情页

- (void)pushUserDetailsView:(UITapGestureRecognizer *)recognizer
{
    OSCTweet *tweet = self.objects[recognizer.view.tag];
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:tweet.authorID];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}

#pragma mark - 编辑话题动弹

- (void)topicEditing
{
    TweetEditingVC *tweetEditingVC = [[TweetEditingVC alloc] initWithTopic:_topic];
    UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
    [self.navigationController presentViewController:tweetEditingNav animated:NO completion:nil];
    
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
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

                      tweet.likeCount--;
                  } else {
                      //点赞

                      tweet.likeCount++;
                  }
                  tweet.isLike = !tweet.isLike;
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
                  
              } else {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}

#pragma mark - UITableViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    [self.navigationController handleURL:URL];
    return NO;
}

#pragma  mark - 转发cell.contentText的tap事件
- (void)onTapCellContentText:(UITapGestureRecognizer*)tap
{
    CGPoint point = [tap locationInView:self.tableView];
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
}

-(void)configurationCellContainImage:(NewTweetCell* )cell
                          dataSource:(OSCTweet* )tweet
                           indexPath:(NSIndexPath* )indexPath
{
    if (!cell.descTextView.delegate) {
        cell.descTextView.delegate = self;
        [cell.descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCellContentText:)]];
    }
    cell.descTextView.tag = indexPath.row;
    
    cell.backgroundColor = [UIColor newCellColor];
    
    [self setBlockForCommentCell:cell];
    cell.tweet = tweet;
    
    if (tweet.hasAnImage) {
        cell.tweetImageView.hidden = NO;
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:tweet.smallImgURL.absoluteString];
        
        // 有图就加载，无图则下载并reload tableview
        if (!image) {
            [cell.tweetImageView setImage:[UIImage imageNamed:@"loading"]];
            [self downloadThumbnailImageThenReload:tweet];
        } else {
            [cell.tweetImageView setImage:image];
        }
    } else {cell.tweetImageView.hidden = YES;}
    
    cell.userPortrait.tag = indexPath.row;
    cell.nameLabel.tag = indexPath.row;
    cell.tweetImageView.tag = indexPath.row;
    cell.likeCountButton.tag = indexPath.row;
    cell.nameLabel.textColor = [UIColor newTitleColor];
    cell.descTextView.textColor = [UIColor newTitleColor];
    
    [cell.userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetailsView:)]];
    [cell.tweetImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImage:)]];
    [cell.likeCountButton addTarget:self action:@selector(togglePraise:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
}

//-(void)configurationCellOnlyText:(NewTweetTextCell* )cell
//                      dataSource:(OSCTweet* )tweet
//                       indexPath:(NSIndexPath* )indexPath
//{
//    if (!cell.descTextView.delegate) {
//        cell.descTextView.delegate = self;
//        [cell.descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCellContentText:)]];
//    }
//    cell.descTextView.tag = indexPath.row;
//    
//    cell.backgroundColor = [UIColor newCellColor];
//    
//    //    [self setBlockForCommentCell:cell];//must code
//    cell.tweet = tweet;
//    
//    cell.userPortrait.tag = indexPath.row;
//    cell.nameLabel.tag = indexPath.row;
//    cell.likeCountButton.tag = indexPath.row;
//    cell.nameLabel.textColor = [UIColor newTitleColor];
//    cell.descTextView.textColor = [UIColor newTitleColor];
//    
//    [cell.userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetailsView:)]];
//    [cell.likeCountButton addTarget:self action:@selector(togglePraise:) forControlEvents:UIControlEventTouchUpInside];
//    
//    cell.contentView.backgroundColor = [UIColor newCellColor];
//    cell.backgroundColor = [UIColor themeColor];
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
//    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
//}

//#pragma mark --- 装配cell内容
//-(void)configurationCellWithTableView:(UITableView* )tableView
//                            indexPath:(NSIndexPath* )indexPath
//                          currentCell:(UITableViewCell* )cell
//{
//    if (self.objects.count > 0) {
//
//        OSCTweet *tweet = self.objects[indexPath.row];
//
//        if (tweet.hasAnImage) {//含图动弹
//            NewTweetCell* tweetCell = (NewTweetCell* )cell;
//            [self configurationCellContainImage:tweetCell dataSource:tweet indexPath:indexPath];
//        }else{//纯文字动态
//            NewTweetTextCell* tweetTextCell = (NewTweetTextCell* )cell;
//            [self configurationCellOnlyText:tweetTextCell dataSource:tweet indexPath:indexPath];
//        }
//    }
//}

/**
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 OSCTweet *tweet = self.objects[indexPath.row];
 if (tweet.hasAnImage) {
 NewTweetCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
 [self configurationCellWithTableView:tableView indexPath:indexPath currentCell:cell];
 return cell;
 }else{
 NewTweetTextCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier_text forIndexPath:indexPath];
 [self configurationCellWithTableView:tableView indexPath:indexPath currentCell:cell];
 return cell;
 }
 }
 */


@end
