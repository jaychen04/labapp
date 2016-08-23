//
//  MessageItem.h
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageSender;

@interface MessageItem : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) MessageSender *sender;

@property (nonatomic, copy) NSString *resource;


@end

@interface MessageSender : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portrait;

@end

