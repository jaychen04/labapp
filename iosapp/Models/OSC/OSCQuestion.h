//
//  OSCQuestion.h
//  iosapp
//
//  Created by 李萍 on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCQuestion : NSObject

@property (nonatomic, assign) long id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) long authorId;
@property (nonatomic, copy) NSString *authorPortrait;

@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, assign) int viewCount;

@end
