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
@property (readonly, nonatomic, strong) NSString *location;
@property (readonly, nonatomic, strong) NSString *name;
@property (readonly, nonatomic, assign) NSUInteger followersCount;
@property (readonly, nonatomic, assign) NSUInteger fansCount;
@property (readonly, nonatomic, assign) NSInteger score;
@property (readonly, nonatomic, copy) NSURL *portraitURL;

@end
