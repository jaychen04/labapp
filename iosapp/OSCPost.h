//
//  OSCPost.h
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCPost : OSCBaseObject

@property (nonatomic, assign) int64_t postID;
@property (nonatomic, strong) NSURL *portraitURL;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) int64_t authorID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int answerCount;
@property (nonatomic, assign) int viewCount;
@property (nonatomic, copy) NSString *pubDate;

@end
