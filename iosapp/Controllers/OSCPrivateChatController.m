//
//  OSCPrivateChatController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChatController.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCPrivateChatCell.h"
#import "OSCPrivateChat.h"
#import "OSCPhotoGroupView.h"

#import "OSCAPI.h"
#import "Config.h"
#import <MJRefresh.h>


static NSString* const OSCPrivateChatCellReuseIdentifier = @"OSCPrivateChatCell";
@interface OSCPrivateChatController ()<UITableViewDelegate,UITableViewDataSource,OSCPrivateChatCellDelegate>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;

@end

@implementation OSCPrivateChatController{
    NSInteger _authorId;
    NSString* _prevPageToken;
    NSString* _nextPageToken;
}
#pragma mark --- initialize method
- (instancetype)initWithAuthorId:(NSInteger)authorId{
    self = [super init];
    if (self) {
        _authorId = authorId;
        _prevPageToken = nil;
        _nextPageToken = nil;
    }
    return self;
}

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDataUpgradeRequest:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [self getDataUpgradeRequest:NO];
    }];
    [self getDataUpgradeRequest:NO];
}


#pragma mark --- Networking
// YES:往上请求数据 带prevPageToken   NO:往下请求数据 带nextPageToken
- (void)getDataUpgradeRequest:(BOOL)isUpgradeReq{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?uid=%llu&authorId=%ld",OSCAPI_V2_PREFIX,OSCAPI_MESSAGE_CHAT_LIST,[Config getOwnID],_authorId];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];

    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (isUpgradeReq && [_prevPageToken length] > 0) {
        [paraMutableDic setObject:_prevPageToken forKey:@"prevPageToken"];
    }
    if (!isUpgradeReq && [_nextPageToken length] > 0) {
        [paraMutableDic setObject:_nextPageToken forKey:@"nextPageToken"];
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
    OSCPrivateChatCell* chatCell = [OSCPrivateChatCell returnReusePrivateChatCellWithTableView:tableView identifier:OSCPrivateChatCellReuseIdentifier];
    chatCell.privateChat = self.dataSource[indexPath.row];
    chatCell.delegate = self;
    return chatCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCPrivateChat* dataSource = self.dataSource[indexPath.row];
    if (dataSource.rowHeight == 0) {
        dataSource.rowHeight = dataSource.popFrame.size.height + SCREEN_PADDING_TOP + SCREEN_PADDING_BOTTOM;
    }
    return dataSource.rowHeight;
}

#pragma mark --- scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && _didScroll) {_didScroll();}
}


#pragma mark --- OSCPrivateChatCellDelegate
//文本cell回调
- (void)privateChatNodeTextViewDidClickText:(OSCPrivateChatCell *)privateChatCell{

}
//图片cell回调
- (void)privateChatNodeImageViewDidClickImage:(OSCPrivateChatCell *)privateChatCell{

}
- (void)privateChatNodeImageViewloadThumbImageDidFinsh:(OSCPrivateChatCell *)privateChatCell{
    [self.tableView reloadData];
}
- (void)privateChatNodeImageViewloadLargerImageDidFinsh:(OSCPrivateChatCell *)privateChatCell photoGroupView:(OSCPhotoGroupView *)groupView fromView:(UIImageView *)fromView{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:nil];
}
//文件cell回调
- (void)privateChatNodeFileViewDidClickFile:(OSCPrivateChatCell *)privateChatCell{

}






#pragma mark --- lazy loading
- (UITableView *)tableView {
	if(_tableView == nil) {
		_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
