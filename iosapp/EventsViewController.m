//
//  EventsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/29/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EventsViewController.h"
#import "OSCEvent.h"
#import "OSCNews.h"
#import "OSCTweet.h"
#import "OSCBlog.h"
#import "OSCPost.h"
#import "EventCell.h"
#import "Config.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TweetDetailsWithBottomBarViewController.h"
#import "DetailsViewController.h"

static NSString * const EventCellID = @"EventCell";

@interface EventsViewController ()

@end

@implementation EventsViewController

#pragma mark - 个人中心动态

- (instancetype)init
{
    return [self initWithCatalog:1];
}

- (instancetype)initWithCatalog:(int)catalog
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.objClass = [OSCEvent class];
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&pageSize=20&uid=%lld", OSCAPI_PREFIX, OSCAPI_ACTIVE_LIST, catalog, (unsigned long)page, [Config getOwnID]];
        };
    }
    
    return self;
}


#pragma mark - 用户动态

- (instancetype)initWithUserID:(int64_t)userID
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.objClass = [OSCEvent class];
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&hisuid=%lld&pageIndex=%lu&pageSize=20", OSCAPI_PREFIX, OSCAPI_USER_INFORMATION, [Config getOwnID], userID, (unsigned long)page];
        };
    }
    
    return self;
}

- (instancetype)initWithUserName:(NSString *)userName
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.objClass = [OSCEvent class];
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&hisname=%@&pageIndex=%lu&pageSize=20", OSCAPI_PREFIX, OSCAPI_USER_INFORMATION, [Config getOwnID], userName, (unsigned long)page];
        };
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"activies"] childrenWithTag:@"active"];
}


#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[EventCell class] forCellReuseIdentifier:EventCellID];
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
        OSCEvent *event = self.objects[row];
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellID forIndexPath:indexPath];
        
        [cell setContentWithEvent:event];
        
        if (event.hasAnImage) {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:event.tweetImg.absoluteString];
            
            // 有图就加载，无图则下载并reload tableview
            if (!image) {
                [self downloadImageThenReload:event.tweetImg];
            } else {
                [cell.thumbnail setImage:image];
            }
        }
        
#if 0
        cell.portrait.tag = row; cell.authorLabel.tag = row; cell.thumbnail.tag = row;
        [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
        [cell.authorLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
        [cell.thumbnail addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImage:)]];
#endif
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCEvent *event = self.objects[indexPath.row];
        
        self.label.font = [UIFont boldSystemFontOfSize:15];
        [self.label setAttributedText:[Utils emojiStringFromRawString:event.message]];
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 51, MAXFLOAT)];
        CGFloat height = size.height + 24 + [UIFont systemFontOfSize:14].lineHeight;
        
        [self.label setAttributedText:event.actionStr];
        size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 51, MAXFLOAT)];
        height += size.height;
        
        if (event.hasReference) {
            UITextView *textView = [UITextView new];
            textView.text = [NSString stringWithFormat:@"%@: %@", event.objectReply[0], event.objectReply[1]];
            size = [textView sizeThatFits:CGSizeMake(tableView.frame.size.width - 51, MAXFLOAT)];
            height += size.height + 5;
        }
        
        if (event.shouleShowClientOrCommentCount) {
            height += [UIFont systemFontOfSize:14].lineHeight + 5;
        }

        if (event.hasAnImage) {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:event.tweetImg.absoluteString];
            if (!image) {image = [UIImage imageNamed:@"portrait_loading"];}
            height += image.size.height + 5;
        }
        
        return height;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.objects.count) {
        OSCEvent *event = self.objects[row];
        switch (event.catalog) {
            case 1: {
                OSCNews *news = [OSCNews new];
                news.newsID = event.objectID;
                news.type = event.objectCatalog;
                DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithNews:news];
                [self.navigationController pushViewController:detailsVC animated:YES];
                break;
            }
            case 2: {
                OSCPost *post = [OSCPost new];
                post.postID = event.objectID;
                DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithPost:post];
                [self.navigationController pushViewController:detailsVC animated:YES];
                break;
            }
            case 3: {
                OSCTweet *tweet = [OSCTweet new];
                tweet.tweetID = event.objectID;
                
                TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
                [self.navigationController pushViewController:tweetDetailsBVC animated:YES];
                
                break;
            }
            case 4: {
                OSCBlog *blog = [OSCBlog new];
                blog.blogID = event.objectID;
                DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithBlog:blog];
                [self.navigationController pushViewController:detailsVC animated:YES];
                break;
            }
            default:
                break;
        }
    } else {
        [self fetchMore];
    }
}





- (void)downloadImageThenReload:(NSURL *)imageURL
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL
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






@end
