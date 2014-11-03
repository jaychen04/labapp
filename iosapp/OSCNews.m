//
//  OSCNews.m
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCNews.h"

static NSString * const kID = @"id";
static NSString * const kTitle = @"title";
static NSString * const kCommentCount = @"commentCount";
static NSString * const kAuthor = @"author";
static NSString * const kAuthorID = @"authorid";
static NSString * const kPubDate = @"pubDate";
static NSString * const kNewsType = @"newstype";
static NSString * const kType = @"type";
static NSString * const kAttachment = @"attachment";
static NSString * const kAuthorUID2 = @"authoruid2";

@implementation OSCNews

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        self.newsID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.title = [[xml firstChildWithTag:kTitle] stringValue];
        
        self.authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        self.author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        self.commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        self.pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        ONOXMLElement *newsType = [xml firstChildWithTag:kNewsType];
        self.type = [[[newsType firstChildWithTag:kType] numberValue] intValue];
        self.attachment = [[newsType firstChildWithTag:kAttachment] stringValue];
        self.authorUID2 = [[[newsType firstChildWithTag:kAuthorUID2] numberValue] longLongValue];
    }
    
    return self;
}

@end
