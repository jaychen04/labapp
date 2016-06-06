//
//  OSCBlogDetail.m
//  iosapp
//
//  Created by Graphic-one on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCBlogDetail.h"
#import <MJExtension.h>

@implementation OSCBlogDetail

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"about" : [OSCBlogDetailRecommend class],
             @"comments" : [OSCBlogDetailComment class]
             };
}


@end



@implementation OSCBlogDetailRecommend


@end


@implementation OSCBlogDetailComment

//+(NSDictionary *)mj_objectClassInArray{
//    return @{
//             @"refer" : [OSCBlogComment class]
//             };
//}

@end

@implementation OSCBlogCommentRefer


@end