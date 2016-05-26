//
//  OSCInformation.h
//  iosapp
//
//  Created by Graphic-one on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, InformationType)
{
    InformationTypeLinkNews,//链接新闻
    InformationTypeSoftWare,//软件推荐
    InformationTypeForum,//讨论区帖子
    InformationTypeBlog,//博客
    InformationTypeTranslation,//翻译文章
    InformationTypeActivityType//活动类型
};

@interface OSCInformation : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* title;

@property (nonatomic,strong) NSString* body;

@property (nonatomic,assign) NSInteger commentCount;

@property (nonatomic,strong) NSString* author;

@property (nonatomic,assign) InformationType type;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) BOOL recommend;

@property (nonatomic,strong) NSString* pubDate;

@end


