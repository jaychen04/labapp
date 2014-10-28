//
//  PostsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(NSUInteger, PostsType)
{
    PostsTypeQA = 1,
    PostsTypeShare,
    PostsTypeSynthesis,
    PostsTypeCaree,
    PostsTypeSiteManager,
};

@interface PostsViewController : OSCObjsViewController

- (instancetype)initWithType:(PostsType)type;

@end
