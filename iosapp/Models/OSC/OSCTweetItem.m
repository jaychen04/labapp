//
//  OSCTweetItem.m
//  iosapp
//
//  Created by Graphic-one on 16/7/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetItem.h"
#import <MJExtension.h>

@implementation OSCTweetItem

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"audio" : [OSCTweetAudio class],
             @"images" : [OSCTweetImages class]
             };
}
@end


#pragma mark -
#pragma mark --- 动弹作者
@implementation OSCTweetAuthor

@end


#pragma mark -
#pragma mark --- 动弹Code
@implementation OSCTweetCode

@end


#pragma mark -
#pragma mark --- 动弹音频 && 视频
@implementation OSCTweetAudio

@end


#pragma mark -
#pragma mark --- 动弹图片
@implementation OSCTweetImages

@end


