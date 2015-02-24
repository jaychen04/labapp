//
//  MessageBubbleViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 2/12/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "MessageBubbleViewController.h"
#import "MessageBubbleCell.h"
#import "OSCComment.h"
#import "Config.h"

@interface MessageBubbleViewController ()

@end

@implementation MessageBubbleViewController

- (instancetype)initWithUserID:(int64_t)userID andUserName:(NSString *)userName
{
    self = [super init];
    if (self) {
        self.navigationItem.title = userName;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=4&id=%llu&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_COMMENTS_LIST, userID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCComment class];
    }
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"comments"] childrenWithTag:@"comment"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[MessageBubbleCell class] forCellReuseIdentifier:kMessageBubbleOthers];
    [self.tableView registerClass:[MessageBubbleCell class] forCellReuseIdentifier:kMessageBubbleMe];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCComment *message = self.objects[indexPath.row];
        
        MessageBubbleCell *cell = nil;
        if (message.authorID == [Config getOwnID]) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:kMessageBubbleMe forIndexPath:indexPath];
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:kMessageBubbleOthers forIndexPath:indexPath];
        }
        
        [cell setContent:message.content andPortrait:message.portraitURL];
        
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCComment *message = self.objects[indexPath.row];
        
        self.label.text = message.content;
        self.label.font = [UIFont systemFontOfSize:15];
        CGSize contentSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 85, MAXFLOAT)];
        
        return contentSize.height + 36;
    } else {
        return 60;
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_didScroll) {_didScroll();}
}



@end
