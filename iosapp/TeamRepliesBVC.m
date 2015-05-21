//
//  TeamRepliesBVC.m
//  iosapp
//
//  Created by AeternChan on 5/21/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamRepliesBVC.h"
#import "TeamReply.h"
#import "TeamAPI.h"
#import "TeamActivity.h"
#import "TeamReplyCell.h"
#import "Utils.h"
#import "LastCell.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

static NSString * const kTeamReplyCellID = @"TeamReplyCell";

@interface TeamRepliesBVC ()

@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) LastCell *lastCell;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) int repliesCount;
@property (nonatomic, assign) int teamID;
@property (nonatomic, strong) TeamActivity *activity;

@end

@implementation TeamRepliesBVC

- (instancetype)init
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        _replies = [NSMutableArray new];
        
        _label = [UILabel new];
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return self;
}


- (instancetype)initWIthActivity:(TeamActivity *)activity andTeamID:(int)teamID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        _replies = [NSMutableArray new];
        _activity = activity;
        _teamID = teamID;
        
        _label = [UILabel new];
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor themeColor];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[TeamReplyCell class] forCellReuseIdentifier:kTeamReplyCellID];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    _lastCell = [LastCell new];
    [_lastCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchMore)]];
    _tableView.tableFooterView = _lastCell;
    
    [self.view bringSubviewToFront:(UIView *)self.editingBar];
    
    NSDictionary *views = @{@"tableView": _tableView, @"bottomBar": self.editingBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
    
    [self fetchRepliesOnPage:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0? 0 : 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (_repliesCount) {
        title = [NSString stringWithFormat:@"%d 条评论", _repliesCount];
    } else {
        title = @"没有评论";
    }
    
    return title;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _replies.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamReply *reply = _replies[indexPath.row];
    
    _label.font = [UIFont systemFontOfSize:14];
    _label.text = reply.content;
    
    CGFloat height = [_label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
    
    return height + 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamReply *reply = _replies[indexPath.row];
        
    TeamReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:kTeamReplyCellID forIndexPath:indexPath];
    [cell setContentWithReply:reply];
        
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamReply *reply = _replies[indexPath.row];
    
    NSString *authorString = [NSString stringWithFormat:@"@%@", reply.author.name];
    
    if ([self.editingBar.editView.text rangeOfString:authorString].location == NSNotFound) {
        [self.editingBar.editView replaceRange:self.editingBar.editView.selectedTextRange withText:authorString];
        [self.editingBar.editView becomeFirstResponder];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        [self.editingBar.editView resignFirstResponder];
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
    if (!_lastCell.shouldResponseToTouch) {return;}
    
    _lastCell.status = LastCellStatusLoading;
    [self fetchRepliesOnPage:(_replies.count + 19) / 20];
}


#pragma mark - 获取评论列表

- (void)fetchRepliesOnPage:(NSUInteger)page
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[Utils generateUserAgent] forHTTPHeaderField:@"User-Agent"];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    NSString *API = _activity.type == 110? TEAM_REPLY_LIST_BY_ACTIVEID :
                                           TEAM_REPLY_LIST_BY_TYPE;
    NSString *type = @{@(118): @"diary", @(114): @"discuss", @(112): @"issue"}[@(_activity.type)] ?: @"";
    
    [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, API]
      parameters:@{
                   @"teamid": @(_teamID),
                   @"id": @(_activity.activityID),
                   @"type": type,
                   @"pageIndex":@(page)
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _repliesCount = [responseObject.rootElement firstChildWithTag:@"totalCount"].numberValue.intValue;
             
             NSArray *repliesXML = [[responseObject.rootElement firstChildWithTag:@"replies"] childrenWithTag:@"reply"];
             
             if (page == 0) {[_replies removeAllObjects];}
             
             for (ONOXMLElement *replyXML in repliesXML) {
                 TeamReply *newReply = [[TeamReply alloc] initWithXML:replyXML];
                 
                 BOOL shouldBeAdded = YES;
                 
                 for (TeamReply *reply in _replies) {
                     if ([newReply isEqual:reply]) {
                         shouldBeAdded = NO;
                         break;
                     }
                 }
                 if (shouldBeAdded) {
                     [_replies addObject:newReply];
                 }
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}



@end
