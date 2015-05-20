//
//  TeamCommentsViewController.m
//  iosapp
//
//  Created by AeternChan on 5/19/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamCommentsViewController.h"
#import "TeamAPI.h"
#import "Utils.h"
#import "Config.h"
#import "TeamActivity.h"
#import "TeamDetailContentCell.h"
#import "TeamReply.h"
#import "TeamReplyCell.h"

#import "TeamDetailContentCell.h"

#import <MBProgressHUD.h>

static NSString * const kTeamReplyCellID = @"TeamReplyCell";

@interface TeamCommentsViewController ()

@property (nonatomic, assign) int teamID;
@property (nonatomic, strong) NSDictionary *parameters;

@property (nonatomic, strong) TeamActivity *activity;

@end

@implementation TeamCommentsViewController

- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID
{
    self = [super init];
    if (self) {
        _activity = activity;
        _teamID = teamID;
        
        __weak typeof(self) weakSelf = self;
        
        self.objClass = [TeamReply class];
        self.allCountKey = @"totalCount";
        
        NSString *API = _activity.type == 110? TEAM_REPLY_LIST_BY_ACTIVEID :
                                               TEAM_REPLY_LIST_BY_TYPE;
        NSString *type = @{@(118): @"diary", @(114): @"discuss", @(112): @"issue"}[@(_activity.type)] ?: @"";
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d&id=%d&type=%@&pageIndex=%ld", OSCAPI_PREFIX, API, teamID, activity.activityID, type, page];
        };
        
        _detailCell = ^ UITableViewCell *  {
            TeamDetailContentCell *cell = [TeamDetailContentCell new];
            [cell setContentWithActivity:activity];
            
            return cell;
        };
        
        _detailCellHeight = ^ CGFloat {
            weakSelf.label.attributedText = weakSelf.activity.attributedDetail;
            
            CGFloat height = [weakSelf.label sizeThatFits:CGSizeMake(weakSelf.tableView.bounds.size.width - 16, MAXFLOAT)].height;
            
            return height + 62;
        };
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"replies"] childrenWithTag:@"reply"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[TeamReplyCell class] forCellReuseIdentifier:kTeamReplyCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
        if (self.allCount) {
            title = [NSString stringWithFormat:@"%d 条评论", self.allCount];
        } else {
            title = @"没有评论";
        }
        
        return title;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0? 1 : self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (indexPath.section == 0) {
        return _detailCellHeight();
    } else {
        TeamReply *reply = self.objects[indexPath.row];
        
        label.font = [UIFont systemFontOfSize:14];
        label.text = reply.content;
        
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        
        return height + 66;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return _detailCell();
    } else {
        TeamReply *reply = self.objects[indexPath.row];
        
        TeamReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:kTeamReplyCellID forIndexPath:indexPath];
        [cell setContentWithReply:reply];
        
        return cell;
    }
}




@end
