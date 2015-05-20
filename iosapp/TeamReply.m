//
//  TeamReply.m
//  iosapp
//
//  Created by AeternChan on 5/8/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamReply.h"

@implementation TeamReply

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _replyID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _type = [[[xml firstChildWithTag:@"type"] numberValue] intValue];
        _appclient = [[[xml firstChildWithTag:@"appclient"] numberValue] intValue];
        _appName = [[xml firstChildWithTag:@"appName"] stringValue];
        _content = [[xml firstChildWithTag:@"content"] stringValue];
        _createTime = [[xml firstChildWithTag:@"createTime"] stringValue];
        
        ONOXMLElement *authorXML = [xml firstChildWithTag:@"author"];
        _author = [[TeamMember alloc] initWithXML:authorXML];
    }
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _replyID == ((TeamReply *)object).replyID;
    }
    
    return NO;
}


@end
