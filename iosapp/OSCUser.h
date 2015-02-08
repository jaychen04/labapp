//
//  OSCUser.h
//  iosapp
//
//  Created by chenhaoxiangs on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCUser : OSCBaseObject

@property (readonly, nonatomic, assign) int64_t userID;
@property (readonly, nonatomic, copy) NSString *location;
@property (readonly, nonatomic, copy) NSString *name;
@property (readonly, nonatomic, assign) int followersCount;
@property (readonly, nonatomic, assign) int fansCount;
@property (readonly, nonatomic, assign) int score;
@property (readonly, nonatomic, assign) int relationship;
@property (readonly, nonatomic, strong) NSURL *portraitURL;
@property (readonly, nonatomic, copy) NSString *expertise;
@property (readonly, nonatomic, copy) NSString *latestOnlineTime;

@end
