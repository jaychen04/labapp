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
#import "UIImage+Util.h"

static NSString * const kKeyYears = @"years";
static NSString * const kKeyMonths = @"months";
static NSString * const kKeyDays = @"days";
static NSString * const kKeyHours = @"hours";
static NSString * const kKeyMinutes = @"minutes";

typedef NS_ENUM(NSUInteger, hudType) {
    hudTypeSendingTweet,
    hudTypeLoading,
    hudTypeCompleted
};

@class MBProgressHUD;

@interface Utils : NSObject

+ (NSString *)getAppclient:(int)clientType;
+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews;
+ (NSString *)GenerateTags:(NSArray *)tags;
+ (void)analysis:(NSString *)url andNavController:(UINavigationController *)navigationController;

+ (NSDictionary *)timeIntervalArrayFromString:(NSString *)dateStr;
+ (NSString *)intervalSinceNow:(NSString *)dateStr;
+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString;
+ (NSData *)compressImage:(UIImage *)image;
+ (NSString *)convertRichTextToRawText:(UITextView *)textView;
+ (NSString *)escapeHTML:(NSString *)originalHTML;
+ (BOOL)isURL:(NSString *)string;
+ (NSInteger)networkStatus;
+ (BOOL)isNetworkExist;

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent;

+ (MBProgressHUD *)createHUDInWindowOfView:(UIView *)view;
+ (UIImage *)createQRCodeFromString:(NSString *)string;



@end
