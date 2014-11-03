//
//  OSCPostDetails.m
//  iosapp
//
//  Created by ChanAetern on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCPostDetails.h"

static NSString *kID = @"id";
static NSString *kTitle = @"title";
static NSString *kURL = @"url";
static NSString *kPortrait = @"portrait";
static NSString *kBody = @"body";
static NSString *kAuthor = @"author";
static NSString *kAuthorID = @"authorid";
static NSString *kAnswerCount = @"answerCount";
static NSString *kViewCount = @"viewCount";
static NSString *kPubDate = @"pubDate";
static NSString *kFavorite = @"favorite";
static NSString *kTags = @"tags";
static NSString *kTag = @"tag";

@implementation OSCPostDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        self.postID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.title = [[xml firstChildWithTag:kTitle] stringValue];
        self.url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
        self.portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        self.body = [[xml firstChildWithTag:kBody] stringValue];
        self.author = [[xml firstChildWithTag:kAuthor] stringValue];
        self.authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        self.answerCount = [[[xml firstChildWithTag:kAnswerCount] numberValue] intValue];
        self.viewCount = [[[xml firstChildWithTag:kViewCount] numberValue] intValue];
        
        NSMutableArray *mutableTags = [NSMutableArray new];
        NSArray *tagsXML = [xml childrenWithTag:kTags];
        for (ONOXMLElement *tagXML in tagsXML) {
            NSString *tag = [[tagXML firstChildWithTag:kTag] stringValue];
            [mutableTags addObject:tag];
        }
        self.tags = [NSArray arrayWithArray:mutableTags];
    }
    
    return self;
}

@end
