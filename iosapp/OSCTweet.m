//
//  OSCTweet.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "OSCTweet.h"
#import "OSCUser.h"

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

static NSString * const kLikeCount = @"likeCount";
static NSString * const kIsLike = @"isLike";
static NSString * const kLikeList = @"likeList";
static NSString * const kUser = @"user";


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
        
        // 点赞
        _likeCount = [[[xml firstChildWithTag:kLikeCount] numberValue] intValue];
        _isLike = [[[xml firstChildWithTag:kIsLike] numberValue] boolValue];
        
        _likeList = [NSMutableArray new];
        NSArray *likeListXML = [[xml firstChildWithTag:kLikeList] childrenWithTag:kUser];
        for (ONOXMLElement *userXML in likeListXML) {
            OSCUser *user = [[OSCUser alloc] initWithXML:userXML];
            [_likeList addObject:user];
        }
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


- (NSString *)likersString
{
    if (_likersString) {
        return _likersString;
    } else {
        NSMutableString *likeListString = [[NSMutableString alloc] initWithString:@""];
        
        if (_likeList.count > 0) {
            for (int names = 0; names < 3 && names < _likeList.count; names++) {
                OSCUser *user = _likeList[names];   //_likeList[_likeCount - 1 - names];
                
                [likeListString appendFormat:@"%@、", user.name];
            }
            [likeListString deleteCharactersInRange:NSMakeRange(likeListString.length - 1, 1)];
            if (_likeCount > 3) {
                [likeListString appendFormat:@"等%d人", _likeCount];
            } else {
                [likeListString appendFormat:@"%d人", _likeCount];
            }

            _likersString = [NSString stringWithFormat:@"👍%@觉得很赞", likeListString];
            return _likersString;
        } else {
            _likersString = @"";
            return _likersString;
        }
    }
}

- (NSString *)likersDetailString
{
    if (_likersString) {
        return _likersString;
    } else {
        NSMutableString *likeListString = [[NSMutableString alloc] initWithString:@""];
        
        if (_likeList.count > 0) {
            for (int names = 0; names < 10 && names < _likeList.count; names++) {
                OSCUser *user = _likeList[names];   //_likeList[_likeCount - 1 - names];
                
                [likeListString appendFormat:@"%@、", user.name];
            }
            [likeListString deleteCharactersInRange:NSMakeRange(likeListString.length - 1, 1)];
            if (_likeCount > 10) {
                [likeListString appendFormat:@"等%d人", _likeCount];
            } else {
                [likeListString appendFormat:@"%d人", _likeCount];
            }
            
            _likersString = [NSString stringWithFormat:@"👍%@觉得很赞", likeListString];
            return _likersString;
        } else {
            _likersString = @"";
            return _likersString;
        }
    }

}

@end
