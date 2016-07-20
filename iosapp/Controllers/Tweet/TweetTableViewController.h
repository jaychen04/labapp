//
//  TweetTableViewController.h
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(NSUInteger, NewTweetsType)
{
    NewTweetsTypeAllTweets,
    NewTweetsTypeHotestTweets,
    NewTweetsTypeOwnTweets,
};

@interface TweetTableViewController : OSCObjsViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithTweetsType:(NewTweetsType)type;
- (instancetype)initWithUserID:(int64_t)userID;
- (instancetype)initWithSoftwareID:(int64_t)softwareID;
- (instancetype)initWithTopic:(NSString *)topic;

//新接口
-(instancetype)initTweetListWithType:(NewTweetsType)type;
@end
