//
//  OSCBlog.m
//  iosapp
//
//  Created by ChanAetern on 10/30/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBlog.h"

static NSString * const kID = @"id";
static NSString * const kAuthor = @"authorname";
static NSString * const kAuthorID = @"authorid";
static NSString * const kTitle = @"title";
static NSString * const kCommentCount = @"commentCount";
static NSString * const kPubDate = @"pubDate";
static NSString * const kDocumentType = @"documentType";

@implementation OSCBlog

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _blogID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        _pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        _documentType = [[[xml firstChildWithTag:kDocumentType] numberValue] intValue];
    }
    
    return self;
}

@end
