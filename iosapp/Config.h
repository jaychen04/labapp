//
//  Config.h
//  iosapp
//
//  Created by ChanAetern on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (void)saveUserAccount:(NSString *)account andPassword:(NSString *)password;
+ (void)saveUserID:(int64_t)userID;

+ (NSArray *)getUserAccountAndPassword;
+ (NSString *)getUserID;

@end
