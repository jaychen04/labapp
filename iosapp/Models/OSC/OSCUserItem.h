//
//  OSCUserItem.h
//  iosapp
//
//  Created by Holden on 16/7/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfoMore;
@class UserInfoStatistics;

@interface OSCUserItem : NSObject

@property (nonatomic, assign) long id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSString *portrait;

@property (nonatomic, assign) int gender;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) int relation;


@property (nonatomic, strong) UserInfoMore *more;
@property (nonatomic, strong) UserInfoStatistics *statistics;


@end

/*
 节点 more
 */
@interface UserInfoMore : NSObject

@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *expertise;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, strong) NSString *joinDate;

@end

/*
 节点 statistics
 */
@interface UserInfoStatistics : NSObject

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int tweet;
@property (nonatomic, assign) int collect;
@property (nonatomic, assign) int fans;
@property (nonatomic, assign) int follow;
@property (nonatomic, assign) int blog;
@property (nonatomic, assign) int answer;
@property (nonatomic, assign) int discuss;

@end
