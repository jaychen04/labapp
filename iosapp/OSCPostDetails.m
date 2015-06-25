//
//  OSCPostDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCPostDetails.h"
#import "Utils.h"


@implementation OSCPostDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        _postID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:@"url"] stringValue]];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:@"portrait"] stringValue]];
        _body = [[xml firstChildWithTag:@"body"] stringValue];
        _author = [[xml firstChildWithTag:@"author"] stringValue];
        _authorID = [[[xml firstChildWithTag:@"authorid"] numberValue] longLongValue];
        _answerCount = [[[xml firstChildWithTag:@"answerCount"] numberValue] intValue];
        _viewCount = [[[xml firstChildWithTag:@"viewCount"] numberValue] intValue];
        _isFavorite = [[[xml firstChildWithTag:@"favorite"] numberValue] boolValue];
        _pubDate = [[xml firstChildWithTag:@"pubDate"] stringValue];
        
        ONOXMLElement *eventElement = [xml firstChildWithTag:@"event"];
        _status = [[[eventElement firstChildWithTag:@"status"] numberValue] intValue];
        _applyStatus = [[[eventElement firstChildWithTag:@"applyStatus"] numberValue] intValue];
        _category    = [[[eventElement firstChildWithTag:@"category"] numberValue] intValue];
        _signUpUrl = [NSURL URLWithString:[[eventElement firstChildWithTag:@"url"] stringValue]];
        
        NSMutableArray *mutableTags = [NSMutableArray new];
        NSArray *tagsXML = [xml childrenWithTag:@"tags"];
        for (ONOXMLElement *tagXML in tagsXML) {
            NSString *tag = [[tagXML firstChildWithTag:@"tag"] stringValue];
            [mutableTags addObject:tag];
        }
        _tags = [NSArray arrayWithArray:mutableTags];
    }
    
    return self;
}

- (NSString *)html
{
    if (!_html) {
        NSDictionary *data = @{
                               @"title": [Utils escapeHTML:_title],
                               @"authorID": @(_authorID),
                               @"authorName": _author,
                               @"timeInterval": [Utils intervalSinceNow:_pubDate],
                               @"content": _body,
                               @"tags": [Utils GenerateTags:_tags],
                               };
        
        _html = [Utils HTMLWithData:data usingTemplate:@"article"];
    }
    
    return _html;
}

@end
