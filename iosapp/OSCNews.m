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
        _newsID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        _pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        ONOXMLElement *newsType = [xml firstChildWithTag:kNewsType];
        _type = [[[newsType firstChildWithTag:kType] numberValue] intValue];
        _attachment = [[newsType firstChildWithTag:kAttachment] stringValue];
        _authorUID2 = [[[newsType firstChildWithTag:kAuthorUID2] numberValue] longLongValue];
    }
    
    return self;
}

@end
