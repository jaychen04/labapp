//
//  OSCEvent.m
//  iosapp
//
//  Created by chenhaoxiang on 11/29/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCEvent.h"

NSString * const kID = @"uid";
NSString * const kMessage = @"message";
NSString * const kTweetImg = @"tweetimage";

NSString * const kAuthorID = @"authorid";
NSString * const kAuthor = @"author";
NSString * const kPortrait = @"portrait";

NSString * const kCatalog = @"catalog";
NSString * const kAppClient = @"appclient";
NSString * const kCommentCount = @"commentCount";
NSString * const kPubDate = @"pubDate";

NSString * const kObjectType = @"objecttype";
NSString * const kObjectTitle = @"objecttitle";
NSString * const kObjectID = @"objectid";
NSString * const kObjectName = @"objectname";
NSString * const kObjectBody = @"objectbody";
NSString * const kObjectCatalog = @"objectcatalog";


@implementation OSCEvent

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _eventID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _message = [[xml firstChildWithTag:kMessage] stringValue];
        _tweetImg = [NSURL URLWithString:[[xml firstChildWithTag:kTweetImg] stringValue]];
        
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        
        _catalog = [[[xml firstChildWithTag:kCatalog] numberValue] intValue];
        _appclient = [[[xml firstChildWithTag:kAppClient] numberValue] intValue];
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        _pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        _objectID = [[[xml firstChildWithTag:kObjectID] numberValue] longLongValue];
        _objectType = [[[xml firstChildWithTag:kObjectType] numberValue] intValue];
        _objectCatalog = [[[xml firstChildWithTag:kObjectCatalog] numberValue] intValue];
        _objectTitle = [[xml firstChildWithTag:kObjectTitle] stringValue];
        NSString *objectName = [[xml firstChildWithTag:kObjectName] stringValue];
        NSString *objectBody = [[xml firstChildWithTag:kObjectBody] stringValue];
        _objectReply = @[objectName, objectBody];
    }
    
    return self;
}

@end
