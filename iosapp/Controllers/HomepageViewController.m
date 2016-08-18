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
#import "HomePageHeadView.h"
#import "ImageViewerController.h"

#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh.h>

static NSString *reuseIdentifier = @"HomeButtonCell";


#define screen_height [UIScreen mainScreen].bounds.size.height - 108
@interface HomepageViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *myQRCodeImageView;

@property (nonatomic, assign) int64_t myID;
@property (nonatomic, strong) OSCUser *myProfile;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) NSMutableArray *noticeCounts;
@property (nonatomic, assign) int badgeValue;

@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) HomePageHeadView *homePageHeadView;


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
    
    self.tableView.tableHeaderView = self.homePageHeadView;
    
    [self hideStatusBar:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    

    [self hideStatusBar:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.homePageHeadView.genderImageView.hidden = YES;
    
     _imageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorColor = [UIColor separatorColor];
    self.tableView.tableHeaderView = self.homePageHeadView;
    self.tableView.bounces = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeButtonCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    [self setUpSubviews];
    
    _myID = [Config getOwnID];
    [self refreshHeaderView];
    
    [self refresh];
    
    [self.homePageHeadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortraitAction)]];
    self.homePageHeadView.userInteractionEnabled = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 状态栏、导航栏处理
- (void)hideStatusBar:(BOOL)hidden
{
    if (hidden) {
        UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 20)];
        statusBarView.backgroundColor=[UIColor colorWithHex:0x24CF5F];
        [self.view addSubview:statusBarView];

        self.navigationController.navigationBarHidden = YES;
    } else {

        self.navigationController.navigationBarHidden = NO;
    }
    
}

#pragma mark - 处理导航栏下1px横线
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

#pragma mark - 刷新
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
                 
                 if ([_myProfile.gender isEqualToString:@"1"]) {
                     [self.homePageHeadView.genderImageView setImage:[UIImage imageNamed:@"ic_male"]];
                     self.homePageHeadView.genderImageView.hidden = NO;
                 } else if ([_myProfile.gender isEqualToString:@"2"]) {
                     [self.homePageHeadView.genderImageView setImage:[UIImage imageNamed:@"ic_female"]];
                     self.homePageHeadView.genderImageView.hidden = NO;
                 }
                 
                 [Config updateProfile:_myProfile];
                 
                 [self refreshHeaderView];
                 [self.refreshControl endRefreshing];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，加载失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
                 
                 [self.refreshControl endRefreshing];
             }];
        
        
        //新用户信息接口
        /*
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
        
        NSString *strUrl = [NSString stringWithFormat:@"%@user_me", OSCAPI_V2_PREFIX];
        
        [manager GET:strUrl
          parameters:nil
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 //
                 NSDictionary* result = responseObject[@"result"];
                 NSLog(@"result = %@", result);
             } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 //
                 NSLog(@"error= %@", error);
        }];
        */
    }
}

#pragma mark - refresh header

- (void)refreshHeaderView
{
    _myProfile = [Config myProfile];
    
    _isLogin = _myID != 0;
    
    if (_isLogin) {
        [self.homePageHeadView.userPortrait sd_setImageWithURL:_myProfile.portraitURL
                     placeholderImage:[UIImage imageNamed:@"default-portrait"]
                              options:SDWebImageContinueInBackground | SDWebImageHandleCookies
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (!image) {return;}
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"TweetUserUpdate" object:@(YES)];
                            }];
        self.homePageHeadView.descLable.hidden = NO;
        self.homePageHeadView.creditLabel.hidden = NO;
        self.homePageHeadView.creditLabel.text = [NSString stringWithFormat:@"积分:%d", _myProfile.score];
        
        [self.homePageHeadView.setUpButton addTarget:self action:@selector(setUpAction) forControlEvents:UIControlEventTouchUpInside];
        [self.homePageHeadView.codeButton addTarget:self action:@selector(showCodeAction) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        
        self.homePageHeadView.userPortrait.image = [UIImage imageNamed:@"default-portrait"];
        self.homePageHeadView.descLable.hidden = YES;
        self.homePageHeadView.creditLabel.hidden = YES;
    }
    
    self.homePageHeadView.nameLabel.text = _isLogin ? _myProfile.name : @"点击头像登录";

}


#pragma mark - customize subviews

- (void)setUpSubviews
{
    [self.homePageHeadView.userPortrait setBorderWidth:2.0 andColor:[UIColor whiteColor]];
    [self.homePageHeadView.userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePortraitAction)]];
    
    self.refreshControl.tintColor = [UIColor refreshControlColor];
}

- (void)changePortraitAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择操作" message:nil delegate:self
                                              cancelButtonTitle:@"取消" otherButtonTitles:@"更换头像", @"查看大头像", nil];
    alertView.tag = 1;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {return;}
    
    if (alertView.tag == 1)
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else if (buttonIndex == 1){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择图片" message:nil delegate:self
                                                      cancelButtonTitle:@"取消" otherButtonTitles:@"相机", @"相册", nil];
            alertView.tag = 2;
            
            [alertView show];
            
        } else {
            
            NSString *str = [NSString stringWithFormat:@"%@", _myProfile.portraitURL];
            
            if (str.length == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"尚未设置头像" message:nil delegate:self
                                                          cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                [alertView show];
                return ;
            }
            
            NSArray *array1 = [str componentsSeparatedByString:@"_"];
            
            NSArray *array2 = [array1[1] componentsSeparatedByString:@"."];
            
            NSString *bigPortraitURL = [NSString stringWithFormat:@"%@_200.%@", array1[0], array2[1]];
            
            ImageViewerController *imgViewweVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:bigPortraitURL]];
            
            [self presentViewController:imgViewweVC animated:YES completion:nil];
        }
        
    } else {
        if (buttonIndex == 1) {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Device has no camera"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                
                [alertView show];
            } else {
                UIImagePickerController *imagePickerController = [UIImagePickerController new];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.allowsEditing = YES;
                imagePickerController.showsCameraControls = YES;
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
            
            
        } else {
            UIImagePickerController *imagePickerController = [UIImagePickerController new];
            imagePickerController.delegate = self;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.allowsEditing = YES;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}

- (void)updatePortrait
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"正在上传头像";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_USERINFO_UPDATE] parameters:@{@"uid":@([Config getOwnID])}
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    if (_image) {
        [formData appendPartWithFileData:[Utils compressImage:_image] name:@"portrait" fileName:@"img.jpg" mimeType:@"image/jpeg"];
    }
} success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDoment) {
    ONOXMLElement *result = [responseDoment.rootElement firstChildWithTag:@"result"];
    int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
    NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
    
    HUD.mode = MBProgressHUDModeCustomView;
    if (errorCode) {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
        HUD.label.text = @"头像更新成功";
        
        HomepageViewController *homepageVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        [homepageVC refresh];
        
        self.homePageHeadView.userPortrait.image = _image;
    } else {
        //            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        HUD.label.text = errorMessage;
    }
    [HUD hideAnimated:YES afterDelay:1];
    
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    HUD.mode = MBProgressHUDModeCustomView;
    //        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
    HUD.label.text = @"网络异常，头像更换失败";
    
    [HUD hideAnimated:YES afterDelay:1];
}];
}


#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self updatePortrait];
    }];
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


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isLogin) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_isLogin) {
        return 4;
    } else {
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return 4;
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
        
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.textLabel.text = @[@"我的消息", @"我的博客", @"我的活动", @"我的团队"][indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@[@"ic_my_messege", @"ic_my_blog", @"ic_my_event", @"ic_my_team"][indexPath.row]];
        
        
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
            
            [buttonCell.creditButton setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];//动弹数
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
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIView *selectedBackground = [UIView new];
            selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
            [cell setSelectedBackgroundView:selectedBackground];
            
            cell.backgroundColor = [UIColor whiteColor];//colorWithHex:0xF9F9F9
            
            cell.textLabel.text = @[@"我的消息", @"我的博客", @"我的活动", @"我的团队"][indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@[@"ic_my_messege", @"ic_my_blog", @"ic_my_event", @"ic_my_team"][indexPath.row]];
            
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
                    MyBlogsViewController *blogsVC = [[MyBlogsViewController alloc] initWithUserID:(NSInteger)_myID];
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
                    MyBlogsViewController *blogsVC = [[MyBlogsViewController alloc] initWithUserID:(NSInteger)_myID];
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

#pragma mark - 功能
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

#pragma mark - setup
- (void)setUpAction {
    SettingsPage *settingPage = [SettingsPage new];
    settingPage.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingPage animated:YES];
}

#pragma mark - 二维码相关
- (void)showCodeAction {
    
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView.backgroundColor = [UIColor whiteColor];

        HUD.label.text = @"扫一扫上面的二维码，加我为好友";
        HUD.label.font = [UIFont systemFontOfSize:13];
        HUD.label.textColor = [UIColor grayColor];
        HUD.customView = self.myQRCodeImageView;
        [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD:)]];
    }
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

#pragma mark - 初始化
- (HomePageHeadView *)homePageHeadView {
    if(_homePageHeadView == nil) {
        if ([UIScreen mainScreen].bounds.size.height < 500) {
            
            _homePageHeadView = [[HomePageHeadView alloc] initWithFrame:(CGRect){{0,0},{[UIScreen mainScreen].bounds.size.width, 250}}];
        } else {
            
            _homePageHeadView = [[HomePageHeadView alloc] initWithFrame:(CGRect){{0,0},{[UIScreen mainScreen].bounds.size.width, screen_height - 205}}];
        }
        
    }
    return _homePageHeadView;
}

@end
