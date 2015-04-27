//
//  DiscussionViewController.m
//  iosapp
//
//  Created by AeternChan on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamDiscussionViewController.h"
#import "TeamAPI.h"
#import "TeamDiscussion.h"
#import "TeamDiscussionCell.h"
#import "DiscussionDetailsViewController.h"

static NSString * const kDiscussionCellID = @"TeamDiscussionCell";

@interface TeamDiscussionViewController ()

@end

@implementation TeamDiscussionViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=12378&pageIndex=%lu", TEAM_PREFIX, TEAM_DISCUSS_LIST, (unsigned long)page];
        };
        
        self.objClass = [TeamDiscussion class];
        self.needCache = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"团队动态";
    [self.tableView registerClass:[TeamDiscussionCell class] forCellReuseIdentifier:kDiscussionCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"discusses"] childrenWithTag:@"discuss"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        TeamDiscussion *discussion = self.objects[indexPath.row];
        
        self.label.font = [UIFont boldSystemFontOfSize:15];
        self.label.text = discussion.title;
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        
        self.label.text = discussion.body;
        self.label.font = [UIFont systemFontOfSize:13];
        height += [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        
        return height + 43;
    } else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        TeamDiscussionCell *cell = [tableView dequeueReusableCellWithIdentifier:kDiscussionCellID forIndexPath:indexPath];
        TeamDiscussion *discussion = self.objects[indexPath.row];
        
        [cell setContentWithDiscussion:discussion];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TeamDiscussion *teamDiscussion = self.objects[indexPath.row];
    
    if (indexPath.row < self.objects.count) {
        [self.navigationController pushViewController:[[DiscussionDetailsViewController alloc] initWithDiscussionID:teamDiscussion.discussionID]
                                             animated:YES];
    }
}




@end
