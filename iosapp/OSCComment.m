//
//  OSCComment.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCComment.h"

static NSString * const kID = @"id";
static NSString * const kPortrait = @"portrait";
static NSString * const kAuthor = @"author";
static NSString * const kAuthorID = @"authorid";
static NSString * const kContent = @"content";
static NSString * const kPubDate = @"pubDate";
static NSString * const kReplies = @"replies";
static NSString * const kReply = @"reply";
static NSString * const kRauthor = @"rauthor";
static NSString * const kRContent = @"rcontent";

@implementation OSCComment

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _commentID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        _content = [[xml firstChildWithTag:kContent] stringValue];
        _pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        NSMutableArray *mutableReplies = [NSMutableArray new];
        NSArray *repliesXML = [[xml firstChildWithTag:kReplies] childrenWithTag:kReply];
        for (ONOXMLElement *replyXML in repliesXML) {
            NSString *rauthor = [[replyXML firstChildWithTag:kRauthor] stringValue];
            NSString *rcontent = [[replyXML firstChildWithTag:kRContent] stringValue];
            [mutableReplies addObject:@[rauthor, rcontent]];
        }
        _replies = [NSArray arrayWithArray:mutableReplies];
    }
    
    return self;
}

@end
