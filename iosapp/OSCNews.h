//
//  OSCNews.h
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

typedef NS_ENUM(NSUInteger, NewsType)
{
    NewsTypeStandardNews,
    NewsTypeSoftWare,
    NewsTypeQA,
    NewsTypeBlog
};

@interface OSCNews : OSCBaseObject

@property (nonatomic, assign) int64_t newsID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) int64_t authorID;
@property (nonatomic, assign) NewsType type;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *attachment;
@property (nonatomic, assign) int64_t authorUID2;

@end
