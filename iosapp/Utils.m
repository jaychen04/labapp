//
//  Utils.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"
#import "OSCTweet.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCPost.h"
#import "UserDetailsViewController.h"
#import "DetailsViewController.h"
#import "PostsViewController.h"
#import "ImageViewerController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import <MBProgressHUD.h>
#import <objc/runtime.h>
#import <Reachability.h>

@implementation Utils


#pragma mark - 处理API返回信息

+ (NSString *)getAppclient:(int)clientType
{
    switch (clientType) {
        case 0:
        case 1: return @"";
        case 2: return @"来自手机";
        case 3: return @"来自Android";
        case 4: return @"来自iPhone";
        case 5: return @"来自Windows Phone";
        case 6: return @"来自微信";
            
        default: return @"";
    }
}

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews
{
    if (relativeNews == nil || [relativeNews count] == 0) {
        return @"";
    }
    
    NSString *middle = @"";
    for (NSArray *news in relativeNews) {
        middle = [NSString stringWithFormat:@"%@<a href=%@ style='text-decoration:none'>%@</a><p/>", middle, news[1], news[0]];
    }
    return [NSString stringWithFormat:@"<hr/>相关文章<div style='font-size:14px'><p/>%@</div>", middle];
}

+ (NSString *)GenerateTags:(NSArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    } else {
        NSString *result = @"";
        for (NSString *tag in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;", result, tag, tag];
        }
        return result;
    }
}


+ (void)analysis:(NSString *)url andNavController:(UINavigationController *)navigationController
{
    //判断是否包含 oschina.net 来确定是不是站内链接
    NSRange range = [url rangeOfString:@"oschina.net"];
    if (range.length <= 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else {
        //站内链接
        
        url = [url substringFromIndex:7];
        NSArray *pathComponents = [url pathComponents];
        NSString *prefix = [pathComponents[0] componentsSeparatedByString:@"."][0];
        UIViewController *viewController;
        
        if ([prefix isEqualToString:@"my"])
        {
            if (pathComponents.count == 2) {
                // 个人专页 my.oschina.net/dong706
                
                viewController = [[UserDetailsViewController alloc] initWithUserName:pathComponents[1]];
                viewController.navigationItem.title = @"用户详情";
            } else if (pathComponents.count == 3) {
                // 个人专页 my.oschina.net/u/12
                
                if ([pathComponents[1] isEqualToString:@"u"]) {
                    viewController= [[UserDetailsViewController alloc] initWithUserID:[pathComponents[2] longLongValue]];
                    viewController.navigationItem.title = @"用户详情";
                }
            } else if (pathComponents.count == 4) {
                NSString *type = pathComponents[2];
                if ([type isEqualToString:@"blog"]) {
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeBlog;
                    news.attachment = pathComponents[3];
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"博客详情";
                } else if ([type isEqualToString:@"tweet"]){
                    OSCTweet *tweet = [OSCTweet new];
                    tweet.tweetID = [pathComponents[3] longLongValue];
                    viewController = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
                    viewController.navigationItem.title = @"动弹详情";
                }
            } else if(pathComponents.count == 5) {
                NSString *type = pathComponents[3];
                if ([type isEqualToString:@"blog"]) {
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeBlog;
                    news.attachment = pathComponents[4];
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"博客详情";
                }
            }
        } else if ([prefix isEqualToString:@"www"]) {
            //新闻,软件,问答
            NSArray *urlComponents = [url componentsSeparatedByString:@"/"];
            NSUInteger count = urlComponents.count;
            if (count >= 3) {
                NSString *type = urlComponents[1];
                if ([type isEqualToString:@"news"]) {
                    // 新闻
                    // www.oschina.net/news/27259/mobile-internet-market-is-small
                    
                    int64_t newsID = [urlComponents[2] longLongValue];
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeStandardNews;
                    news.newsID = newsID;
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"资讯详情";
                } else if ([type isEqualToString:@"p"]) {
                    // 软件 www.oschina.net/p/jx
                    
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeSoftWare;
                    news.attachment = urlComponents[2];
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"软件详情";
                } else if ([type isEqualToString:@"question"]) {
                    // 问答
                    
                    if (count == 3) {
                        // 问答 www.oschina.net/question/12_45738
                        
                        NSArray *IDs = [urlComponents[2] componentsSeparatedByString:@"_"];
                        if ([IDs count] >= 2) {
                            OSCPost *post = [OSCPost new];
                            post.postID = [IDs[1] longLongValue];
                            viewController = [[DetailsViewController alloc] initWithPost:post];
                            viewController.navigationItem.title = @"帖子详情";
                        }
                    } else if (count >= 4) {
                        // 问答-标签 www.oschina.net/question/tag/python
                        
                        NSString *tag = urlComponents.lastObject;
                        
                        viewController = [PostsViewController new];
                        ((PostsViewController *)viewController).generateURL = ^NSString * (NSUInteger page) {
                            return [NSString stringWithFormat:@"%@%@?tag=%@&pageIndex=0&%@", OSCAPI_PREFIX, OSCAPI_POSTS_LIST, tag, OSCAPI_SUFFIX];
                        };
                        
                        ((PostsViewController *)viewController).objClass = [OSCPost class];
                        viewController.title = tag;
                    }
                }
            }
        } else if ([prefix isEqualToString:@"static"]) {
            ImageViewerController *imageViewerVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]]];
            
            [navigationController presentViewController:imageViewerVC animated:YES completion:nil];
            
            return;
        }
        if (viewController) {
            [navigationController pushViewController:viewController animated:YES];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]]];
        }
    }
}






#pragma mark - 通用

#pragma mark 信息处理

+ (NSDictionary *)timeIntervalArrayFromString:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *compsPast = [calendar components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger years = [compsNow year] - [compsPast year];
    NSInteger months = [compsNow month] - [compsPast month] + years * 12;
    NSInteger days = [compsNow day] - [compsPast day] + months * 30;
    NSInteger hours = [compsNow hour] - [compsPast hour] + days * 24;
    NSInteger minutes = [compsNow minute] - [compsPast minute] + hours * 60;
    
    return @{
             kKeyYears:  @(years),
             kKeyMonths: @(months),
             kKeyDays:   @(days),
             kKeyHours:  @(hours),
             kKeyMinutes:@(minutes)
             };
}

+ (NSString *)intervalSinceNow:(NSString *)dateStr
{
    NSDictionary *dic = [Utils timeIntervalArrayFromString:dateStr];
    //NSInteger years = [[dic objectForKey:kKeyYears] integerValue];
    NSInteger months = [[dic objectForKey:kKeyMonths] integerValue];
    NSInteger days = [[dic objectForKey:kKeyDays] integerValue];
    NSInteger hours = [[dic objectForKey:kKeyHours] integerValue];
    NSInteger minutes = [[dic objectForKey:kKeyMinutes] integerValue];
    
    if (minutes < 1) {
        return @"刚刚";
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%ld分钟前", (long)minutes];
    } else if (hours < 24) {
        return [NSString stringWithFormat:@"%ld小时前", (long)hours];
    } else if (hours < 48 && days == 1) {
        return @"昨天";
    } else if (days < 30) {
        return [NSString stringWithFormat:@"%ld天前", (long)days];
    } else if (days < 60) {
        return @"一个月前";
    } else if (months < 12) {
        return [NSString stringWithFormat:@"%ld个月前", (long)months];
    } else {
        NSArray *arr = [dateStr componentsSeparatedByString:@"T"];
        return arr[0];
    }
}


// 参考 http://www.cnblogs.com/ludashi/p/3962573.html

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString
{
    NSMutableAttributedString *emojiString = [[NSMutableAttributedString alloc] initWithString:rawString];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emoji" ofType:@"plist"];
    NSDictionary *emoji = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (!re) {NSLog(@"%@", error.localizedDescription);}
    
    NSArray *resultsArray = [re matchesInString:rawString options:0 range:NSMakeRange(0, rawString.length)];
    
    NSMutableArray *emojiArray = [NSMutableArray arrayWithCapacity:resultsArray.count];
    
    for (NSTextCheckingResult *match in resultsArray) {
        NSRange range = [match range];
        NSString *emojiName = [rawString substringWithRange:range];
        
        if (emoji[emojiName]) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:emoji[emojiName]];
            
            NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            
            NSDictionary *emojiToReplace = @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]};
            [emojiArray addObject:emojiToReplace];
        }
    }
    
    for (NSInteger i = emojiArray.count -1; i >= 0; i--) {
        NSRange range;
        [emojiArray[i][@"range"] getValue:&range];
        [emojiString replaceCharactersInRange:range withAttributedString:emojiArray[i][@"image"]];
    }
    
    return emojiString;
}

+ (NSString *)convertRichTextToRawText:(UITextView *)textView
{
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
                                                    if (!attachment) {return;}
                                        
                                                    int emojiNum = [objc_getAssociatedObject(attachment, @"number") intValue];
                                                    [rawText insertString:[NSString stringWithFormat:@"[%d]", emojiNum-1] atIndex:range.location];
                                                }];
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSData *)compressImage:(UIImage *)image
{
    NSUInteger maxFileSize = 500 * 1024;
    CGFloat compressionRatio = 1.0f;
    CGFloat maxCompressionRatio = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compressionRatio);
    
    while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
        compressionRatio -= 0.1f;
        imageData = UIImageJPEGRepresentation(image, compressionRatio);
    }
    
    return imageData;
}

+ (NSString *)escapeHTML:(NSString *)originalHTML
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:originalHTML];
    [result replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"'"  withString:@"&#39;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    return result;
}


+ (BOOL)isURL:(NSString *)string
{
    NSString *pattern = @"^(http|https)://.*?$(net|com|.com.cn|org|me|)";
    
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    
    return [urlPredicate evaluateWithObject:string];
}


+ (NSInteger)networkStatus
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.oschina.net"];
    return reachability.currentReachabilityStatus;
}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] > 0;
}


#pragma mark UI处理

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent
{
    return min + (max - min) * percent;
}

+ (MBProgressHUD *)createHUDInWindowOfView:(UIView *)view
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:HUD];
    [HUD show:YES];
    
    return HUD;
}

+ (UIImage *)createQRCodeFromString:(NSString *)string
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [QRFilter setValue:stringData forKey:@"inputMessage"];
    [QRFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CGFloat scale = 5;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:QRFilter.outputImage fromRect:QRFilter.outputImage.extent];
    
    //Scale the image usign CoreGraphics
    CGFloat width = QRFilter.outputImage.extent.size.width * scale;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return image;
}



@end
