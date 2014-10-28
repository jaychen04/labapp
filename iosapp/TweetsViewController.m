//
//  TweetsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TweetsViewController.h"
#import "TweetCell.h"

#import "OSCTweet.h"



static NSString *kTweetCellID = @"TweetCell";



#pragma mark -

@interface TweetsViewController ()

@property (nonatomic, assign) int64_t uid;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) LastCell *lastCell;

@end

#pragma mark -



@implementation TweetsViewController

/*! Primary view has been loaded for this view controller
 
 */


- (instancetype)initWithType:(TweetsType)type
{
    self = [super init];
    if (self) {
        switch (type) {
            case TweetsTypeAllTweets:
                self.uid = 0;
                break;
            case TweetsTypeHotestTweets:
                self.uid = -1;
                break;
            case TweetsTypeOwnTweets:
                self.uid = 1244649;         /* 需要一个获得自己ID的方法 */
                break;
            default:
                break;
        }
        
        __weak TweetsViewController *weakSelf = self;
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            if (weakSelf.uid == -1) {[weakSelf.lastCell statusFinished];}
            else {responseObjectsCount < 20? [weakSelf.lastCell statusFinished]: [weakSelf.lastCell statusMore];}
        };
        
        self.generateURL = ^(NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_TWEETS_LIST, weakSelf.uid, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.parseXML = ^NSArray * (ONOXMLDocument *xml) {
            return [[xml.rootElement firstChildWithTag:@"tweets"] childrenWithTag:@"tweet"];
        };
        
        self.objClass = [OSCTweet class];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"self.tweets的应用计数:%ld", CFGetRetainCount((__bridge CFTypeRef)self.tweets));
    //NSLog(@"self.tweets的应用计数:%ld", CFGetRetainCount((__bridge CFTypeRef)_tweets));
    
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:kTweetCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetCellID forIndexPath:indexPath];
        OSCTweet *tweet = [self.objects objectAtIndex:indexPath.row];
        
        [cell.portrait sd_setImageWithURL:tweet.portraitURL placeholderImage:nil options:0]; //options:SDWebImageRefreshCached
        [cell.authorLabel setText:tweet.author];
        [cell.timeLabel setText:[Utils intervalSinceNow:tweet.pubDate]];
        [cell.appclientLabel setText:[Utils getAppclient:tweet.appclient]];
        [cell.commentCount setText:[NSString stringWithFormat:@"评论：%d", tweet.commentCount]];
        [cell.contentLabel setText:tweet.body];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCTweet *tweet = [self.objects objectAtIndex:indexPath.row];
        [self.label setText:tweet.body];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        
        return size.height + 71;
    } else {
        return 60;
    }
}





@end
