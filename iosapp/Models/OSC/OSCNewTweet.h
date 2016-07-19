//
//  OSCNewTweet.h
//  iosapp
//
//  Created by 李萍 on 16/7/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSCAuthor;
@interface OSCNewTweet : NSObject

@property (nonatomic, assign) long Id;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) int appClient;
@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *href;


@property (nonatomic, strong) OSCAuthor *author;
@property (nonatomic, strong) NSDictionary *code;
@property (nonatomic, strong) NSArray *audio;
@property (nonatomic, strong) NSArray *images;

@end

@interface OSCAuthor : NSObject

@property (nonatomic, assign) long Id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *portrait;

@end