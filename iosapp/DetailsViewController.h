//
//  DetailsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DetailsType)
{
    DetailsTypeNews,
    DetailsTypeBlog,
    DetailsTypeSoftware,
};

@class OSCNews;
@class OSCBlog;

@interface DetailsViewController : UIViewController

- (instancetype)initWithNews:(OSCNews *)news;
- (instancetype)initWithBlog:(OSCBlog *)blog;

@end
