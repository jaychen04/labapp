//
//  CommentsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(int, CommentsType)
{
    CommentsTypeNews = 1,
    CommentsTypePost,
    CommentsTypeTweet,
    CommentsTypeMessageCenter,
};

@interface CommentsViewController : OSCObjsViewController

@property (nonatomic, copy) UITableViewCell * (^otherSectionCell)(NSIndexPath *indexPath);
@property (nonatomic, copy) CGFloat (^heightForOtherSectionCell)(NSIndexPath *indexPath);

@property (nonatomic, copy) void (^didCommentSelected)(NSString *authorName);
@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithCommentsType:(CommentsType)type andID:(int64_t)objectID;

@end
