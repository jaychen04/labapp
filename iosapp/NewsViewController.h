//
//  NewsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(int, NewsType)
{
    NewsTypeAllType = 0,
    NewsTypeNews,
    NewsTypeSynthesis,
    NewsTypeSoftwareRenew,
};

@interface NewsViewController : OSCObjsViewController

- (instancetype)initWithNewsType:(NewsType)type;

@end
