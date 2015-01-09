//
//  Utils.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "UIImageView+Util.h"

@class OSCUser;

@interface Utils : NSObject

+ (NSString *)getAppclient:(int)clientType;
+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews;
+ (NSString *)GenerateTags:(NSArray *)tags;
+ (void)analysis:(NSString *)url andNavController:(UINavigationController *)navigationController;

+ (NSString *)intervalSinceNow:(NSString *)dateStr;
+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString;
+ (NSData *)compressImage:(UIImage *)image;

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent;

@end
