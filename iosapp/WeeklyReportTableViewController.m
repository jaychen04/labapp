//
//  WeeklyReportTableViewController.m
//  iosapp
//
//  Created by AeternChan on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportTableViewController.h"
#import "TeamAPI.h"
#import "TeamWeeklyReport.h"
#import "WeeklyReportCell.h"

static NSString * const kWeeklyReportCellID = @"WeeklyReportCell";

@interface WeeklyReportTableViewController ()

@end

@implementation WeeklyReportTableViewController

- (instancetype)initWithTeamID:(int)teamID year:(int)year andWeek:(int)week
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d&year=%d&week=%d&pageIndex=%lu", TEAM_PREFIX, TEAM_DIARY_LIST, teamID, year, week, (unsigned long)page];
        };
        
        self.objClass = [TeamWeeklyReport class];
        self.needCache = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[WeeklyReportCell class] forCellReuseIdentifier:kWeeklyReportCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"diaries"] childrenWithTag:@"diary"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        TeamWeeklyReport *weeklyReport = self.objects[indexPath.row];
        
        self.label.attributedText = weeklyReport.attributedTitle;
        
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        
        return height + 63;
    } else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        WeeklyReportCell *cell = [tableView dequeueReusableCellWithIdentifier:kWeeklyReportCellID forIndexPath:indexPath];
        TeamWeeklyReport *weeklyReport = self.objects[indexPath.row];
        
        [cell setContentWithWeeklyReport:weeklyReport];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
