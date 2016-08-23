//
//  AtMeItem.h
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSCOrigin,OSCReceiver;
@interface AtMeItem : NSObject

@property (nonatomic, strong) OSCReceiver *author;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) OSCOrigin *origin;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) NSInteger appClient;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger commentCount;

@end


@interface OSCOrigin : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) NSInteger type;

@end


@interface OSCReceiver : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portrait;

@end

