//
//  OSCPostDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 11/3/14.
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
        _postID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        _body = [[xml firstChildWithTag:kBody] stringValue];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _answerCount = [[[xml firstChildWithTag:kAnswerCount] numberValue] intValue];
        _viewCount = [[[xml firstChildWithTag:kViewCount] numberValue] intValue];
        _pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        NSMutableArray *mutableTags = [NSMutableArray new];
        NSArray *tagsXML = [xml childrenWithTag:kTags];
        for (ONOXMLElement *tagXML in tagsXML) {
            NSString *tag = [[tagXML firstChildWithTag:kTag] stringValue];
            [mutableTags addObject:tag];
        }
        _tags = [NSArray arrayWithArray:mutableTags];
    }
    
    return self;
}

@end
