//
//  OSCBlogDetail.h
//  iosapp
//
//  Created by Graphic-one on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSCBlogDetailRecommend , OSCBlogDetailComment;

@interface OSCBlogDetail : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *body;

@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, copy) NSString *authorPortrait;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) BOOL recommend;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL original;

@property (nonatomic, assign) NSInteger authorRelation;

@property (nonatomic, assign) NSInteger viewCount;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic,strong) NSArray<OSCBlogDetailRecommend* >* about;

@property (nonatomic,strong) NSArray<OSCBlogDetailComment* >* comments;

@end



@interface OSCBlogDetailRecommend : NSObject

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger viewCount;

@end



@interface OSCBlogDetailComment : NSObject

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) NSInteger appClient;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, copy) NSString *authorPortrait;

@end
