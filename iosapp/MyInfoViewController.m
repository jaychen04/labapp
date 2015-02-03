//
//  MyInfoViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/10/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "MyInfoViewController.h"
#import "OSCUser.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "SwipeableViewController.h"
#import "FavoritesViewController.h"
#import "FriendsViewController.h"
#import "BlogsViewController.h"
#import "EventsViewController.h"
#import "MessagesViewController.h"
#import "LoginViewController.h"
#import "SearchViewController.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <RESideMenu.h>

@interface MyInfoViewController ()

@property (nonatomic, strong) OSCUser *user;

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *creditsBtn;
@property (nonatomic, strong) UIButton *collectionsBtn;
@property (nonatomic, strong) UIButton *followsBtn;
@property (nonatomic, strong) UIButton *fansBtn;

@end


@implementation MyInfoViewController

- (instancetype)initWithUser:(OSCUser *)user
{
    self = [super init];
    if (!self) {return nil;}
    
    _user = user;
    
    return self;
}

- (instancetype)initWithUserID:(int64_t)userID
{
    self = [super init];
    if (!self) {return self;}
    
    __block BOOL done = NO;
    __block OSCUser *tmpUser;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@?uid=%lld&hisuid=%lld&pageIndex=0&pageSize=20", OSCAPI_PREFIX, OSCAPI_USER_INFORMATION, [Config getOwnID], userID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             ONOXMLElement *userXML = [responseDocument.rootElement firstChildWithTag:@"user"];
             tmpUser = [[OSCUser alloc] initWithXML:userXML];
             done = YES;
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"网络异常，错误码：%ld", (long)error.code);
             done = YES;
         }];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    _user = tmpUser;
    
    return self;
}


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
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor colorWithHex:0x00CD66];
    
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:25];
    [_portrait loadPortrait:_user.portraitURL];
    _portrait.userInteractionEnabled = YES;
    [_portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortrait)]];
    [header addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    _nameLabel.text = _user.name;
    [header addSubview:_nameLabel];
    
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
    
    setButtonStyle(_creditsBtn, [NSString stringWithFormat:@"积分\n%lu", (long)_user.score]);
    setButtonStyle(_collectionsBtn, [NSString stringWithFormat:@"收藏\n83", nil]);
    setButtonStyle(_followsBtn, [NSString stringWithFormat:@"关注\n%lu", (unsigned long)_user.followersCount]);
    setButtonStyle(_fansBtn, [NSString stringWithFormat:@"粉丝\n%lu", (unsigned long)_user.fansCount]);
    
    [_collectionsBtn addTarget:self action:@selector(pushFavoriteSVC) forControlEvents:UIControlEventTouchUpInside];
    [_followsBtn addTarget:self action:@selector(pushFriendsSVC) forControlEvents:UIControlEventTouchUpInside];
    [_fansBtn addTarget:self action:@selector(pushFriendsSVC) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIView *view in header.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    for (UIView *view in countView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _nameLabel, _creditsBtn, _collectionsBtn, _followsBtn, _fansBtn, countView);
    NSDictionary *metrics = @{@"width": @(tableView.frame.size.width / 4)};
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_portrait(50)]-8-[_nameLabel]-15-[countView(50)]|"
                                                                   options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(50)]" options:0 metrics:nil views:views]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[countView]|" options:0 metrics:nil views:views]];
    
    
    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_creditsBtn(width)][_collectionsBtn(width)][_followsBtn(width)][_fansBtn(width)]|"
                                                                      options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_creditsBtn]|" options:0 metrics:nil views:views]];
    
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
    switch (indexPath.row) {
        case 0: {
            [self.navigationController pushViewController:[[SwipeableViewController alloc] initWithTitle:@"消息中心"
                                                                                            andSubTitles:@[@"@我", @"评论", @"留言", @"粉丝"]
                                                                                          andControllers:@[
                                                                                                           [[EventsViewController alloc] initWithCatalog:2],
                                                                                                           [[EventsViewController alloc] initWithCatalog:3],
                                                                                                           [MessagesViewController new],
                                                                                                           [[FriendsViewController alloc] initWithUserID:_user.userID andFriendsRelation:0]
                                                                                                           ]]
                                                 animated:YES]; break;
        }
        case 1: {
            [self.navigationController pushViewController:[[BlogsViewController alloc] initWithUserID:_user.userID] animated:YES];
            break;
        }
        case 2: {
             break;
        }
        case 3: {
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
    SwipeableViewController *favoritesSVC = [[SwipeableViewController alloc] initWithTitle:@"收藏"
                                                                              andSubTitles:@[@"软件", @"话题", @"代码", @"博客", @"资讯"]
                                                                            andControllers:@[
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeSoftware],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeTopic],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeCode],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeBlog],
                                                                                             [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeNews]
                                                                                             ]];
    
    [self.navigationController pushViewController:favoritesSVC animated:YES];
}

- (void)pushFriendsSVC
{
    SwipeableViewController *friendsSVC = [[SwipeableViewController alloc] initWithTitle:@"关注/粉丝"
                                                                            andSubTitles:@[@"关注", @"粉丝"]
                                                                          andControllers:@[
                                                                                           [[FriendsViewController alloc] initWithUserID:_user.userID andFriendsRelation:1],
                                                                                           [[FriendsViewController alloc] initWithUserID:_user.userID andFriendsRelation:0]
                                                                                           ]];
    
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
    if ([Config getOwnID] == 0)
    {
        [self.navigationController pushViewController:[LoginViewController new] animated:YES];
    }
}





@end
