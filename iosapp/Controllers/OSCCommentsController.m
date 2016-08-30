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
#import "OSCMessageCenter.h"
#import "OSCCommentsCell.h"
#import "UserDetailsViewController.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIColor+Util.h"

#import <YYKit.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <MBProgressHUD.h>

#define COMMENT_HEIGHT 150

static NSString* const OSCCommentsCellReuseIdentifier = @"OSCCommentsCell";
@interface OSCCommentsController ()<UITableViewDelegate,UITableViewDataSource,OSCCommentsCellDelegate>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,strong) NSString* nextToken;

@end

@implementation OSCCommentsController

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCCommentsCell" bundle:nil] forCellReuseIdentifier:OSCCommentsCellReuseIdentifier];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDataThroughDropdown:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getDataThroughDropdown:NO];
    }];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark --- Networking 
- (void)getDataThroughDropdown:(BOOL)dropDown{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?uid=%llu",OSCAPI_V2_PREFIX,OSCAPI_MESSAGES_COMMENTS_LIST,[Config getOwnID]];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!dropDown && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    MBProgressHUD *HUD = [Utils createHUD];
    
    [manager GET:strUrl
      parameters:paraMutableDic.copy
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if([responseObject[@"code"]integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray* items = resultDic[@"items"];
                 if (dropDown) {
                     [self.dataSource removeAllObjects];
                 }
                 NSArray* models = [CommentItem mj_objectArrayWithKeyValuesArray:items];
                 [self.dataSource addObjectsFromArray:models];
                 self.nextToken = resultDic[@"nextPageToken"];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (dropDown) {
                         [self.tableView.mj_header endRefreshing];
                     }else{
                         [self.tableView.mj_footer endRefreshing];
                     }
                     [self.tableView reloadData];
                     [HUD hideAnimated:YES afterDelay:1];
                 });
             }else{
                 HUD.label.text = @"未知错误";
                 [HUD hideAnimated:YES afterDelay:1];
             }
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (dropDown) {
                     [self.tableView.mj_header endRefreshing];
                 }else{
                     [self.tableView.mj_footer endRefreshing];
                 }
                 HUD.label.text = @"网络异常，操作失败";
                 [HUD hideAnimated:YES afterDelay:1];
             });
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
    OSCCommentsCell* cell = [OSCCommentsCell returnReuseCommentsCellWithTableView:tableView indexPath:indexPath identifier:OSCCommentsCellReuseIdentifier];
    cell.commentItem = self.dataSource[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //push new ViewController...
}

#pragma mark --- OSCCommentsCellDelegate
- (void)commentsCellDidClickUserPortrait:(OSCCommentsCell *)cell{
    CommentItem* commentItem = cell.commentItem;
    OSCReceiver* receiver = commentItem.author;
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:receiver.id];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}


#pragma mark --- lazy loading
- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,self.view.bounds.size.height - 100}} style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = COMMENT_HEIGHT;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.scrollsToTop = NO;
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
