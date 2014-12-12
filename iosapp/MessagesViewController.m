//
//  MessagesViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "MessagesViewController.h"
#import "Config.h"
#import "OSCMessage.h"
#import "MessageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kMessageCellID = @"MessageCell";

@implementation MessagesViewController

- (instancetype)init
{
    self = [super init];
    if (!self) {return nil;}
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?uid=%llu&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_MESSAGES_LIST, [Config getOwnID], (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCMessage class];
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"messages"] childrenWithTag:@"message"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:kMessageCellID];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMessageCellID forIndexPath:indexPath];
        OSCMessage *message = self.objects[indexPath.row];
        
        cell.backgroundColor = [UIColor themeColor];
        [cell.portrait sd_setImageWithURL:message.portraitURL placeholderImage:nil];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", message.senderID == [Config getOwnID] ? @"发给" : @"来自", message.friendName];
        cell.contentLabel.text = message.content;
        cell.timeLabel.text = [Utils intervalSinceNow:message.pubDate];
        cell.commentCountLabel.text = [NSString stringWithFormat:@"%d条留言", message.messageCount];
        
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count) {
        OSCMessage *message = self.objects[indexPath.row];
        self.label.text = message.senderName;
        CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        self.label.text = message.content;
        CGSize contentSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        return nameSize.height + contentSize.height + 50;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row < self.objects.count) {
            
    } else {
        [self fetchMore];
    }
}

@end
