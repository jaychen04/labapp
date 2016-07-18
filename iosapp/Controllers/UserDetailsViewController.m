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

#import <MBProgressHUD.h>

#define NAVBAR_CHANGE_POINT 50

@interface UserDetailsViewController ()

@property (nonatomic, strong) OSCUser *user;

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
    
//    self.tableView.frame = (CGRect){{0,-64},self.tableView.bounds.size};
//    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"用户中心";
    self.tableView.bounces = NO;
    [self settingNaviBarItem];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:YES];
//    self.tableView.delegate = self;
//    [self scrollViewDidScroll:self.tableView];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.tableView.delegate = nil;
//    [self.navigationController.navigationBar lt_reset];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.separatorColor = [UIColor separatorColor];
    
    return section == 0 ? 1 : self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 415;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UserHeaderCell *cell = [UserHeaderCell new];

        [cell setContentWithUser:_user];

        cell.followsBtn.tag = 1;
        cell.fansBtn.tag = 2;

        [cell.followsBtn addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
        [cell.fansBtn addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {return;}
    else {[super tableView:tableView didSelectRowAtIndexPath:indexPath];}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    UIColor * color = [UIColor navigationbarColor];
//    CGFloat offsetY = scrollView.contentOffset.y;
//    if (offsetY > NAVBAR_CHANGE_POINT) {
//        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
//        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//    } else {
//        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
//    }
//}

#pragma mark - 处理页面跳转

- (void)pushFriendsSVC:(UIButton *)button
{
    if (button.tag == 1) {//关注
        FriendsViewController* followsVC = [[FriendsViewController alloc]initWithUserID:_user.userID andFriendsRelation:1];
        followsVC.title = @"关注";
        [self.navigationController pushViewController:followsVC animated:YES];
    }else{//粉丝
        FriendsViewController* fansVC = [[FriendsViewController alloc]initWithUserID:_user.userID andFriendsRelation:0];
        fansVC.title = @"粉丝";
        [self.navigationController pushViewController:fansVC animated:YES];
    }
}


- (void)updateRelationship
{
    if ([Config getOwnID] == 0) {
        [self.navigationController pushViewController:[LoginViewController new] animated:YES];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_USER_UPDATERELATION]
           parameters:@{
//                          @"id"       :       @(_user.userID)
                        @"uid":             @([Config getOwnID]),
                        @"hisuid":          @(_user.userID),
                        @"newrelation":     _user.relationship <= 2? @(0) : @(1)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDoment) {
                  ONOXMLElement *result = [responseDoment.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  if (errorCode == 1) {
                      _user.relationship = [[[responseDoment.rootElement firstChildWithTag:@"relation"] numberValue] intValue];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self updateRelationshipImage];
                      });
                  } else {
                      MBProgressHUD *HUD = [Utils createHUD];
                      HUD.mode = MBProgressHUDModeCustomView;
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.labelText = errorMessage;
                      
                      [HUD hide:YES afterDelay:1];
                  }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                HUD.labelText = @"网络异常，操作失败";
                
                [HUD hide:YES afterDelay:1];
            }];
    }
}


- (void)sendMessage
{
    if ([Config getOwnID] == 0) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"请先登录";
        [HUD hide:YES afterDelay:0.5];
    } else {
        [self.navigationController pushViewController:[[BubbleChatViewController alloc] initWithUserID:_user.userID andUserName:_user.name] animated:YES];
    }
}

- (void)showUserInformation
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.color = [UIColor colorWithHex:0xEEEEEE];
    
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
    
    HUD.detailsLabelColor = [UIColor blackColor];
    HUD.detailsLabelFont = [UIFont systemFontOfSize:14];
    detailsLabel.attributedText = userInformation;
    
    [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD:)]];
}

- (void)hideHUD:(UITapGestureRecognizer *)recognizer
{
    [(MBProgressHUD *)recognizer.view hide:YES];
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


@end
