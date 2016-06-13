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

@end
