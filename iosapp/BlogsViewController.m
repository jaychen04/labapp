//
//  BlogsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/30/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "BlogsViewController.h"
#import "BlogCell.h"
#import "OSCBlog.h"
#import "Config.h"
#import "DetailsViewController.h"

static NSString *kBlogCellID = @"BlogCell";

@interface BlogsViewController ()

@end

@implementation BlogsViewController


#pragma mark - init method

- (instancetype)initWithBlogsType:(BlogsType)type
{
    if (self = [super init]) {
        NSString *blogType = type == BlogTypeLatest? @"latest" : @"recommend";
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?type=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_BLOGS_LIST, blogType, (unsigned long)page, OSCAPI_SUFFIX];
        };
        self.objClass = [OSCBlog class];
    }
    
    return self;
}

- (instancetype)initWithUserID:(int64_t)userID
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?authoruid=%lld&pageIndex=1&pageSize=%d&uid=%lld", OSCAPI_PREFIX, OSCAPI_USERBLOGS_LIST, userID, 20, [Config getOwnID]];
        };
        self.objClass = [OSCBlog class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"blogs"] childrenWithTag:@"blog"];
}



#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[BlogCell class] forCellReuseIdentifier:kBlogCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark - tableView things

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        BlogCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBlogCellID forIndexPath:indexPath];
        OSCBlog *blog = self.objects[indexPath.row];
        
        [cell.titleLabel setText:blog.title];
        [cell.authorLabel setText:blog.author];
        [cell.timeLabel setText:[Utils intervalSinceNow:blog.pubDate]];
        [cell.commentCount setText:[NSString stringWithFormat:@"%d 评", blog.commentCount]];
        
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCBlog *blog = self.objects[indexPath.row];
        [self.label setText:blog.title];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        
        return size.height + 39;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.objects.count) {
        OSCBlog *blog = self.objects[row];
        DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithBlog:blog];
        [self.navigationController pushViewController:detailsViewController animated:YES];
    } else {
        [self fetchMore];
    }
}





@end
