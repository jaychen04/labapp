//
//  TeamMemberDetailViewController.m
//  iosapp
//
//  Created by Holden on 15/5/7.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamMemberDetailViewController.h"
#import "TeamAPI.h"
#import "TeamMember.h"
#import "TeamActivity.h"
#import "MemberDetailCell.h"
#import "TeamActivityCell.h"
#import "TeamActivityDetailViewController.h"

static NSString * const kUserActivityCellID = @"userActivityCell";
static NSString * const kMemberDetailCellID = @"memberDetailCell";
@interface TeamMemberDetailViewController ()
//<anotherNetWorkingDelegate>
@property (nonatomic)int teamId;
@property (nonatomic)int uId;
@property (nonatomic,strong)TeamMember *member;
@end


@implementation TeamMemberDetailViewController

//teamid 团队id
//pageIndex 页数
//pageSize 每页条数
//type （是否需要区分动态的类别，如：所有/动弹/git/分享/讨论/周报，"all","tweet","git","share","discuss","report"）
//uid 要查询动态的用户id
- (instancetype)initWithTeamId:(int)teamId uId:(int)uId
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url = [NSString stringWithFormat:@"%@%@?teamid=%d&uid=%d&pageIndex=%lu&pageSize=20&type=all", TEAM_PREFIX, TEAM_ACTIVE_LIST, teamId, uId,(unsigned long)page];
            return url;
        };
        self.teamId = teamId;
        self.uId = uId;
        self.objClass = [TeamActivity class];
        self.needCache = YES;
        
//        self.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        self.anotherNetWorking = ^{
            [weakSelf getMemberDetailInfo];
        };
    }
    
    return self;
}
- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"actives"] childrenWithTag:@"active"];
}

//#pragma mark --anotherNetWorkingDelegate
//-(void)getAnotherDataFromNetWorking
//{
//    [self getMemberDetailInfo];
//}

-(void)getMemberDetailInfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    NSString *url = [NSString stringWithFormat:@"%@%@?uid=%d&teamid=%d", TEAM_PREFIX, TEAM_USER_INFORMATION,_uId,_teamId];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *memberDetailsXML = [responseObject.rootElement firstChildWithTag:@"member"];
             _member = [[TeamMember alloc] initWithXML:memberDetailsXML];
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(self.tableView){
                     [self.tableView reloadData];
                 }
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"用户主页";
    [self.tableView registerClass:[TeamActivityCell class] forCellReuseIdentifier:kUserActivityCellID];
    [self.tableView registerClass:[MemberDetailCell class] forCellReuseIdentifier:kMemberDetailCellID];
    
    [self getMemberDetailInfo];

}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 120;
    } else {
        TeamActivity *activity = self.objects[indexPath.row-1];
        self.label.attributedText = activity.attributedTitle;
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        return height + 63;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MemberDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberDetailCellID forIndexPath:indexPath];
        if (_member) {
            [cell setContentWithTeamMember:_member];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        TeamActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserActivityCellID forIndexPath:indexPath];
        TeamActivity *activity = self.objects[indexPath.row-1];
        [cell setContentWithActivity:activity];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row != 0) {
        if (indexPath.row < self.objects.count) {
            TeamActivity *activity = self.objects[indexPath.row];
            TeamActivityDetailViewController *detailVC = [[TeamActivityDetailViewController alloc] initWithActivity:activity andTeamID:_teamId];
            [self.navigationController pushViewController:detailVC animated:YES];
        } else {
            [self fetchMore];
        }
    }
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
