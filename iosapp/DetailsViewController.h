//
//  DetailsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "BottomBarViewController.h"

typedef NS_ENUM(NSUInteger, DetailsType)
{
    DetailsTypeNews,
    DetailsTypeBlog,
    DetailsTypeSoftware,
};

@class OSCNews;
@class OSCBlog;
@class OSCPost;

@interface DetailsViewController : BottomBarViewController

- (instancetype)initWithNews:(OSCNews *)news;
- (instancetype)initWithBlog:(OSCBlog *)blog;
- (instancetype)initWithPost:(OSCPost *)post;

@end
