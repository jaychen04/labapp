//
//  PostsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "PostsViewController.h"
#import "PostCell.h"

#import "OSCPost.h"


static NSString *kPostCellID = @"PostCell";


@implementation PostsViewController

- (instancetype)initWithPostsType:(PostsType)type
{
    self = [super init];
    
    if (self) {
        self.generateURL = ^(NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_POSTS_LIST, type, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.parseXML = ^NSArray * (ONOXMLDocument *xml) {
            return [[xml.rootElement firstChildWithTag:@"posts"] childrenWithTag:@"post"];
        };
        
        self.objClass = [OSCPost class];
    }
    
    return self;
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
        OSCPost *post = [self.objects objectAtIndex:indexPath.row];
        
        [cell.portrait sd_setImageWithURL:post.portraitURL placeholderImage:nil options:0];        
        [cell.titleLabel setText:post.title];
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
        OSCPost *post = [self.objects objectAtIndex:indexPath.row];
        [self.label setText:post.title];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        return size.height + 39;
    } else {
        return 60;
    }
}







@end
