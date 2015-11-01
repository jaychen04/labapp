//
//  Config.m
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "Config.h"
#import "TeamTeam.h"
#import "OSCUser.h"

#import <SSKeychain.h>

NSString * const kService = @"OSChina";
NSString * const kAccount = @"account";
NSString * const kUserID = @"userID";

NSString * const kUserName = @"name";
NSString * const kPortrait = @"portrait";
NSString * const kPortraitURL = @"portraitURL";
NSString * const kUserScore = @"score";
NSString * const kFavoriteCount = @"favoritecount";
NSString * const kFanCount = @"fans";
NSString * const kFollowerCount = @"followers";

NSString * const kJointime = @"jointime";
NSString * const kDevelopPlatform = @"devplatform";
NSString * const kExpertise = @"expertise";
NSString * const kHometown = @"from";

NSString * const kTrueName = @"trueName";
NSString * const kSex = @"sex";
NSString * const kPhoneNumber = @"phoneNumber";
NSString * const kCorporation = @"corporation";
NSString * const kPosition = @"position";

NSString * const kTeamID = @"teamID";
NSString * const kTeamsArray = @"teams";


@implementation Config

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:kAccount];
    [userDefaults synchronize];
    
    [SSKeychain setPassword:password forService:kService account:account];
}

+ (void)saveProfile:(OSCUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(user.userID) forKey:kUserID];
    [userDefaults setObject:user.name forKey:kUserName];
    [userDefaults setObject:user.portraitURL.absoluteString forKey:kPortraitURL];
    [userDefaults setObject:@(user.score) forKey:kUserScore];
    [userDefaults setObject:@(user.favoriteCount) forKey:kFavoriteCount];
    [userDefaults setObject:@(user.fansCount)      forKey:kFanCount];
    [userDefaults setObject:@(user.followersCount) forKey:kFollowerCount];
    
    [userDefaults synchronize];
}


+ (void)updateProfile:(OSCUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:user.name forKey:kUserName];
    [userDefaults setObject:user.portraitURL.absoluteString forKey:kPortraitURL];
    [userDefaults setObject:@(user.score) forKey:kUserScore];
    [userDefaults setObject:@(user.favoriteCount) forKey:kFavoriteCount];
    [userDefaults setObject:@(user.fansCount)      forKey:kFanCount];
    [userDefaults setObject:@(user.followersCount) forKey:kFollowerCount];
    
    [userDefaults synchronize];
}


+ (void)clearProfile
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(0) forKey:kUserID];
    [userDefaults setObject:@"点击头像登录" forKey:kUserName];
    [userDefaults setObject:@(0) forKey:kUserScore];
    [userDefaults setObject:@(0) forKey:kFavoriteCount];
    [userDefaults setObject:@(0)      forKey:kFanCount];
    [userDefaults setObject:@(0) forKey:kFollowerCount];
    
    [userDefaults synchronize];
}



+ (void)clearCookie
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"sessionCookies"];
}

+ (void)savePortrait:(UIImage *)portrait
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:UIImagePNGRepresentation(portrait) forKey:kPortrait];
    
    [userDefaults synchronize];
}

+ (void)saveName:(NSString *)actorName sex:(NSInteger)sex phoneNumber:(NSString *)phoneNumber corporation:(NSString *)corporation andPosition:(NSString *)position
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:actorName forKey:kTrueName];
    [userDefaults setObject:@(sex) forKey:kSex];
    [userDefaults setObject:phoneNumber forKey:kPhoneNumber];
    [userDefaults setObject:corporation forKey:kCorporation];
    [userDefaults setObject:position forKey:kPosition];
    [userDefaults synchronize];
}

+ (void)saveTweetText:(NSString *)tweetText forUser:(ino64_t)userID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [NSString stringWithFormat:@"tweetTmp_%lld", userID];
    [userDefaults setObject:tweetText forKey:key];
    
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
    return [userDefaults integerForKey:kUserID];
}

+ (NSString *)getOwnUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:kUserName];
    if (userName) {return userName;}
    return @"";
}

+ (NSArray *)getActivitySignUpInfomation
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *name = [userDefaults objectForKey:kTrueName] ?: @"";
    NSNumber *sex = [userDefaults objectForKey:kSex] ?: @(0);
    NSString *phoneNumber = [userDefaults objectForKey:kPhoneNumber] ?: @"";
    NSString *corporation = [userDefaults objectForKey:kCorporation] ?: @"";
    NSString *position = [userDefaults objectForKey:kPosition] ?: @"";
    
    return @[name, sex, phoneNumber, corporation, position];
}

+ (OSCUser *)myProfile
{
    OSCUser *user = [OSCUser new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    user.userID = [userDefaults integerForKey:kUserID];
    user.name = [userDefaults objectForKey:kUserName];
    user.portraitURL = [NSURL URLWithString:[userDefaults objectForKey:kPortraitURL]];
    user.score = [[userDefaults objectForKey:kUserScore] intValue];
    user.favoriteCount = [[userDefaults objectForKey:kFavoriteCount] intValue];
    user.fansCount = [[userDefaults objectForKey:kFanCount] intValue];
    user.followersCount = [[userDefaults objectForKey:kFollowerCount] intValue];
    
    if (!user.name) {
        user.name = @"点击头像登录";
    }
    
    return user;
}

+ (UIImage *)getPortrait
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UIImage *portrait = [UIImage imageWithData:[userDefaults objectForKey:kPortrait]];
    
    return portrait;
}

+ (NSString *)getTweetText
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *IdStr = [NSString stringWithFormat:@"tweetTmp_%lld", [Config getOwnID]];
    NSString *tweetText = [userDefaults objectForKey:IdStr];
    
    return tweetText;
}


#pragma mark - Team

+ (int)teamID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userDefaults objectForKey:kTeamID] intValue];
}

+ (void)setTeamID:(int)teamID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:@(teamID) forKey:kTeamID];
    [userDefaults synchronize];
}

+ (void)saveTeams:(NSArray *)teams
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *rawTeams = [NSMutableArray new];
    
    for (TeamTeam *team in teams) {
        [rawTeams addObject:@[@(team.teamID), team.name]];
    }
    [userDefaults setObject:rawTeams forKey:kTeamsArray];
    
    [userDefaults synchronize];
}

+ (NSMutableArray *)teams
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *rawTeams = [userDefaults objectForKey:kTeamsArray];
    NSMutableArray *teams = [NSMutableArray new];
    
    for (NSArray *rawTeam in rawTeams) {
        TeamTeam *team = [TeamTeam new];
        team.teamID = [((NSNumber *)rawTeam[0]) intValue];
        team.name = rawTeam[1];
        [teams addObject:team];
    }
    
    return teams;
}


+ (void)removeTeamInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kTeamID];
    [userDefaults removeObjectForKey:kTeamsArray];
}

//夜间状态
+ (void)saveWhetherNightMode:(BOOL)isNight
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(isNight) forKey:@"mode"];
    [userDefaults synchronize];
}
+ (BOOL)getMode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userDefaults objectForKey:@"mode"] boolValue];
}

@end
