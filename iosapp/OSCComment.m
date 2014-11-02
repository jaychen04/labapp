//
//  OSCComment.m
//  iosapp
//
//  Created by ChanAetern on 10/28/14.
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
        self.commentID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        
        self.portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        self.author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        self.content = [[xml firstChildWithTag:kContent] stringValue];
        self.pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        NSMutableArray *mutableReplies = [NSMutableArray new];
        NSArray *repliesXML = [[xml firstChildWithTag:kReplies] childrenWithTag:kReply];
        for (ONOXMLElement *replyXML in repliesXML) {
            NSString *rauthor = [[replyXML firstChildWithTag:kRauthor] stringValue];
            NSString *rcontent = [[replyXML firstChildWithTag:kRContent] stringValue];
            [mutableReplies addObject:@[rauthor, rcontent]];
        }
        self.replies = [NSArray arrayWithArray:mutableReplies];
    }
    
    return self;
}

@end
