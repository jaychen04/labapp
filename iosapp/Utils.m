//
//  Utils.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "Utils.h"

@implementation Utils


#pragma mark - 处理API返回信息

+ (NSString *)getAppclient:(int)clientType
{
    switch (clientType) {
        case 1:
            return @"";
        case 2:
            return @"来自手机";
        case 3:
            return @"来自Android";
        case 4:
            return @"来自iPhone";
        case 5:
            return @"来自Windows Phone";
        case 6:
            return @"来自微信";
        default:
            return @"";
    }

}


#pragma mark - 通用

#pragma mark - 信息处理

+ (NSString *)intervalSinceNow:(NSString *)dateStr
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
    
    if (minutes < 1) {
        return @"刚刚";
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%ld 分钟前", (long)minutes];
    } else if (hours < 24) {
        return [NSString stringWithFormat:@"%ld 小时前", (long)hours];
    } else if (hours < 48 && days == 1) {
        return @"昨天";
    } else if (days < 30) {
        return [NSString stringWithFormat:@"%ld 天前", (long)days];
    } else if (days < 60) {
        return @"一个月前";
    } else if (months < 12) {
        return [NSString stringWithFormat:@"%ld 个月前", (long)months];
    } else {
        NSArray *arr = [dateStr componentsSeparatedByString:@"T"];
        return [arr objectAtIndex:0];
    }
}


#pragma mark - UI处理

+ (void)roundView:(UIView *)view cornerRadius:(CGFloat)cornerRadius
{
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}




@end
