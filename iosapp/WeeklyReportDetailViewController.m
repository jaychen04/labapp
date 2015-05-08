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
#import "TeamDetailContentCell.h"
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
    self.navigationItem.title = @"周报内容";
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
    return _detail? _detail.days + 1 : 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:15];
    
    if (row == 0) {
        label.attributedText = _detail.summary;
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
        
        return height + 62;
    } else {
        row -= 1;
        NSAttributedString *attributedString = _detail.details[row][1];
        
        label.attributedText = attributedString;
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 99, MAXFLOAT)].height;
        
        return height + 18;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 0 && _detail) {
        TeamDetailContentCell *cell = [TeamDetailContentCell new];
        [cell setContentWithReportDetail:_detail];
        
        return cell;
    } else {                //if (row < _detail.days - 1) {
        row -= 1;
        TimeLineNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeLineNodeCellID forIndexPath:indexPath];
        
        [cell setContentWithString:_detail.details[row][1]];
        cell.dayLabel.text = _detail.details[row][0];
        
        cell.upperLine.hidden = row == 0;
        cell.underLine.hidden = row == _detail.days-1;
        
        return cell;
    }
}



@end
