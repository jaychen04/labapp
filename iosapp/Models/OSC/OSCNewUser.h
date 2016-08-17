//
//  OSCNewUser.h
//  iosapp
//
//  Created by 李萍 on 16/8/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCNewUser : NSObject

/*
 
 id":312312,
 "name":"昵称",
 "portrait":"http://xx.xxx.xxx.png",
 "gender":1,
 "desc":"我是一名搬运工",
 "score":2000,
 "tweetCount":2000,
 "collectCount":2000,
 "fansCount":2000,
 "followCount":2000

 
 */
@property (nonatomic, assign) long id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSString *portrait;
@property (nonatomic, assign) int gender;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int tweetCount;
@property (nonatomic, assign) int collectCount;
@property (nonatomic, assign) int fansCount;
@property (nonatomic, assign) int followCount;

@end
