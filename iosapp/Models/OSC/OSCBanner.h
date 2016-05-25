//
//  OSCBanner.h
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSInteger , BannerType){
    BannerTypeNews = 1,//资讯
    BannerTypeActivity,//活动
    BannerTypeQA,//问答
    BannerTypeBlog,//博客
    BannerTypeSoftWare,//开源软件
    BannerTypeOther//外链Href，此时href有值，id无值
};

@interface OSCBanner : NSObject

@property (nonatomic,strong) NSString* name;

@property (nonatomic,strong) NSString* detail;

@property (nonatomic,strong) NSString* img;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) BannerType type;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* time;

@end
