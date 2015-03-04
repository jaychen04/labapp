//
//  Config.m
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "Config.h"
#import <SSKeychain.h>

NSString * const kService = @"OSChina";
NSString * const kAccount = @"account";
NSString * const kUserID = @"userID";

NSString * const kActorName = @"Actor";
NSString * const kSex = @"Sex";
NSString * const kTelephoneNumber = @"TelephoneNumber";
NSString * const kCorporateName = @"CorporateName";
NSString * const kPositionName = @"PositionName";

@implementation Config

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:kAccount];
    [userDefaults synchronize];
    
    [SSKeychain setPassword:password forService:kService account:account];
}

+ (void)saveOwnID:(int64_t)userID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(userID) forKey:kUserID];
    [userDefaults synchronize];
}

+ (void)saveActivityActorName:(NSString *)actorName andSex:(NSInteger)sex andTelephoneNumber:(NSString *)telephoneNumber andCorporateName:(NSString *)corporateName andPositionName:(NSString *)positionName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:actorName forKey:kActorName];
    [userDefaults setObject:@(sex) forKey:kSex];
    [userDefaults setObject:telephoneNumber forKey:kTelephoneNumber];
    [userDefaults setObject:corporateName forKey:kCorporateName];
    [userDefaults setObject:positionName forKey:kPositionName];
    [userDefaults synchronize];
}

+ (NSArray *)getOwnAccountAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kAccount];
    NSString *password = [SSKeychain passwordForService:kService account:account];
    
    if (account) {return @[account, password];}
    return nil;
}

+ (int64_t)getOwnID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [userDefaults objectForKey:kUserID];
    
    if (userID) {return [userID longLongValue];}
    return 0;
}

+ (NSArray *)getActivitySignUpInfomation
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *actorName = [userDefaults objectForKey:kActorName];
    NSNumber *sex = [userDefaults objectForKey:kSex];
    NSString *telephoneNumber = [userDefaults objectForKey:kTelephoneNumber];
    NSString *corporateName = [userDefaults objectForKey:kCorporateName];
    NSString *positionName = [userDefaults objectForKey:kPositionName];
    if (actorName) {
        return @[actorName, sex, telephoneNumber, corporateName, positionName];
    }
    return nil;
}




@end
