//
//  HomepageViewController.m
//  iosapp
//
//  Created by AeternChan on 7/18/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "HomepageViewController.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import "OSCUser.h"
#import "SwipableViewController.h"
#import "FriendsViewController.h"
#import "FavoritesViewController.h"
#import "MessageCenter.h"
#import "LoginViewController.h"
#import "MyBasicInfoViewController.h"
#import "TeamAPI.h"
#import "TeamTeam.h"
#import "TeamCenter.h"
#import "AppDelegate.h"
#import "FeedBackViewController.h"
#import "SettingsPage.h"
#import "ActivitiesViewController.h"
#import "MyBlogsViewController.h"
#import "HomeButtonCell.h"
#import "UIScrollView+ScalableCover.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh.h>

static NSString *reuseIdentifier = @"HomeButtonCell";

@interface HomepageViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *portrait;
@property (nonatomic, weak) IBOutlet UIButton *QRCodeButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *myQRCodeImageView;

@property (nonatomic, assign) int64_t myID;
@property (nonatomic, strong) OSCUser *myProfile;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) NSMutableArray *noticeCounts;
@property (nonatomic, assign) int badgeValue;

@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation HomepageViewController

- (void)dawnAndNightMode
{
    self.refreshControl.tintColor = [UIColor refreshControlColor];
    
    [self refreshHeaderView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noticeUpdateHandler:)
                                                 name:OSCAPI_USER_NOTICE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userRefreshHandler:)
                                                 name:@"userRefresh"
                                               object:nil];
    
    _noticeCounts = [NSMutableArray arrayWithArray:@[@(0), @(0), @(0), @(0), @(0)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _imageView.hidden = YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
     _imageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorColor = [UIColor separatorColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeButtonCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self setUpSubviews];
    
    _myID = [Config getOwnID];
    [self refreshHeaderView];
    
    [self refresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}


- (void)refresh
{
    _myID = [Config getOwnID];
    if (_myID == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshHeaderView];
            [self.refreshControl endRefreshing];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSString *str = [NSString stringWithFormat:@"%@%@?uid=%lld", OSCAPI_PREFIX, OSCAPI_MY_INFORMATION, _myID];
        [manager GET:str
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
                 
                 ONOXMLElement *userXML = [responseDocument.rootElement firstChildWithTag:@"user"];
                 _myProfile = [[OSCUser alloc] initWithXML:userXML];
                 
                 [Config updateProfile:_myProfile];
                 
                 [self refreshHeaderView];
                 [self.refreshControl endRefreshing];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
//                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                 HUD.label.text = @"网络异常，加载失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
                 
                 [self.refreshControl endRefreshing];
             }];
    }
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

- (void)pushFriendsSVC:(UIButton *)button
{
    if (button.tag == 1) {
        FriendsViewController *friendVC = [[FriendsViewController alloc] initWithUserID:_myID andFriendsRelation:1];
        friendVC.title = @"关注";
        friendVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:friendVC animated:YES];
    } else {
        FriendsViewController *friendVC = [[FriendsViewController alloc] initWithUserID:_myID andFriendsRelation:0];
        friendVC.title = @"粉丝";
        friendVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:friendVC animated:YES];
    }
}



#pragma mark - customize subviews

- (void)setUpSubviews
{
    [_portrait setBorderWidth:2.0 andColor:[UIColor whiteColor]];
    [_portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortraitAction)]];
    
    [self setCoverImage];
    self.refreshControl.tintColor = [UIColor refreshControlColor];
}



- (void)tapPortraitAction
{
    if (![Utils isNetworkExist]) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = @"网络无连接，请检查网络";
        
        [HUD hideAnimated:YES afterDelay:1];
    } else {
        if ([Config getOwnID] == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController pushViewController:loginVC animated:YES];
        } else {
            MyBasicInfoViewController *basicInfoVC = [MyBasicInfoViewController new];
            basicInfoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:basicInfoVC animated:YES];
        }
    }
}


#pragma mark - refresh header

- (void)refreshHeaderView
{
    _myProfile = [Config myProfile];
    
    _isLogin = _myID != 0;
    
    if (_isLogin) {
        [_portrait sd_setImageWithURL:_myProfile.portraitURL
                     placeholderImage:[UIImage imageNamed:@"default-portrait"]
                              options:SDWebImageContinueInBackground | SDWebImageHandleCookies
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (!image) {return;}
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"TweetUserUpdate" object:@(YES)];
                            }];
        
        [_QRCodeButton addTarget:self action:@selector(showQRCode) forControlEvents:UIControlEventTouchUpInside];
    } else {
        
        _portrait.image = [UIImage imageNamed:@"default-portrait"];
    }
    
    _nameLabel.text = _isLogin ? _myProfile.name : @"点击头像登录";
    
    [self setCoverImage];
    
    _QRCodeButton.hidden = !_isLogin;
}


- (void)setCoverImage
{
    NSString *imageName = @"bg_my";
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        imageName = @"bg_my_dark";
    }
    
    if (!self.tableView.scalableCover) {
        [self.tableView addScalableCoverWithImage:[UIImage imageNamed:imageName]];
    } else {
        self.tableView.scalableCover.image = [UIImage imageNamed:imageName];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isLogin) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_isLogin) {
        switch (section) {
            case 0:
                return 4;
                break;
            case 1:
                return 1;
                break;
                
            default:
                break;
        }
    } else {
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return 4;
                break;
            case 2:
                return 1;
                break;
                
            default:
                break;
        }
    }
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isLogin) {
        return 45;
    } else {
        if (indexPath.section == 0) {
            return 61;
        } else {
            return 45;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isLogin) {
        UITableViewCell *cell = [UITableViewCell new];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [cell setSelectedBackgroundView:selectedBackground];
        
        cell.backgroundColor = [UIColor whiteColor];//colorWithHex:0xF9F9F9
        
        if (indexPath.section == 0) {
            cell.textLabel.text = @[@"我的消息", @"我的博客", @"我的活动", @"我的团队"][indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@[@"ic_my_messege", @"ic_my_blog", @"ic_my_event", @"ic_my_team"][indexPath.row]];
        } else {
            cell.textLabel.text = @[@"设置"][indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@[@"ic_my_setting"][indexPath.row]];
            
        }
        
        
        cell.textLabel.textColor = [UIColor titleColor];
        
        if (indexPath.row == 0 && indexPath.section == 1) {
            if (_badgeValue == 0) {
                cell.accessoryView = nil;
            } else {
                UILabel *accessoryBadge = [UILabel new];
                accessoryBadge.backgroundColor = [UIColor redColor];
                accessoryBadge.text = [@(_badgeValue) stringValue];
                accessoryBadge.textColor = [UIColor whiteColor];
                accessoryBadge.textAlignment = NSTextAlignmentCenter;
                accessoryBadge.layer.cornerRadius = 11;
                accessoryBadge.clipsToBounds = YES;
                
                CGFloat width = [accessoryBadge sizeThatFits:CGSizeMake(MAXFLOAT, 26)].width + 8;
                width = width > 26? width: 22;
                accessoryBadge.frame = CGRectMake(0, 0, width, 22);
                cell.accessoryView = accessoryBadge;
            }
        }
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return cell;
    } else {
        if (indexPath.section == 0) {
            
            HomeButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [buttonCell.creditButton setTitle:[NSString stringWithFormat:@"%@", @(_myProfile.score)] forState:UIControlStateNormal];
            [buttonCell.collectionButton setTitle:[NSString stringWithFormat:@"%@", @(_myProfile.favoriteCount)] forState:UIControlStateNormal];
            [buttonCell.followingButton setTitle:[NSString stringWithFormat:@"%@", @(_myProfile.followersCount)] forState:UIControlStateNormal];
            [buttonCell.fanButton setTitle:[NSString stringWithFormat:@"%@", @(_myProfile.fansCount)] forState:UIControlStateNormal];
            
            [buttonCell.collectionButton addTarget:self action:@selector(pushFavoriteSVC) forControlEvents:UIControlEventTouchUpInside];
            [buttonCell.collectionTitleButton addTarget:self action:@selector(pushFavoriteSVC) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonCell.followingTitleButton addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCell.followingButton addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonCell.fanButton addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCell.fanTitleButton addTarget:self action:@selector(pushFriendsSVC:) forControlEvents:UIControlEventTouchUpInside];
            
            return buttonCell;
        } else {
            
            UITableViewCell *cell = [UITableViewCell new];
            //        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIView *selectedBackground = [UIView new];
            selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
            [cell setSelectedBackgroundView:selectedBackground];
            
            cell.backgroundColor = [UIColor whiteColor];//colorWithHex:0xF9F9F9
            
            if (indexPath.section == 1) {
                cell.textLabel.text = @[@"我的消息", @"我的博客", @"我的活动", @"我的团队"][indexPath.row];
                cell.imageView.image = [UIImage imageNamed:@[@"ic_my_messege", @"ic_my_blog", @"ic_my_event", @"ic_my_team"][indexPath.row]];
            } else {
                cell.textLabel.text = @[@"设置"][indexPath.row];
                cell.imageView.image = [UIImage imageNamed:@[@"ic_my_setting"][indexPath.row]];
                
            }
            
            
            cell.textLabel.textColor = [UIColor titleColor];
            
            if (indexPath.row == 0 && indexPath.section == 1) {
                if (_badgeValue == 0) {
                    cell.accessoryView = nil;
                } else {
                    UILabel *accessoryBadge = [UILabel new];
                    accessoryBadge.backgroundColor = [UIColor redColor];
                    accessoryBadge.text = [@(_badgeValue) stringValue];
                    accessoryBadge.textColor = [UIColor whiteColor];
                    accessoryBadge.textAlignment = NSTextAlignmentCenter;
                    accessoryBadge.layer.cornerRadius = 11;
                    accessoryBadge.clipsToBounds = YES;
                    
                    CGFloat width = [accessoryBadge sizeThatFits:CGSizeMake(MAXFLOAT, 26)].width + 8;
                    width = width > 26? width: 22;
                    accessoryBadge.frame = CGRectMake(0, 0, width, 22);
                    cell.accessoryView = accessoryBadge;
                }
            }
            
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
            
            return cell;
        }
    }
    
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_isLogin) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            SettingsPage *settingPage = [SettingsPage new];
            settingPage.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingPage animated:YES];
        } else {
            if ([Config getOwnID] == 0) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                [self.navigationController pushViewController:loginVC animated:YES];
                return;
            }
            
            if (indexPath.section == 0) {
                switch (indexPath.row) {
                    case 0: {
                        _badgeValue = 0;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        });
                        self.navigationController.tabBarItem.badgeValue = nil;
                        
                        MessageCenter *messageCenterVC = [[MessageCenter alloc] initWithNoticeCounts:_noticeCounts];
                        messageCenterVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:messageCenterVC animated:YES];
                        
                        break;
                    }
                    case 1: {
                        MyBlogsViewController *blogsVC = [[MyBlogsViewController alloc] initWithUserID:_myID];
                        blogsVC.navigationItem.title = @"我的博客";
                        blogsVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:blogsVC animated:YES];
                        break;
                    }
                    case 2: {
                        ActivitiesViewController *myActivitiesVc = [[ActivitiesViewController alloc] initWithUID:[Config getOwnID]];
                        myActivitiesVc.navigationItem.title = @"我的活动";
                        myActivitiesVc.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:myActivitiesVc animated:YES];
                        break;
                    }
                    case 3: {
                        TeamCenter *teamCenter = [TeamCenter new];
                        teamCenter.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:teamCenter animated:YES];
                        
                        break;
                    }
                    default: break;
                }
            }
        }
    } else {
        if (indexPath.section == 2 && indexPath.row == 0) {
            SettingsPage *settingPage = [SettingsPage new];
            settingPage.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingPage animated:YES];
        } else {
            if ([Config getOwnID] == 0) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                [self.navigationController pushViewController:loginVC animated:YES];
                return;
            }
            
            if (indexPath.section == 1) {
                switch (indexPath.row) {
                    case 0: {
                        _badgeValue = 0;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        });
                        self.navigationController.tabBarItem.badgeValue = nil;
                        
                        MessageCenter *messageCenterVC = [[MessageCenter alloc] initWithNoticeCounts:_noticeCounts];
                        messageCenterVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:messageCenterVC animated:YES];
                        
                        break;
                    }
                    case 1: {
                        MyBlogsViewController *blogsVC = [[MyBlogsViewController alloc] initWithUserID:_myID];
                        blogsVC.navigationItem.title = @"我的博客";
                        blogsVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:blogsVC animated:YES];
                        break;
                    }
                    case 2: {
                        ActivitiesViewController *myActivitiesVc = [[ActivitiesViewController alloc] initWithUID:[Config getOwnID]];
                        myActivitiesVc.navigationItem.title = @"我的活动";
                        myActivitiesVc.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:myActivitiesVc animated:YES];
                        break;
                    }
                    case 3: {
                        TeamCenter *teamCenter = [TeamCenter new];
                        teamCenter.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:teamCenter animated:YES];
                        
                        break;
                    }
                    default: break;
                }
            }
        }
    }
    
    
}


#pragma mark - 二维码相关

- (void)showQRCode
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView.backgroundColor = [UIColor whiteColor];
    
    HUD.label.text = @"扫一扫上面的二维码，加我为好友";
    HUD.label.font = [UIFont systemFontOfSize:13];
    HUD.label.textColor = [UIColor grayColor];
    HUD.customView = self.myQRCodeImageView;
    [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD:)]];
}

- (void)hideHUD:(UIGestureRecognizer *)recognizer
{
    [(MBProgressHUD *)recognizer.view hideAnimated:YES];
}

- (UIImageView *)myQRCodeImageView
{
    if (!_myQRCodeImageView) {
        UIImage *myQRCode = [Utils createQRCodeFromString:[NSString stringWithFormat:@"http://my.oschina.net/u/%llu", [Config getOwnID]]];
        _myQRCodeImageView = [[UIImageView alloc] initWithImage:myQRCode];
    }
    
    return _myQRCodeImageView;
}


#pragma mark - 处理通知

- (void)noticeUpdateHandler:(NSNotification *)notification
{
    NSArray *noticeCounts = [notification object];
    
    __block int sumOfCount = 0;
    [noticeCounts enumerateObjectsUsingBlock:^(NSNumber *count, NSUInteger idx, BOOL *stop) {
        _noticeCounts[idx] = count;
        sumOfCount += [count intValue];
    }];
    
    _badgeValue = sumOfCount;
    if (_badgeValue) {
        self.navigationController.tabBarItem.badgeValue = [@(sumOfCount) stringValue];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    });
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:sumOfCount];
}


- (void)userRefreshHandler:(NSNotification *)notification
{
    _myID = [Config getOwnID];
    
    [self refreshHeaderView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
