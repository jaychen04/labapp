//
//  Utils.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Util.h"
#import "UIColor+Util.h"

@interface Utils : NSObject

+ (NSString *)getAppclient:(int)clientType;
+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews;
+ (NSString *)GenerateTags:(NSArray *)tags;

+ (NSString *)intervalSinceNow:(NSString *)dateStr;

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent;

@end
