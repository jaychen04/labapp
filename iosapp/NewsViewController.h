//
//  NewsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(int, NewsListType)
{
    NewsListTypeAllType = 0,
    NewsListTypeNews,
    NewsListTypeSynthesis,
    NewsListTypeSoftwareRenew,
};

@interface NewsViewController : OSCObjsViewController

- (instancetype)initWithNewsListType:(NewsListType)type;

@end
