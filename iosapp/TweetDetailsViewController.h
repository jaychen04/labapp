//
//  TweetDetailsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentsViewController.h"

@class OSCTweet;

@interface TweetDetailsViewController : CommentsViewController

- (instancetype)initWithTweet:(OSCTweet *)tweet;

@end
