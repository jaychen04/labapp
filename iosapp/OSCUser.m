//
//  OSCUser.m
//  iosapp
//
//  Created by chenhaoxiang on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCUser.h"

static NSString * const kID = @"uid";
static NSString * const kUserID = @"userid";
static NSString * const kLocation = @"location";
static NSString * const kFrom = @"from";
static NSString * const kName = @"name";
static NSString * const kFollowers = @"followers";
static NSString * const kFans = @"fans";
static NSString * const kScore = @"score";
static NSString * const kPortrait = @"portrait";
static NSString * const kExpertise = @"expertise";

@interface OSCUser ()

@property (readwrite, nonatomic, assign) int64_t userID;
@property (readwrite, nonatomic, strong) NSString *location;
@property (readwrite, nonatomic, strong) NSString *name;
@property (readwrite, nonatomic, assign) NSUInteger followersCount;
@property (readwrite, nonatomic, assign) NSUInteger fansCount;
@property (readwrite, nonatomic, assign) NSInteger score;
@property (readwrite, nonatomic, strong) NSURL *portraitURL;
@property (readwrite, nonatomic, strong) NSString *expertise;

@end


@implementation OSCUser

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (!self) {return nil;}
    // 有些API返回用<id>，有些地方用<userid>，这样写是为了简化处理
    _userID = [[[xml firstChildWithTag:kID] numberValue] longLongValue] | [[[xml firstChildWithTag:kUserID] numberValue] longLongValue];
    
    // 理由同上
    _location = [[xml firstChildWithTag:kLocation] stringValue];
    if (!_location) {_location = [[xml firstChildWithTag:kFrom] stringValue];}
    
    _name = [[xml firstChildWithTag:kName] stringValue];
    _followersCount = [[[xml firstChildWithTag:kFollowers] numberValue] unsignedLongValue];
    _fansCount = [[[xml firstChildWithTag:kFans] numberValue] unsignedLongValue];
    _score = [[[xml firstChildWithTag:kScore] numberValue] integerValue];
    _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
    _expertise = [[xml firstChildWithTag:kExpertise] stringValue];
    
    return self;
}

@end
