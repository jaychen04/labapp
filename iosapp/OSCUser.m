//
//  OSCUser.m
//  iosapp
//
//  Created by chenhaoxiang on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCUser.h"

NSString * const kID = @"uid";
NSString * const kLocation = @"location";
NSString * const kName = @"name";
NSString * const kFollowers = @"followers";
NSString * const kFans = @"fans";
NSString * const kScore = @"score";
NSString * const kPortrait = @"portrait";

@interface OSCUser ()

@property (readwrite, nonatomic, assign) int64_t userID;
@property (readwrite, nonatomic, strong) NSString *location;
@property (readwrite, nonatomic, strong) NSString *name;
@property (readwrite, nonatomic, assign) NSUInteger followersCount;
@property (readwrite, nonatomic, assign) NSUInteger fansCount;
@property (readwrite, nonatomic, assign) NSInteger score;
@property (readwrite, nonatomic, copy) NSURL *portraitURL;

@end


@implementation OSCUser

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (!self) {return nil;}
    
    self.userID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
    self.location = [[xml firstChildWithTag:kLocation] stringValue];
    self.name = [[xml firstChildWithTag:kName] stringValue];
    self.followersCount = [[[xml firstChildWithTag:kFollowers] numberValue] unsignedLongValue];
    self.fansCount = [[[xml firstChildWithTag:kFans] numberValue] unsignedLongValue];
    self.score = [[[xml firstChildWithTag:kScore] numberValue] integerValue];
    self.portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
    
    return self;
}

@end
