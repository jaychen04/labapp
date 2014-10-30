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
        self.blogID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.author = [[xml firstChildWithTag:kAuthor] stringValue];
        self.authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        self.title = [[xml firstChildWithTag:kTitle] stringValue];
        self.commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        self.pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        self.documentType = [[[xml firstChildWithTag:kDocumentType] numberValue] intValue];
    }
    
    return self;
}

@end
