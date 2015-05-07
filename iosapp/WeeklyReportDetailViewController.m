//
//  WeeklyReportDetailViewController.m
//  iosapp
//
//  Created by AeternChan on 5/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportDetailViewController.h"
#import "TimeLineNodeCell.h"
#import "TeamAPI.h"
#import "TeamWeeklyReportDetail.h"
#import "Utils.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

static NSString * const kTimeLineNodeCellID = @"TimeLineNodeCell";

@interface WeeklyReportDetailViewController ()

@property (nonatomic, strong) TeamWeeklyReportDetail *detail;
@property (nonatomic, assign) int teamID;
@property (nonatomic, assign) int reportID;

@end

@implementation WeeklyReportDetailViewController

- (instancetype)initWithTeamID:(int)teamID andReportID:(int)reportID
{
    self = [super init];
    if (self) {
        _teamID = teamID;
        _reportID = reportID;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor themeColor];
    [self.tableView registerClass:[TimeLineNodeCell class] forCellReuseIdentifier:kTimeLineNodeCellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@?teamid=%d&diaryid=%d", TEAM_PREFIX, TEAM_DIARY_DETAIL, _teamID, _reportID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _detail = [[TeamWeeklyReportDetail alloc] initWithXML:[responseObject.rootElement firstChildWithTag:@"diary"]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _detail.days;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString *attributedString = _detail.details[indexPath.row][1];
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:15];
    label.attributedText = attributedString;
    
    CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 99, MAXFLOAT)].height;
    
    return height + 38;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeLineNodeCellID forIndexPath:indexPath];
    
    [cell setContentWithString:_detail.details[indexPath.row][1]];
    cell.dayLabel.text = _detail.details[indexPath.row][0];
    
    cell.upperLine.hidden = indexPath.row == 0;
    cell.underLine.hidden = indexPath.row == _detail.days-1;
    
    return cell;
}



@end
