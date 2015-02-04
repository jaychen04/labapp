//
//  PostsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "PostsViewController.h"
#import "PostCell.h"
#import "OSCPost.h"
#import "DetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


static NSString *kPostCellID = @"PostCell";


@implementation PostsViewController

- (instancetype)initWithPostsType:(PostsType)type
{
    self = [super init];
    
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_POSTS_LIST, type, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCPost class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"posts"] childrenWithTag:@"post"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[PostCell class] forCellReuseIdentifier:kPostCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark - 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPostCellID forIndexPath:indexPath];
        OSCPost *post = self.objects[indexPath.row];
        
        [cell.portrait sd_setImageWithURL:post.portraitURL placeholderImage:nil options:0];        
        [cell.titleLabel setText:post.title];
        [cell.bodyLabel setText:post.body];
        [cell.authorLabel setText:post.author];
        [cell.timeLabel setText:[Utils intervalSinceNow:post.pubDate]];
        [cell.commentAndView setText:[NSString stringWithFormat:@"%d回 / %d阅", post.replyCount, post.viewCount]];
        
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCPost *post = self.objects[indexPath.row];
        
        self.label.text = post.title;
        self.label.font = [UIFont boldSystemFontOfSize:14];
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
        
        self.label.text = post.body;
        self.label.font = [UIFont systemFontOfSize:13];
        height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
        
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
        OSCPost *post = self.objects[row];
        DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithPost:post];
        [self.navigationController pushViewController:detailsViewController animated:YES];
    } else {
        [self fetchMore];
    }
}







@end
