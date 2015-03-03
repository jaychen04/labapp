//
//  NewsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"
#import "OSCNews.h"
#import "DetailsViewController.h"

static NSString *kNewsCellID = @"NewsCell";

@interface NewsViewController ()

@end

@implementation NewsViewController


- (instancetype)initWithNewsListType:(NewsListType)type
{
    self = [super init];
    
    if (self) {
        __weak NewsViewController *weakSelf = self;
        self.generateURL = ^NSString * (NSUInteger page) {
            if (type < 4) {
                return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_NEWS_LIST, type, (unsigned long)page, OSCAPI_SUFFIX];
            } else if (type == NewsListTypeAllTypeWeekHottest) {
                return [NSString stringWithFormat:@"%@%@?show=week", OSCAPI_PREFIX, OSCAPI_NEWS_LIST];
            } else {
                return [NSString stringWithFormat:@"%@%@?show=month", OSCAPI_PREFIX, OSCAPI_NEWS_LIST];
            }
        };
        
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            if (type >= 4) {[weakSelf.lastCell statusFinished];}
            else {responseObjectsCount < 20? [weakSelf.lastCell statusFinished]: [weakSelf.lastCell statusMore];}
        };
        
        self.objClass = [OSCNews class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"newslist"] childrenWithTag:@"news"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[NewsCell class] forCellReuseIdentifier:kNewsCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellID forIndexPath:indexPath];
        OSCNews *news = self.objects[indexPath.row];
        
        if ([[Utils timeIntervalArrayFromString:news.pubDate][kKeyDays] integerValue] == 0) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:@"widget_today_icon.png"];
            NSAttributedString *attributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
            [strTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [strTitle appendAttributedString:[[NSAttributedString alloc] initWithString:news.title]];
            [cell.titleLabel setAttributedText:strTitle];

        }else{
            [cell.titleLabel setText:news.title];
        }
        
        [cell.bodyLabel setText:news.body];
        [cell.authorLabel setText:news.author];
        [cell.timeLabel setText:[Utils intervalSinceNow:news.pubDate]];
        [cell.commentCount setText:[NSString stringWithFormat:@"%d评", news.commentCount]];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCNews *news = self.objects[indexPath.row];
        
        if ([[Utils timeIntervalArrayFromString:news.pubDate][kKeyDays] integerValue] == 0)
        {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:@"widget_today_icon.png"];
            NSAttributedString *attributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
            [strTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [strTitle appendAttributedString:[[NSAttributedString alloc] initWithString:news.title]];
            
            [self.label setAttributedText:strTitle];
        } else {
            self.label.text = news.title;
        }
        self.label.font = [UIFont boldSystemFontOfSize:14];
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
        
        self.label.text = news.body;
        self.label.font = [UIFont systemFontOfSize:13];
        height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
        
        return height + 41;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.objects.count) {
        OSCNews *news = self.objects[row];
        DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithNews:news];
        [self.navigationController pushViewController:detailsViewController animated:YES];
    } else {
        [self fetchMore];
    }
}








@end
