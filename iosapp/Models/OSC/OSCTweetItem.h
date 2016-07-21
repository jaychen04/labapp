//
//  OSCTweetItem.h
//  iosapp
//
//  Created by Graphic-one on 16/7/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSCTweetAuthor,OSCTweetCode,OSCTweetAudio,OSCTweetImages;

@interface OSCTweetItem : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) NSInteger appClient;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, strong) OSCTweetAuthor *author;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger likeCount;

@property (nonatomic, strong) NSArray<OSCTweetAudio *> *audio;

@property (nonatomic, strong) OSCTweetCode *code;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, strong) NSArray<OSCTweetImages *> *images;

@property (nonatomic, assign) BOOL liked;

@property (nonatomic, copy) NSString *content;


@end

#pragma mark -
#pragma mark --- 动弹作者
@interface OSCTweetAuthor : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portrait;

@end

#pragma mark -
#pragma mark --- 动弹Code
@interface OSCTweetCode : NSObject

@property (nonatomic, copy) NSString *brush;

@property (nonatomic, copy) NSString *content;

@end

#pragma mark -
#pragma mark --- 动弹音频 && 视频
@interface OSCTweetAudio : NSObject

@property (nonatomic, copy) NSString *href;

@property (nonatomic, assign) NSInteger timeSpan;

@end

#pragma mark -
#pragma mark --- 动弹图片
@interface OSCTweetImages : NSObject

@property (nonatomic, copy) NSString *thumb;//小图

@property (nonatomic, copy) NSString *href;//大图

@end

