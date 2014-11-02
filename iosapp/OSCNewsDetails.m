//
//  OSCNewsDetails.m
//  iosapp
//
//  Created by ChanAetern on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCNewsDetails.h"

static NSString *kID = @"id";
static NSString *kTitle = @"title";
static NSString *kURL = @"url";
static NSString *kBody = @"body";
static NSString *kCommentCount = @"commentCount";
static NSString *kAuthor = @"author";
static NSString *kAuthorID = @"authorid";
static NSString *kPubDate = @"pubDate";
static NSString *kSoftwareLink = @"softwarelink";
static NSString *kSoftwareName = @"softwareName";
static NSString *kFavorite = @"favorite";
static NSString *kRelatives = @"relativies";
static NSString *kRelative = @"relative";
static NSString *kRTitle = @"rtitle";
static NSString *kRURL = @"rurl";

@implementation OSCNewsDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        self.newsID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.title = [[xml firstChildWithTag:kTitle] stringValue];
        self.url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
        self.body = [[xml firstChildWithTag:kBody] stringValue];
        self.commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        self.author = [[xml firstChildWithTag:kAuthor] stringValue];
        self.authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        self.pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        self.softwareLink = [NSURL URLWithString:[[xml firstChildWithTag:kSoftwareLink] stringValue]];
        self.softwareName = [[xml firstChildWithTag:kSoftwareName] stringValue];
        self.favoriteCount = [[[xml firstChildWithTag:kFavorite] numberValue] intValue];
        NSMutableArray *mutableRelatives = [NSMutableArray new];
        NSArray *relativesXML = [[xml firstChildWithTag:kRelatives] childrenWithTag:kRelative];
        for (ONOXMLElement *relativeXML in relativesXML) {
            NSString *rTitle = [[relativeXML firstChildWithTag:kRTitle] stringValue];
            NSString *rURL = [[relativeXML firstChildWithTag:kRURL] stringValue];
            [mutableRelatives addObject:@[rTitle, rURL]];
        }
        self.relatives = [NSArray arrayWithArray:mutableRelatives];
    }
    
    return self;
}

@end
