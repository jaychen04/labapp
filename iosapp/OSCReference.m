//
//  OSCReference.m
//  iosapp
//
//  Created by ChanAetern on 2/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCReference.h"

@implementation OSCReference

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _title = [[xml firstChildWithTag:@"refertitle"] stringValue];
        _body  = [[xml firstChildWithTag:@"referbody"] stringValue];
    }
    
    return self;
}

@end
