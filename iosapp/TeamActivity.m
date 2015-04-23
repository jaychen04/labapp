//
//  TeamActivity.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamActivity.h"
#import "TeamMember.h"

#import <UIKit/UIKit.h>

@implementation TeamActivity

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _activityID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _type = [[[xml firstChildWithTag:@"type"] numberValue] intValue];
        _appID = [[[xml firstChildWithTag:@"appid"] numberValue] intValue];
        _appName = [[xml firstChildWithTag:@"appName"] stringValue];
        _replyCount = [[[xml firstChildWithTag:@"reply"] numberValue] intValue];
        _createTime = [[xml firstChildWithTag:@"createTime"] stringValue];
        
        ONOXMLElement *bodyXML = [xml firstChildWithTag:@"body"];
        _title = [[bodyXML firstChildWithTag:@"title"] stringValue];
        _detail = [[bodyXML firstChildWithTag:@"detail"] stringValue];
        _code = [[bodyXML firstChildWithTag:@"code"] stringValue];
        _codeType = [[bodyXML firstChildWithTag:@"codeType"] stringValue];
        _imageURL = [NSURL URLWithString:[[bodyXML firstChildWithTag:@"image"] stringValue]];
        _originImageURL = [NSURL URLWithString:[[bodyXML firstChildWithTag:@"imageOrigin"] stringValue]];
        
        ONOXMLElement *authorXML = [xml firstChildWithTag:@"author"];
        _author = [[TeamMember alloc] initWithXML:authorXML];
    }
    
    return self;
}

- (NSAttributedString *)attributedTittle
{
    if (!_attributedTittle) {
        _attributedTittle = [[NSAttributedString alloc] initWithData:[_title dataUsingEncoding:NSUnicodeStringEncoding]
                                                             options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                  documentAttributes:nil
                                                               error:nil];
    }
    
    return _attributedTittle;
}

@end
