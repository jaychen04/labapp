//
//  OSCObjsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"
#import "OSCBaseObject.h"
#import "LastCell.h"

@interface OSCObjsViewController ()

@property (nonatomic, strong) LastCell *lastCell;

@end

@implementation OSCObjsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor themeColor];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    self.lastCell = [[LastCell alloc] initCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.lastCell.status == LastCellStatusNotVisible) return self.objects.count;
    return self.objects.count + 1;
}




#pragma mark - 刷新

- (void)refresh
{
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fetchObjectsOnPage:0 refresh:YES];
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
    [self fetchObjectsOnPage:(self.objects.count + 19)/20 refresh:NO];
}




#pragma mark - 请求数据

- (void)fetchObjectsOnPage:(NSUInteger)page refresh:(BOOL)refresh
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
    [manager GET:self.generateURL(page, refresh)
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             NSArray *tweetsXML = [[responseDocument.rootElement firstChildWithTag:@"tweets"] childrenWithTag:@"tweet"];
             
             if (refresh) {[self.objects removeAllObjects];}
             
             /* 这里要添加一个去重步骤 */
             
             for (ONOXMLElement *objXML in tweetsXML) {
                 id obj = [[self.objClass alloc] initWithXML:objXML];
                 [self.objects addObject:obj];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (self.tableWillReload) {self.tableWillReload();}
                 
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
