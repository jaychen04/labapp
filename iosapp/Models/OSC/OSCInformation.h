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
    InformationTypeLinkNews,
    InformationTypeSoftWare,
    InformationTypeForum,
    InformationTypeBlog,
    InformationTypeDefaultNews,
    InformationTypeTranslation
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


@interface OSCInformationBanner : NSObject

@property (nonatomic,strong) NSString* name;

@property (nonatomic,strong) NSString* detail;

@property (nonatomic,strong) NSString* img;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) NSInteger type;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* time;

@end