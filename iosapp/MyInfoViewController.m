//
//  MyInfoViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/10/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "MyInfoViewController.h"
#import "OSCAPI.h"
#import "OSCMyInfo.h"
#import "Config.h"
#import "Utils.h"
#import "SwipableViewController.h"
#import "FavoritesViewController.h"
#import "FriendsViewController.h"
#import "BlogsViewController.h"
#import "EventsViewController.h"
#import "MessagesViewController.h"
#import "LoginViewController.h"
#import "SearchViewController.h"
#import "MyBasicInfoViewController.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <RESideMenu.h>
#import <MBProgressHUD.h>

@interface MyInfoViewController ()

@property (nonatomic, strong) OSCMyInfo *myInfo;
@property (nonatomic, readonly, assign) int64_t myID;

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *myQRCodeImageView;

@property (nonatomic, strong) UIButton *creditsBtn;
@property (nonatomic, strong) UIButton *collectionsBtn;
@property (nonatomic, strong) UIButton *followsBtn;
@property (nonatomic, strong) UIButton *fansBtn;

@end


@implementation MyInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-search"] style:UIBarButtonItemStylePlain target:self action:@selector(pushSearchViewController)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-sidebar"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickMenuButton)];
    
    self.tableView.bounces = NO;
    self.navigationItem.title = @"我";
    self.view.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    [self refreshView];
}

- (void)refreshView
{
    _myID = [Config getOwnID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@?uid=%lld", OSCAPI_PREFIX, OSCAPI_MY_INFORMATION, _myID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             ONOXMLElement *userXML = [responseDocument.rootElement firstChildWithTag:@"user"];
             _myInfo = [[OSCMyInfo alloc] initWithXML:userXML];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"网络异常，错误码：%ld", (long)error.code);
         }];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor colorWithHex:0x00CD66];
    
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:25];
    [_portrait loadPortrait:_myInfo.portraitURL];
    _portrait.userInteractionEnabled = YES;
    [_portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortrait)]];
    [header addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    _nameLabel.text = _myID? _myInfo.name: @"点击头像登录";
    [header addSubview:_nameLabel];
    
    UIImageView *QRCodeImageView = [UIImageView new];
    QRCodeImageView.image = [UIImage imageNamed:@"QR-Code"];
    QRCodeImageView.userInteractionEnabled = YES;
    [QRCodeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapQRCodeImage)]];
    [header addSubview:QRCodeImageView];
    if ([Config getOwnID] == 0) {QRCodeImageView.hidden = YES;}
    
    UIView *countView = [UIView new];
    [header addSubview:countView];
    
    _creditsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectionsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _followsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _fansBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    void (^setButtonStyle)(UIButton *, NSString *) = ^(UIButton *button, NSString *title) {
        [button setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:title forState:UIControlStateNormal];
        [countView addSubview:button];
    };
    
    setButtonStyle(_creditsBtn, [NSString stringWithFormat:@"积分\n%d", _myInfo.score]);
    setButtonStyle(_collectionsBtn, [NSString stringWithFormat:@"收藏\n%d", _myInfo.favoriteCount]);
    setButtonStyle(_followsBtn, [NSString stringWithFormat:@"关注\n%d", _myInfo.followersCount]);
    setButtonStyle(_fansBtn, [NSString stringWithFormat:@"粉丝\n%d", _myInfo.fansCount]);
    
    [_collectionsBtn addTarget:self action:@selector(pushFavoriteSVC) forControlEvents:UIControlEventTouchUpInside];
    [_followsBtn addTarget:self action:@selector(pushFriendsSVC) forControlEvents:UIControlEventTouchUpInside];
    [_fansBtn addTarget:self action:@selector(pushFriendsSVC) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIView *view in header.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    for (UIView *view in countView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _nameLabel, _creditsBtn, _collectionsBtn, _followsBtn, _fansBtn, QRCodeImageView, countView);
    NSDictionary *metrics = @{@"width": @(tableView.frame.size.width / 4)};
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_portrait(50)]-8-[_nameLabel]-15-[countView(50)]|"
                                                                   options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(50)]" options:0 metrics:nil views:views]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[countView]|" options:0 metrics:nil views:views]];
    
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[QRCodeImageView]" options:0 metrics:nil views:views]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[QRCodeImageView]-15-|" options:0 metrics:nil views:views]];
    
    
    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_creditsBtn(width)][_collectionsBtn(width)][_followsBtn(width)][_fansBtn(width)]|"
                                                                      options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_creditsBtn]|" options:0 metrics:nil views:views]];
    
    
    if ([Config getOwnID] == 0) {countView.hidden = YES;}
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
    [cell setSelectedBackgroundView:selectedBackground];
    
    cell.textLabel.text = @[@"消息", @"博客"][indexPath.row];
    //cell.imageView.image = [UIImage imageNamed:@[@"", @"", @"", @""][indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([Config getOwnID] == 0) {
        [self.navigationController pushViewController:[LoginViewController new] animated:YES];
        return;
    }
    
    switch (indexPath.row) {
        case 0: {
            SwipableViewController *messageCenterVC = [[SwipableViewController alloc] initWithTitle:@"消息中心"
                                                                                       andSubTitles:@[@"@我", @"评论", @"留言", @"粉丝"]
                                                                                     andControllers:@[
                                                                                                      [[EventsViewController alloc] initWithCatalog:2],
                                                                                                      [[EventsViewController alloc] initWithCatalog:3],
                                                                                                      [MessagesViewController new],
                                                                                                      [[FriendsViewController alloc] initWithUserID:_myID andFriendsRelation:0]
                                                                                                      ]];
            messageCenterVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:messageCenterVC animated:YES];
            
            break;
        }
        case 1: {
            BlogsViewController *blogsVC = [[BlogsViewController alloc] initWithUserID:_myID];
            blogsVC.navigationItem.title = @"我的博客";
            blogsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:blogsVC animated:YES];
            break;
        }
        default: break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 158;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)pushFavoriteSVC
{
    SwipableViewController *favoritesSVC = [[SwipableViewController alloc] initWithTitle:@"收藏"
                                                                              andSubTitles:@[@"软件", @"话题", @"代码", @"博客", @"资讯"]
                                                                            andControllers:@[
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeSoftware],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeTopic],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeCode],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeBlog],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeNews]
                                                                                             ]];
    favoritesSVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:favoritesSVC animated:YES];
}

- (void)pushFriendsSVC
{
    SwipableViewController *friendsSVC = [[SwipableViewController alloc] initWithTitle:@"关注/粉丝"
                                                                            andSubTitles:@[@"关注", @"粉丝"]
                                                                          andControllers:@[
                                                                                           [[FriendsViewController alloc] initWithUserID:_myID andFriendsRelation:1],
                                                                                           [[FriendsViewController alloc] initWithUserID:_myID andFriendsRelation:0]
                                                                                           ]];
    friendsSVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:friendsSVC animated:YES];
}


- (void)onClickMenuButton
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)pushSearchViewController
{
    [self.navigationController pushViewController:[SearchViewController new] animated:YES];
}


- (void)tapPortrait
{
    if ([Config getOwnID] == 0) {
        [self.navigationController pushViewController:[LoginViewController new] animated:YES];
    } else {
        [self.navigationController pushViewController:[[MyBasicInfoViewController alloc] initWithMyInformation:_myInfo]
                                             animated:YES];
    }
}


#pragma mark - 二维码相关

- (void)tapQRCodeImage
{
    MBProgressHUD *HUD = [Utils createHUDInWindowOfView:self.view];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.color = [UIColor whiteColor];
    
    HUD.labelText = @"扫一扫上面的二维码，加我为好友";
    HUD.labelFont = [UIFont systemFontOfSize:13];
    HUD.labelColor = [UIColor grayColor];
    HUD.customView = self.myQRCodeImageView;
    [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD:)]];
}

- (void)hideHUD:(UIGestureRecognizer *)recognizer
{
    [(MBProgressHUD *)recognizer.view hide:YES];
}

- (UIImageView *)myQRCodeImageView
{
    if (!_myQRCodeImageView) {
        UIImage *myQRCode = [Utils createQRCodeFromString:[NSString stringWithFormat:@"http://my.oschina.net/u/%llu", [Config getOwnID]]];
        _myQRCodeImageView = [[UIImageView alloc] initWithImage:myQRCode];
    }
    
    return _myQRCodeImageView;
}




@end
