//
//  TweetDetailNewTableViewController.h
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCComment.h"
#import "OSCTweet.h"

@interface TweetDetailNewTableViewController : UITableViewController
@property (nonatomic, assign) int64_t tweetID;
@property (nonatomic, strong)OSCTweet *currentTweet;

@property (nonatomic, copy) void (^didCommentSelected)(OSCComment *comment);
@property (nonatomic, copy) void (^didScroll)();
@property (nonatomic, copy) void (^didActivatedInputBar)();
//@property (nonatomic, copy) void (^didRegisterInputBar)();

-(void)loadTweetCommentListIsrefresh:(BOOL)isRefresh;
@end
