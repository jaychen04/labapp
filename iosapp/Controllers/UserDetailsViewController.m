//
//  UserDetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "OSCUser.h"
#import "Utils.h"
#import "Config.h"
#import "SwipableViewController.h"
#import "FriendsViewController.h"
#import "OSCEvent.h"
#import "EventCell.h"
#import "UserHeaderCell.h"
#import "UserOperationCell.h"
#import "BubbleChatViewController.h"
#import "LoginViewController.h"
#import "UINavigationBar+BackgroundColor.h"
#import "UserDrawHeaderView.h"

#import <MBProgressHUD.h>

#define NAVIBAR_HEIGHT 350

@interface UserDetailsViewController ()

@property (nonatomic, strong) OSCUser *user;

@property (nonatomic, strong) UserDrawHeaderView* headerCanvasView;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation UserDetailsViewController{
     UIButton* _rightBarMessageBtn;
     UIButton* _rightBaFollowrBtn;
}


#pragma mark - init method

- (instancetype)initWithUserID:(int64_t)userID
{
    self = [super initWithUserID:userID];
    self.hidesBottomBarWhenPushed = YES;
    if (!self) {return self;}
    
    __weak UserDetailsViewController *weakSelf = self;
    self.parseExtraInfo = ^(ONOXMLDocument *XML) {
        ONOXMLElement *userXML = [XML.rootElement firstChildWithTag:@"user"];
        weakSelf.user = [[OSCUser alloc] initWithXML:userXML];
        [weakSelf updateRelationshipImage];
        if (weakSelf.user.userID != [Config getOwnID]) {
            [weakSelf settingNaviBarItem];
        }
        [weakSelf assemblyHeaderView];
    };
    
    return self;
}

- (instancetype)initWithUserName:(NSString *)userName
{
    self = [super initWithUserName:userName];
    self.hidesBottomBarWhenPushed = YES;
    if (!self) {return self;}
    
    __weak UserDetailsViewController *weakSelf = self;
    self.parseExtraInfo = ^(ONOXMLDocument *XML) {
        ONOXMLElement *userXML = [XML.rootElement firstChildWithTag:@"user"];
        weakSelf.user = [[OSCUser alloc] initWithXML:userXML];
        [weakSelf updateRelationshipImage];
        if (weakSelf.user.userID != [Config getOwnID]) {
            [weakSelf settingNaviBarItem];
        }
        [weakSelf assemblyHeaderView];
    };
    
    return self;
}

-(void)settingNaviBarItem{
    _rightBarMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarMessageBtn.userInteractionEnabled = YES;
    _rightBarMessageBtn.frame  = CGRectMake(0, 0, 36, 36);
    [_rightBarMessageBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [_rightBaFollowrBtn setTitle:@"" forState:UIControlStateNormal];
    [_rightBarMessageBtn setBackgroundImage:[UIImage imageNamed:@"btn_pm_normal"] forState:UIControlStateNormal];
    [_rightBarMessageBtn setBackgroundImage:[UIImage imageNamed:@"btn_pm_pressed"] forState:UIControlStateHighlighted];
    
    _rightBaFollowrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBaFollowrBtn.userInteractionEnabled = YES;
    _rightBaFollowrBtn.frame  = CGRectMake(0, 0, 36, 36);
    [_rightBaFollowrBtn addTarget:self action:@selector(updateRelationship) forControlEvents:UIControlEventTouchUpInside];
    [_rightBaFollowrBtn setTitle:@"" forState:UIControlStateNormal];
    [self updateRelationshipImage];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:_rightBaFollowrBtn] ,[[UIBarButtonItem alloc] initWithCustomView:_rightBarMessageBtn]];;
}


#pragma mark - life cycle

- (void)viewDidLoad {
    self.needRefreshAnimation = NO;
    [super viewDidLoad];
    
    self.navigationItem.title = @"用户中心";
    self.tableView.bounces = NO;
    self.tableView.tableHeaderView = self.headerCanvasView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.tableView.tableHeaderView = self.headerCanvasView;
    if (_user) { [self assemblyHeaderView]; }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.headerCanvasView = nil;
    self.tableView.tableHeaderView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.separatorColor = [UIColor separatorColor];
    
    return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - 处理页面跳转

- (void)pushFriendsSVC:(UIButton *)button
{
    if (button.tag == 1) {//关注
        FriendsViewController* followsVC = [[FriendsViewController alloc]initUserId:_user.userID andRelation:OSCAPI_USER_FOLLOWS];
        followsVC.title = @"关注";
        [self.navigationController pushViewController:followsVC animated:YES];
    }else{//粉丝
        FriendsViewController* fansVC = [[FriendsViewController alloc]initUserId:_user.userID andRelation:OSCAPI_USER_FANS];
        fansVC.title = @"粉丝";
        [self.navigationController pushViewController:fansVC animated:YES];
    }
}


- (void)updateRelationship
{
    if ([Config getOwnID] == 0) {
        [self.navigationController pushViewController:[LoginViewController new] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_USER_RELATION_REVERSE] parameters:@{
                         @"id" : @(_user.userID)
                         }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"] floatValue] == 1) {
                     NSDictionary* resultDic = responseObject[@"result"];
                     _user.relationship = [resultDic[@"relation"] intValue];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         HUD.mode = MBProgressHUDModeCustomView;
                         if (_user.relationship == 1 || _user.relationship == 2) {
                             HUD.label.text = @"关注成功";
                         }else{
                             HUD.label.text = @"取消关注";
                         }
                         
                         [HUD hideAnimated:YES afterDelay:1];
                         [self updateRelationshipImage];
                     });
                 }else{
                     HUD.mode = MBProgressHUDModeCustomView;
                   HUD.label.text = @"数据异常";

                   [HUD hideAnimated:YES afterDelay:1];
                 }
              }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，操作失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
         }];
    }
}


- (void)sendMessage
{
    if ([Config getOwnID] == 0) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = @"请先登录";
        [HUD hideAnimated:YES afterDelay:0.5];
    } else {
        [self.navigationController pushViewController:[[BubbleChatViewController alloc] initWithUserID:_user.userID andUserName:_user.name] animated:YES];
    }
}

- (void)showUserInformation
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView.backgroundColor = [UIColor colorWithHex:0xEEEEEE];
    
    UILabel *detailsLabel = [HUD valueForKey:@"detailsLabel"];
    detailsLabel.textAlignment = NSTextAlignmentLeft;
    detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[UIColor grayColor]};
    
    NSArray *title = @[@"加入时间：", @"所在地区：", @"开发平台：", @"专长领域："];
    NSString *joinTime = [_user.joinTime timeAgoSinceNow];
    NSArray *content = @[joinTime, _user.location, _user.developPlatform, _user.expertise];
    
    NSMutableAttributedString *userInformation = [NSMutableAttributedString new];
    for (int i = 0; i < 4; ++i) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title[i]
                                                                                           attributes:titleAttributes];
        if (i  < 3) {
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", content[i]]]];
        } else {
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", content[i]]]];
        }
        
        [userInformation appendAttributedString:attributedText];
    }
    
    HUD.detailsLabel.textColor = [UIColor blackColor];
    HUD.detailsLabel.font = [UIFont systemFontOfSize:14];
    detailsLabel.attributedText = userInformation;
    
    [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD:)]];
}

- (void)hideHUD:(UITapGestureRecognizer *)recognizer
{
    [(MBProgressHUD *)recognizer.view hideAnimated:YES];
}

-(void)updateRelationshipImage{
    UIImage* relationImageNomal;
    UIImage* relationImagePress;
    if (_user.relationship == 1) {
        relationImageNomal = [UIImage imageNamed:@"btn_following_both_normal"];
        relationImagePress = [UIImage imageNamed:@"btn_following_both_pressed"];
    }else if (_user.relationship == 2){
        relationImageNomal = [UIImage imageNamed:@"btn_following_normal"];
        relationImagePress = [UIImage imageNamed:@"btn_following_pressed"];
    }else{
        relationImageNomal = [UIImage imageNamed:@"btn_follow_normal"];
        relationImagePress = [UIImage imageNamed:@"btn_follow_pressed"];
    }
    
    [_rightBaFollowrBtn setBackgroundImage:relationImageNomal forState:UIControlStateNormal];
    [_rightBaFollowrBtn setBackgroundImage:relationImagePress forState:UIControlStateHighlighted];
}

#pragma mark --- headerView 
- (void) assemblyHeaderView{
    [self.headerCanvasView setContentWithUser:_user];
    self.headerCanvasView.followsBtn.tag = 1;
    self.headerCanvasView.fansBtn.tag = 2;

    [self.headerCanvasView.followsBtn addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerCanvasView.fansBtn addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
}

- (UserDrawHeaderView *)headerCanvasView {
	if(_headerCanvasView == nil) {
        _headerCanvasView = [[UserDrawHeaderView alloc] initWithFrame:(CGRect){{0,0},{[UIScreen mainScreen].bounds.size.width,NAVIBAR_HEIGHT}}];
	}
	return _headerCanvasView;
}

@end
