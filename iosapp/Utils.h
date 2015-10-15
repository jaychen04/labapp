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
#import "NSTextAttachment+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "UINavigationController+Router.h"
#import "NSDate+Util.h"


typedef NS_ENUM(NSUInteger, hudType) {
    hudTypeSendingTweet,
    hudTypeLoading,
    hudTypeCompleted
};

@class MBProgressHUD;

@interface Utils : NSObject

+ (NSDictionary *)emojiDict;

+ (NSAttributedString *)getAppclient:(int)clientType;

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews;
+ (NSString *)GenerateTags:(NSArray *)tags;

+ (NSAttributedString *)attributedTimeString:(NSDate *)date;

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString;
+ (NSMutableAttributedString *)attributedStringFromHTML:(NSString *)HTML;
+ (NSData *)compressImage:(UIImage *)image;
+ (NSString *)convertRichTextToRawText:(UITextView *)textView;

+ (NSString *)escapeHTML:(NSString *)originalHTML;
+ (NSString *)deleteHTMLTag:(NSString *)HTML;

+ (BOOL)isURL:(NSString *)string;
+ (NSInteger)networkStatus;
+ (BOOL)isNetworkExist;

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent;

+ (MBProgressHUD *)createHUD;
+ (UIImage *)createQRCodeFromString:(NSString *)string;

+ (NSAttributedString *)attributedCommentCount:(int)commentCount;

+ (NSString *)HTMLWithData:(NSDictionary *)data usingTemplate:(NSString *)templateName;



@end
