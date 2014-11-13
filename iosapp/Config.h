//
//  Config.h
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password;
+ (void)saveOwnID:(int64_t)userID;
//+ (void)saveCookie:(BOOL)isLogin;

+ (NSArray *)getOwnAccountAndPassword;
+ (int64_t)getOwnID;


@end
