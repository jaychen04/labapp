//
//  OSCNewTweet.m
//  iosapp
//
//  Created by 李萍 on 16/7/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNewTweet.h"
#import <MJExtension.h>

@implementation OSCNewTweet

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"Id" : @"id"
             };
}

@end

@implementation OSCAuthor

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"Id" : @"id"
             };
}

@end
