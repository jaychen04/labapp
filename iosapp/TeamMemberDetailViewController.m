//
//  TeamMemberDetailViewController.m
//  iosapp
//
//  Created by Holden on 15/5/7.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamMemberDetailViewController.h"
#import "TeamAPI.h"
@interface TeamMemberDetailViewController ()

@end


@implementation TeamMemberDetailViewController

//teamid 团队id
//uid 用户id
//pageIndex 页数
//pageSize 每页条数
//- (instancetype)initWithTeamId:(int64_t)teamId uId:(int)uId
//{
//    if (self = [super init]) {
//        self.generateURL = ^NSString * (NSUInteger page) {
//            NSString *url = [NSString stringWithFormat:@"%@%@?teamid=%lld&uid=%d&pageIndex=%lu&pageSize=20", TEAM_PREFIX, TEAM_USER_INFOMATION, teamId, visitUserId,page];
//            return url;
//        };
////        self.objClass = [TeamActivity class];
//        self.needCache = YES;
//    }
//    
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
