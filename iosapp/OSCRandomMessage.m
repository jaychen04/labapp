//
//  OSCRandomMessage.m
//  iosapp
//
//  Created by ChanAetern on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCRandomMessage.h"

@implementation OSCRandomMessage

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _randomType = [[[xml firstChildWithTag:@"randomtype"] numberValue] intValue];
        _randomMessageID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _title = [[[xml firstChildWithTag:@"title"] stringValue] copy];
        _detail = [[[xml firstChildWithTag:@"detail"] stringValue] copy];
        _author = [[[xml firstChildWithTag:@"author"] stringValue] copy];
        _authorID = [[[xml firstChildWithTag:@"authorid"] numberValue] longLongValue];
        _portraitURL = [NSURL URLWithString:[[[xml firstChildWithTag:@"image"] stringValue] copy]];
        _pubDate = [[[xml firstChildWithTag:@"pubDate"] stringValue] copy];
        _commentCount = [[[xml firstChildWithTag:@"commentCount"] numberValue] intValue];
        _url = [NSURL URLWithString:[[[xml firstChildWithTag:@"url"] stringValue] copy]];
        
        ONOXMLElement *newsTypeXML = [xml firstChildWithTag:@"newstype"];
        _newsType = @{
                      @"type": [[[newsTypeXML firstChildWithTag:@"type"] stringValue] copy],
                      @"authorid2": @([[[newsTypeXML firstChildWithTag:@"authorid2"] numberValue] longLongValue]),
                      @"eventurl": [NSURL URLWithString:[[[newsTypeXML firstChildWithTag:@"eventurl"] stringValue] copy]]
                      };
    }
    
    return self;
}

@end
