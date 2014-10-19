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
        self.tweetID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        
        self.portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        self.author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        self.body = [[xml firstChildWithTag:kBody] stringValue];
        self.appclient = [[[xml firstChildWithTag:kAppclient] numberValue] intValue];
        self.commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        self.pubDate = [[xml firstChildWithTag:kPubDate] stringValue];
        
        // 附图
        self.smallImgURL = [NSURL URLWithString:[[xml firstChildWithTag:kImgSmall] stringValue]];
        self.bigImgURL = [NSURL URLWithString:[[xml firstChildWithTag:kImgBig] stringValue]];
        
        // 语音信息
        self.attach = [[xml firstChildWithTag:kAttach] stringValue];
    }
    
    return self;
}

@end
