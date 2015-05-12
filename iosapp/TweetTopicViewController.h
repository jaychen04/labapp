//
//  TweetTopicViewController.h
//  iosapp
//
//  Created by 李萍 on 15/5/4.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface TweetTopicViewController : OSCObjsViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithTopic:(NSString *)topic;

@end
