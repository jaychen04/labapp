//
//  BlogsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/30/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "BlogsViewController.h"
#import "BlogCell.h"
#import "OSCBlog.h"

static NSString *kBlogCellID = @"BlogCell";

@interface BlogsViewController ()

@end

@implementation BlogsViewController

- (instancetype)initWithBlogsType:(BlogsType)type
{
    self = [super init];
    
    if (self) {
        NSString *blogType = type == BlogTypeLatest? @"latest" : @"recommend";
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?type=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_BLOGS_LIST, blogType, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.parseXML = ^NSArray * (ONOXMLDocument *xml) {
            return [[xml.rootElement firstChildWithTag:@"blogs"] childrenWithTag:@"blog"];
        };
        
        self.objClass = [OSCBlog class];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[BlogCell class] forCellReuseIdentifier:kBlogCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        BlogCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBlogCellID forIndexPath:indexPath];
        OSCBlog *blog = [self.objects objectAtIndex:indexPath.row];
        
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
        OSCBlog *blog = [self.objects objectAtIndex:indexPath.row];
        [self.label setText:blog.title];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        
        return size.height + 39;
    } else {
        return 60;
    }
}





@end
