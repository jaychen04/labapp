//
//  OSCBlogDetails.m
//  iosapp
//
//  Created by ChanAetern on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBlogDetails.h"

static NSString *kID = @"id";
static NSString *kTitle = @"title";
static NSString *kURL = @"url";
static NSString *kBody = @"body";
static NSString *kCommentCount = @"commentCount";
static NSString *kAuthor = @"author";
static NSString *kAuthorID = @"authorid";
static NSString *kPubDate = @"pubDate";
static NSString *kFavorite = @"favorite";
static NSString *kWhere = @"where";
static NSString *kDocumentType = @"documentType";

@implementation OSCBlogDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        self.blogID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.title = [[xml firstChildWithTag:kTitle] stringValue];
        self.url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
        self.body = [[xml firstChildWithTag:kBody] stringValue];
        self.commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        self.author = [[xml firstChildWithTag:kAuthor] stringValue];
        self.authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        self.pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        self.favoriteCount = [[[xml firstChildWithTag:kFavorite] numberValue] intValue];
        self.where = [[xml firstChildWithTag:kWhere] stringValue];
        self.documentType = [[[xml firstChildWithTag:kDocumentType] numberValue] intValue];
    }
    
    return self;
}

@end
