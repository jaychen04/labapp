//
//  TeamActivityDetailViewController.m
//  iosapp
//
//  Created by Holden on 15/5/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamActivityDetailViewController.h"
#import "TeamAPI.h"
#import "Utils.h"
#import "Config.h"
#import "TeamActivity.h"
#import "TeamDetailContentCell.h"
#import "TeamReply.h"
#import "TeamReplyCell.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

static NSString * const kTeamReplyCellID = @"TeamReplyCell";

@interface TeamActivityDetailViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) int teamID;
@property (nonatomic, strong) TeamActivity *activity;
@property (nonatomic, strong) NSMutableArray *replies;

@end

@implementation TeamActivityDetailViewController

- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        _activity = activity;
        _teamID = teamID;
        _replies = [NSMutableArray new];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"动态详情";
    
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor themeColor];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[TeamReplyCell class] forCellReuseIdentifier:kTeamReplyCellID];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:(UIView *)self.editingBar];
    
    NSDictionary *views = @{@"detailTableView": _tableView, @"bottomBar": self.editingBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailTableView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
    
    [self fetchReplies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (indexPath.section == 0) {
        label.attributedText = _activity.attributedDetail;
        
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
        
        return height + 62;
    } else {
        TeamReply *reply = _replies[indexPath.row];
        
        label.font = [UIFont systemFontOfSize:14];
        label.text = reply.content;
        
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        
        return height + 66;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_activity) {
        return 0;
    } else {
        return _replies.count? 2 : 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0? 0 : 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        NSString *title;
        if (_activity.replyCount) {
            title = [NSString stringWithFormat:@"%d 条评论", _activity.replyCount];
        } else {
            title = @"没有评论";
        }
        return title;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0? 1 : _replies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TeamDetailContentCell *cell = [TeamDetailContentCell new];
        [cell setContentWithActivity:_activity];
        
        return cell;
    } else {
        TeamReply *reply = _replies[indexPath.row];
        
        TeamReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:kTeamReplyCellID forIndexPath:indexPath];
        [cell setContentWithReply:reply];
        
        return cell;
    }
}

#pragma 发表评论

- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[Utils generateUserAgent] forHTTPHeaderField:@"User-Agent"];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_TWEET_REPLY]
       parameters:@{
                    @"teamid": @(_teamID),
                    @"uid": @([Config getOwnID]),
                    @"type": @(_activity.type),
                    @"tweetid": @(_activity.activityID),
                    @"content": [Utils convertRichTextToRawText:self.editingBar.editView]
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
             
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                 
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.labelText = @"评论发表成功";
                 
                  [_tableView setContentOffset:CGPointZero animated:NO];
                  [self fetchReplies];
              } else {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabelText = error.localizedFailureReason;
             
              [HUD hide:YES afterDelay:1];
          }];
}


#pragma mark - 获取评论列表

- (void)fetchReplies
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
                   @"pageIndex":@((_replies.count + 19) / 20)
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             NSArray *repliesXML = [[responseObject.rootElement firstChildWithTag:@"replies"] childrenWithTag:@"reply"];
             for (ONOXMLElement *replyXML in repliesXML) {
                 TeamReply *reply = [[TeamReply alloc] initWithXML:replyXML];
                 [_replies addObject:reply];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}






@end
