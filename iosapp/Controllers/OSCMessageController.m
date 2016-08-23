//
//  OSCMessageController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMessageController.h"
#import "OSCMessageCell.h"
#import "MessageItem.h"
#import "OSCAPI.h"
#import "Config.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIColor+Util.h"
#import <AFNetworking.h>
#import <MJRefresh.h>

static NSString* const messageCellIdentifier = @"OSCMessageCell";

@interface OSCMessageController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView* tableView;

@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,strong) NSString* nextToken;

@end

@implementation OSCMessageController

#pragma mrak --- initialize Method


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

#pragma mark --- Network 
- (void)getDataThroughDropdown:(BOOL)dorpDown{//YES:下拉   NO:上拉
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?uid=%llu",OSCAPI_V2_PREFIX,OSCAPI_MESSAGES_LIST,[Config getOwnID]];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!dorpDown && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    [manager GET:strUrl
      parameters:paraMutableDic.copy
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if([responseObject[@"code"]integerValue] == 1) {
                 
             }
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
    OSCMessageCell* cell = [OSCMessageCell returnReuseMessageCellWithTableView:tableView identifier:messageCellIdentifier];
    cell.messageItem = self.dataSource[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //push 到私信界面
}







#pragma mark --- lazy loading
- (UITableView *)tableView {
	if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.separatorColor = [UIColor separatorColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
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
