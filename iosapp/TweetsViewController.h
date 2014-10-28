//
//  TweetsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCObjsViewController.h"

typedef NS_ENUM(NSUInteger, TweetsType)
{
    TweetsTypeAllTweets,
    TweetsTypeHotestTweets,
    TweetsTypeOwnTweets,
};

@interface TweetsViewController : OSCObjsViewController

- (instancetype)initWithType:(TweetsType)type;

@end
