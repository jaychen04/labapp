//
//  OSCTweet.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "OSCTweet.h"

static NSString * const kID = @"id";
static NSString * const kPortrait = @"portrait";
static NSString * const kAuthor = @"author";
static NSString * const kAuthorID = @"authorid";
static NSString * const kBody = @"body";
static NSString * const kAppclient = @"appclient";
static NSString * const kCommentCount = @"commentCount";
static NSString * const kPubDate = @"pubDate";
static NSString * const kImgSmall = @"imgSmall";
static NSString * const kImgBig = @"imgBig";
static NSString * const kAttach = @"attach";

@implementation OSCTweet

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _tweetID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        _body = [[xml firstChildWithTag:kBody] stringValue];
        _appclient = [[[xml firstChildWithTag:kAppclient] numberValue] intValue];
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        _pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        // 附图
        NSString *imageURLStr = [[xml firstChildWithTag:kImgSmall] stringValue];
        _hasAnImage = ![imageURLStr isEqualToString:@""];
        _smallImgURL = [NSURL URLWithString:imageURLStr];
        _bigImgURL = [NSURL URLWithString:[[xml firstChildWithTag:kImgBig] stringValue]];
        
        // 语音信息
        _attach = [[xml firstChildWithTag:kAttach] stringValue];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _tweetID == ((OSCTweet *)object).tweetID;
    }
    
    return NO;
}

@end
