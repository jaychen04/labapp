//
//  OSCReply.m
//  iosapp
//
//  Created by ChanAetern on 2/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCReply.h"

@implementation OSCReply

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _author  = [[xml firstChildWithTag:@"rauthor"] stringValue];
        _pubDate = [[xml firstChildWithTag:@"rpubDate"] stringValue];
        _content = [[xml firstChildWithTag:@"rcontent"] stringValue];
    }
    
    return self;
}

@end
