//
//  OSCPrivateChat.h
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger,OSCPrivateChatType){
    OSCPrivateChatTypeText = 1,
    OSCPrivateChatTypeImage = 3,
    OSCPrivateChatTypeFile = 5
};

@class OSCSender;
@interface OSCPrivateChat : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) OSCSender *sender;

@property (nonatomic, copy) NSString *resource;

@property (nonatomic,assign) OSCPrivateChatType privateChatType;

//以下是布局信息
@property (nonatomic,assign) CGFloat rowHeight;///< 整体行高 全部消息类型都用到

@property (nonatomic,assign) CGRect popFrame;///< 气泡大小 全部消息类型都用到

@property (nonatomic,assign) CGRect textFrame;///< 文本消息类型

@property (nonatomic,assign) CGRect imageFrame;///< 图片消息类型

@property (nonatomic,assign) CGRect fileFrame;///< 文件消息类型

@end

@interface OSCSender : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portrait;

@property (nonatomic,assign,getter=isBySelf) BOOL bySelf;

@end

