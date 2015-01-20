//
//  CommentsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(int, CommentType)
{
    CommentTypeNews = 1,
    CommentTypePost,
    CommentTypeTweet,
    CommentTypeMessageCenter,
    
    CommentTypeBlog,
    CommentTypeSoftware,
};

@interface CommentsViewController : OSCObjsViewController

@property (nonatomic, readwrite, assign) int64_t objectAuthorID;

@property (nonatomic, copy) UITableViewCell * (^otherSectionCell)(NSIndexPath *indexPath);
@property (nonatomic, copy) CGFloat (^heightForOtherSectionCell)(NSIndexPath *indexPath);

@property (nonatomic, copy) void (^didCommentSelected)(NSString *authorName);
@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID;

@end
