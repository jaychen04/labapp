//
//  OSCNewsDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCNewsDetails.h"
#import "Utils.h"


@implementation OSCNewsDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        _newsID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:@"url"] stringValue]];
        _body = [[xml firstChildWithTag:@"body"] stringValue];
        _commentCount = [[[xml firstChildWithTag:@"commentCount"] numberValue] intValue];
        _author = [[xml firstChildWithTag:@"author"] stringValue];
        _authorID = [[[xml firstChildWithTag:@"authorid"] numberValue] longLongValue];
        _pubDate = [[xml firstChildWithTag:@"pubDate"] stringValue];
        _softwareLink = [NSURL URLWithString:[[xml firstChildWithTag:@"softwarelink"] stringValue]];
        _softwareName = [[xml firstChildWithTag:@"softwareName"] stringValue];
        _isFavorite = [[[xml firstChildWithTag:@"favorite"] numberValue] boolValue];
        NSMutableArray *mutableRelatives = [NSMutableArray new];
        NSArray *relativesXML = [[xml firstChildWithTag:@"relativies"] childrenWithTag:@"relative"];
        for (ONOXMLElement *relativeXML in relativesXML) {
            NSString *rTitle = [[relativeXML firstChildWithTag:@"rtitle"] stringValue];
            NSString *rURL = [[relativeXML firstChildWithTag:@"rurl"] stringValue];
            [mutableRelatives addObject:@[rTitle, rURL]];
        }
        _relatives = [NSArray arrayWithArray:mutableRelatives];
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
                               @"softwareLink": _softwareLink,
                               @"softwareName": _softwareName,
                               @"relatedInfo": [Utils generateRelativeNewsString:_relatives],
                               };
        
        _html = [Utils HTMLWithData:data usingTemplate:@"article"];
    }
    
    return _html;
}

@end
