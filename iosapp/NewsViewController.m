//
//  NewsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "OSCNews.h"
#import "NewsCell.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "LastCell.h"


static NSString *kNewsCellID = @"NewsCell";



@interface NewsViewController ()

@property (nonatomic, strong) NSMutableArray *news;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) LastCell *lastCell;

@end

@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.news = [NSMutableArray new];
    
    // tableView设置
    [self.tableView registerClass:[NewsCell class] forCellReuseIdentifier:kNewsCellID];
    
    self.tableView.backgroundColor = [UIColor themeColor];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    // 刷新
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // 用于计算高度
    self.label = [UILabel new];
    
    self.lastCell = [[LastCell alloc] initCell];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.news.count > 0 || self.lastCell.status == LastCellStatusFinished) {
        return;
    }
    
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height)
                            animated:YES];
    
    [self fetchNewsOnPage:0 refresh:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.lastCell.status == LastCellStatusNotVisible) return self.news.count;
    return self.news.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.news.count) {
        NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellID forIndexPath:indexPath];
        OSCNews *news = [self.news objectAtIndex:indexPath.row];
        
        [cell.titleLabel setText:news.title];
        [cell.authorLabel setText:news.author];
        [cell.timeLabel setText:[Utils intervalSinceNow:news.pubDate]];
        [cell.commentCount setText:[NSString stringWithFormat:@"%d", news.commentCount]];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.news.count) {
        OSCNews *news = [self.news objectAtIndex:indexPath.row];
        [self.label setText:news.title];
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.font = [UIFont boldSystemFontOfSize:14];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        
        return size.height + 42;
    } else {
        return 60;
    }
}





#pragma mark - 刷新

- (void)refresh
{
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fetchNewsOnPage:0 refresh:YES];
            refreshInProgress = NO;
        });
    }
}




#pragma mark - 上拉加载更多

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
    {
        [self fetchMore];
    }
}

- (void)fetchMore
{
    if (self.lastCell.status == LastCellStatusFinished || self.lastCell.status == LastCellStatusLoading) {return;}
    
    [self.lastCell statusLoading];
    [self fetchNewsOnPage:(self.news.count + 19)/20 refresh:NO];
}




#pragma mark - 加载新闻

- (void)fetchNewsOnPage:(NSUInteger)page refresh:(BOOL)refresh
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
    
    if (!refresh) {[self.lastCell statusLoading];}
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@?catalog=1&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_NEWS_LIST, (unsigned long)page, OSCAPI_SUFFIX]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             NSArray *newsXML = [[responseDocument.rootElement firstChildWithTag:@"newslist"] childrenWithTag:@"news"];
             
             if (refresh) {[self.news removeAllObjects];}
             
             /* 这里要添加一个去重步骤 */
             
             for (ONOXMLElement *singleNewsXML in newsXML) {
                 OSCNews *news = [[OSCNews alloc] initWithXML:singleNewsXML];
                 [self.news addObject:news];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
                 if (refresh) {[self.refreshControl endRefreshing];}
             });
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"网络异常，错误码：%ld", (long)error.code);
             
             [self.lastCell statusError];
             [self.tableView reloadData];
             if (refresh) {
                 [self.refreshControl endRefreshing];
             }
             
         }
     ];
}




@end
