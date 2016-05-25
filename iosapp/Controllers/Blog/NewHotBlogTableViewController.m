//
//  NewHotBlogTableViewController.m
//  iosapp
//
//  Created by Holden on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewHotBlogTableViewController.h"
#import "BlogCell.h"
#import "OSCBlog.h"
#import "Config.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "DetailsViewController.h"

static NSString *kBlogCellID = @"BlogCell";
@interface NewHotBlogTableViewController ()
@property (nonatomic, strong)NSArray *blogObjects;
@property (nonatomic, strong) UILabel *label;

@end

@implementation NewHotBlogTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[BlogCell class] forCellReuseIdentifier:kBlogCellID];
    
    _label = [UILabel new];
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.font = [UIFont boldSystemFontOfSize:14];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark -- DIY_headerView
- (UIView*)setUpHeaderViewWithSectionTitle:(NSString*)title iconUrl:(NSURL*)iconUrl {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xffffff];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 30, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:30];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    UIImageView *rightIv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(headerView.frame)-30, 0, 13, 7)];
    rightIv.center = CGPointMake(rightIv.center.x, headerView.center.y);
    [headerView addSubview:rightIv];

    headerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getMoreBlogWithSeries:)];
    [headerView addGestureRecognizer:tap];
    
    
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *seriesTitle = section==0?@"最热":@"最新";
    NSURL *seriesUrl = section==0?nil:nil;
    return [self setUpHeaderViewWithSectionTitle:seriesTitle iconUrl:seriesUrl];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlogCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBlogCellID forIndexPath:indexPath];
    OSCBlog *blog = self.blogObjects[indexPath.row];
    
    cell.backgroundColor = [UIColor themeColor];
    
    [cell.titleLabel setAttributedText:blog.attributedTittle];
    [cell.bodyLabel setText:blog.body];
    [cell.authorLabel setText:blog.author];
    cell.titleLabel.textColor = [UIColor titleColor];
    [cell.timeLabel setAttributedText:[Utils attributedTimeString:blog.pubDate]];
    [cell.commentCount setAttributedText:blog.attributedCommentCount];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCBlog *blog = self.blogObjects[indexPath.row];
    self.label.font = [UIFont boldSystemFontOfSize:15];
    [self.label setAttributedText:blog.attributedTittle];
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    self.label.text = blog.body;
    self.label.font = [UIFont systemFontOfSize:13];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    return height + 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCBlog *blog = self.blogObjects[indexPath.row];
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithBlog:blog];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

@end
