//
//  NewsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"

#import "OSCNews.h"



static NSString *kNewsCellID = @"NewsCell";



@interface NewsViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation NewsViewController


- (instancetype)initWithCatalog:(int)catalog
{
    self = [super init];
    
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_NEWS_LIST, catalog, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.parseXML = ^NSArray * (ONOXMLDocument *xml) {
            return [[xml.rootElement firstChildWithTag:@"newslist"] childrenWithTag:@"news"];
        };
        
        self.objClass = [OSCNews class];
    }
    
    return self;
}

- (void)viewDidLoad
{
#if 1
    self.generateURL = ^NSString * (NSUInteger page) {
        NSString *url = [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_NEWS_LIST, 1, (unsigned long)page, OSCAPI_SUFFIX];
        
        return url;
    };
    
    self.parseXML = ^NSArray * (ONOXMLDocument *xml) {
        return [[xml.rootElement firstChildWithTag:@"newslist"] childrenWithTag:@"news"];
    };
    
    self.objClass = [OSCNews class];
#endif
    
    [super viewDidLoad];
    
    [self.tableView registerClass:[NewsCell class] forCellReuseIdentifier:kNewsCellID];
    
    self.label = [UILabel new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellID forIndexPath:indexPath];
        OSCNews *news = [self.objects objectAtIndex:indexPath.row];
        
        [cell.titleLabel setText:news.title];
        [cell.authorLabel setText:news.author];
        [cell.timeLabel setText:[Utils intervalSinceNow:news.pubDate]];
        [cell.commentCount setText:[NSString stringWithFormat:@"%d", news.commentCount]];
        
        return cell;
    } else {
        return self.lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCNews *news = [self.objects objectAtIndex:indexPath.row];
        [self.label setText:news.title];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        
        return size.height + 42;
    } else {
        return 60;
    }
}








@end
