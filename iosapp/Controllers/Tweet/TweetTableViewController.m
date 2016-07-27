//
//  TweetTableViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetTableViewController.h"
#import "OSCTweetItem.h"
#import "NewTweetCell.h"
#import "NewMultipleTweetCell.h"
#import "OSCPhotoGroupView.h"
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
#import <MJExtension.h>

static NSString* const reuseIdentifier = @"NewTweetCell";
static NSString* const reuseIdentifier_Multiple = @"NewMultipleTweetCell";

@interface TweetTableViewController () <UITextViewDelegate,networkingJsonDataDelegate,NewMultipleTweetCellDelegate>

@property (nonatomic,strong) NSMutableArray* dataModels;
@property (nonatomic, assign) int64_t uid;
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, copy) NSString *nextToken;

@end

@implementation TweetTableViewController

#pragma mark - init method
-(instancetype)initTweetListWithType:(NewTweetsType)type {
    self = [super init];
    if (self) {
        NSDictionary *para;
        switch (type) {
            case NewTweetsTypeAllTweets:
                para = @{
                         @"type":@(1),
                         @"pageToken":@""
                         };
                break;
                
            case NewTweetsTypeHotestTweets:
                para = @{
                         @"type":@(2),
                         @"pageToken":@""
                         };
                break;
                
            case NewTweetsTypeOwnTweets:
                para = @{
                         @"authorId":@([Config getOwnID]),
                         @"pageToken":@""
                         };
                break;
                
        }
        self.parametersDic = para;
        self.netWorkingDelegate = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@tweets",OSCAPI_V2_PREFIX];
        };
        self.isJsonDataVc = YES;
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
        
        self.objClass = [OSCTweetItem class];
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
        
        self.objClass = [OSCTweetItem class];
        
        self.navigationItem.title = topic;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(topicEditing)];
    }
    return self;
}



- (void)setBlockAndClass {
    __weak TweetTableViewController *weakSelf = self;
    self.tableWillReload = ^(NSUInteger responseObjectsCount) {
        if (weakSelf.uid == -1) {weakSelf.lastCell.status = LastCellStatusFinished;}
        else {responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);}
    };
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?uid=%lld&pageIndex=%lu&%@&clientType=android", OSCAPI_PREFIX, OSCAPI_TWEETS_LIST, weakSelf.uid, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCTweetItem class];
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
    
    NSMutableDictionary* paraMutableDic = self.parametersDic.mutableCopy;
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    [self.manager GET:self.generateUrl()
           parameters:paraMutableDic.copy
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  if([responseObject[@"code"]integerValue] == 1) {
                      NSDictionary* resultDic = responseObject[@"result"];
                      NSArray* items = resultDic[@"items"];
                      NSArray* modelArray = [OSCTweetItem mj_objectArrayWithKeyValuesArray:items];
                      if (isRefresh) {//下拉得到的数据
                          [self.dataModels removeAllObjects];
                      }
                      [self.dataModels addObjectsFromArray:modelArray];
                      self.objects = self.dataModels;
                      self.nextToken = resultDic[@"nextPageToken"];
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          self.lastCell.status = items.count < 1 ? LastCellStatusFinished : LastCellStatusMore;
                          if (self.tableView.mj_header.isRefreshing) {
                              [self.tableView.mj_header endRefreshing];
                          }
                          [self.tableView reloadData];
                      });
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  //                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
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
    if (self.dataModels.count > 0) {
        return self.dataModels.count;
    }
    return 0;
}
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCTweetItem* model = self.dataModels[indexPath.row];
    if (model.images.count == 0) {
        if (model.content.length > 200) {
            return 200;
        }else{
            return 150;
        }
    }else if (model.images.count == 1){
        return 250;
    }else{
        return 300;
    }
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCTweetItem* model = self.dataModels[indexPath.row];
    
    if (model.images.count < 2) {
        NewTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.tweet = model;

        if (!cell.descTextView.delegate) {
            cell.descTextView.delegate = self;
            [cell.descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCellContentText:)]];
        }
        [self setBlockForCommentCell:cell];
        
        if (model.images.count > 0) {
            OSCTweetImages* imageData = [model.images lastObject];
            cell.tweetImageView.hidden = NO;
            
            UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageData.thumb];
            if (!image) {
                [cell.tweetImageView setImage:[UIImage imageNamed:@"loading"]];
                [self downloadThumbnailImageThenReload:imageData.thumb];
            } else {
                [cell.tweetImageView setImage:image];
            }
            
        } else {
            cell.tweetImageView.hidden = YES;
        }
        
        cell.userPortrait.tag = indexPath.row;
        cell.descTextView.tag = indexPath.row;
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
        
        return cell;
    }else{
        NewMultipleTweetCell* cell = [NewMultipleTweetCell returnReuseMultipeTweetCellWithTableView:tableView identifier:reuseIdentifier_Multiple indexPath:indexPath];
        cell.delegate = self;
        cell.tweetItem = model;
        [self setBlockForCommentMultipleCell:cell];
        
        if (!cell.descTextView.delegate) {
            cell.descTextView.delegate = self;
            [cell.descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCellContentText:)]];
        }
        cell.likeCountButton.tag = indexPath.row;
        [cell.likeCountButton addTarget:self action:@selector(togglePraise:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.contentView.backgroundColor = [UIColor newCellColor];
        cell.backgroundColor = [UIColor themeColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCTweetItem *tweet = self.dataModels[indexPath.row];
    
    TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.id];
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

#pragma mark - NewMultipleTweetCellDelegate
-(void)userPortraitDidClick:(NewMultipleTweetCell *)multipleTweetCell
                tapGestures:(UITapGestureRecognizer *)tap
{
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:multipleTweetCell.tweetItem.author.id];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}

-(void)assemblyMultipleTweetCellDidFinsh:(NewMultipleTweetCell *)multipleTweetCell
{
    [self.tableView reloadData];
}
-(void)loadLargeImageDidFinsh:(NewMultipleTweetCell *)multipleTweetCell
               photoGroupView:(OSCPhotoGroupView *)groupView
                     fromView:(UIImageView *)fromView
{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:nil];
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
            OSCTweetItem *tweet = self.dataModels[indexPath.row];
            return tweet.author.id == [Config getOwnID];
        }
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCTweetItem *tweet = self.dataModels[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"正在删除动弹";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_DELETE]
           parameters:@{
                        @"sourceId": @(tweet.id),
                        }
              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                  if ([responseObject[@"code"] floatValue] == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"动弹删除成功";
                      
                      [self.dataModels removeObjectAtIndex:indexPath.row];
                      self.allCount--;
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  }else{
                      HUD.label.text = @"网络错误";
                  }
                  [HUD hideAnimated:YES afterDelay:1];
                  
              }
              failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}

- (void)setBlockForCommentMultipleCell:(NewMultipleTweetCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            OSCTweetItem *tweet = self.dataModels[indexPath.row];
            return tweet.author.id == [Config getOwnID];
        }
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCTweetItem *tweet = self.dataModels[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"正在删除动弹";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_DELETE]
           parameters:@{
                        @"sourceId": @(tweet.id),
                        }
              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                  if ([responseObject[@"code"] floatValue] == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"动弹删除成功";
                      
                      [self.dataModels removeObjectAtIndex:indexPath.row];
                      self.allCount--;
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  }else{
                      HUD.label.text = @"网络错误";
                  }
                  [HUD hideAnimated:YES afterDelay:1];
                  
              }
              failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}


#pragma mark - 下载图片

- (void)downloadThumbnailImageThenReload:(NSString*)urlString
{
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:urlString]
                                                        options:SDWebImageDownloaderUseNSURLCache
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                          [[SDImageCache sharedImageCache] storeImage:image forKey:urlString toDisk:NO];
                                                          
                                                          // 单独刷新某一行会有闪烁，全部reload反而较为顺畅
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.tableView reloadData];
                                                          });
                                                      }];
    
}


#pragma mark - 跳转到用户详情页

- (void)pushUserDetailsView:(UITapGestureRecognizer *)recognizer
{
    OSCTweetItem *tweet = self.objects[recognizer.view.tag];
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:tweet.author.id];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}

#pragma mark - 编辑话题动弹

- (void)topicEditing {
    TweetEditingVC *tweetEditingVC = [[TweetEditingVC alloc] initWithTopic:_topic];
    UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
    [self.navigationController presentViewController:tweetEditingNav animated:NO completion:nil];
    
}


#pragma mark - 加载大图

- (void)loadLargeImage:(UITapGestureRecognizer *)recognizer {
    UIImageView* fromView = (UIImageView* )recognizer.view;
    OSCTweetItem *tweet = self.objects[recognizer.view.tag];
    OSCTweetImages* tweetItem = [tweet.images lastObject];
    
    OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
    currentPhotoItem.largeImageURL = [NSURL URLWithString:tweetItem.href];
    currentPhotoItem.thumbView = fromView;
    currentPhotoItem.largeImageSize = [UIScreen mainScreen].bounds.size;
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
//    [photoGroup presentFromImageView:fromView toContainer:keyWindow animated:YES completion:nil];
    [photoGroup presentFromImageView:fromView toContainer:self.tabBarController.view animated:YES completion:nil];

    
    //    __weak typeof(self) weakSelf = self;
    //    [photoGroup dismissAnimated:YES completion:^{
    //        [weakSelf.tableView reloadData];
    //    }];
    //    [photoGroup presentFromImageView:fromView toContainer:keyWindow animated:YES completion:^{
    //        [photoGroup dismissAnimated:YES completion:nil];
    //    }];
}

#pragma mark - 点赞功能
- (void)togglePraise:(UIButton *)button
{
    OSCTweetItem *tweet = self.dataModels[button.tag];
    [self toPraise:tweet];
}
#pragma mark --点赞（新接口)
- (void)toPraise:(OSCTweetItem *)tweet {
    if (tweet.id == 0) {
        return;
    }
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_LIKE_REVERSE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:postUrl
       parameters:@{@"sourceId":@(tweet.id)}
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              
              if([responseObject[@"code"]integerValue] == 1) {
                  tweet.liked = !tweet.liked;
                  NSDictionary* resultDic = responseObject[@"result"];
                  tweet.likeCount = [resultDic[@"likeCount"] integerValue];
              }else {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = [NSString stringWithFormat:@"%@", responseObject[@"message"]?:@"未知错误"];
                  [HUD hideAnimated:YES afterDelay:1];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.tableView reloadData];
              });
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.label.text = @"网络错误";
              [HUD hideAnimated:YES afterDelay:1];
          }
     ];
}

/*
 - (void)toPraise:(OSCTweetItem *)tweet
 {
 
 NSString *postUrl;
 if (tweet.liked) {
 postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_UNLIKE];
 } else {
 postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE];
 }
 
 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
 
 [manager POST:postUrl
 parameters:@{
 @"uid": @([Config getOwnID]),
 @"tweetid": @(tweet.id),
 @"ownerOfTweet": @( tweet.author.id)
 }
 success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
 ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
 int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
 NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
 
 if (errorCode == 1) {
 if (tweet.liked) {
 //取消点赞
 
 tweet.likeCount--;
 } else {
 //点赞
 
 tweet.likeCount++;
 }
 tweet.liked = !tweet.liked;
 
 dispatch_async(dispatch_get_main_queue(), ^{
 [self.tableView reloadData];
 });
 
 } else {
 MBProgressHUD *HUD = [Utils createHUD];
 HUD.mode = MBProgressHUDModeCustomView;
 
 //                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
 HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
 
 [HUD hideAnimated:YES afterDelay:1];
 }
 
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 MBProgressHUD *HUD = [Utils createHUD];
 HUD.mode = MBProgressHUDModeCustomView;
 
 //              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
 HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
 
 [HUD hideAnimated:YES afterDelay:1];
 }];
 }
 */
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

- (NSMutableArray *)dataModels {
    if(_dataModels == nil) {
        _dataModels = [[NSMutableArray alloc] init];
    }
    return _dataModels;
}

@end
