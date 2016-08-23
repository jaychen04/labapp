//
//  OSCCommentsController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCommentsController.h"
#import "OSCAPI.h"
#import "Config.h"
#import "MessageCenter.h"
#import "OSCCommentsCell.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIColor+Util.h"

#import <MJRefresh.h>

static NSString* const OSCCommentsCellReuseIdentifier = @"OSCCommentsCell";
@interface OSCCommentsController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,strong) NSString* nextToken;

@end

@implementation OSCCommentsController

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDataThroughDropdown:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getDataThroughDropdown:NO];
    }];
    [self.tableView.mj_header beginRefreshing];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}


#pragma mark --- Networking 
- (void)getDataThroughDropdown:(BOOL)dropDown{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?uid=%llu",OSCAPI_V2_PREFIX,OSCAPI_MESSAGES_COMMENTS_LIST,[Config getOwnID]];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!dropDown && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    [manager GET:strUrl
      parameters:paraMutableDic.copy
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
    }];
}

#pragma mark --- UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCCommentsCell* cell = [OSCCommentsCell returnReuseCommentsCellWithTableView:tableView identifier:OSCCommentsCellReuseIdentifier];
    cell.commentItem = self.dataSource[indexPath.row];
    return cell;
}



#pragma mark --- lazy loading
- (UITableView *)tableView {
    if(_tableView == nil) {
        UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView = tableView;
        _tableView.separatorColor = [UIColor separatorColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (NSMutableArray *)dataSource {
	if(_dataSource == nil) {
		_dataSource = [[NSMutableArray alloc] init];
	}
	return _dataSource;
}

@end
