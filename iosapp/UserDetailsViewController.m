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
#import "SwipeableViewController.h"
#import "TweetsViewController.h"
#import "BlogsViewController.h"

@interface UserDetailsViewController ()

@property (nonatomic, strong) OSCUser *user;
@property (nonatomic, strong) SwipeableViewController *swipeableVC;

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation UserDetailsViewController


#pragma mark - init method

- (instancetype)initWithUser:(OSCUser *)user
{
    self = [super init];
    if (!self) {return nil;}
    
    self.user = user;
    
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
    self.user = tmpUser;
    
    return self;
}




#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor themeColor];
    
    self.swipeableVC = [[SwipeableViewController alloc] initWithTitle:nil
                                                         andSubTitles:@[@"动态", @"博客"]
                                                       andControllers:@[
                                                                        [[TweetsViewController alloc] initWithUserID:_user.userID],
                                                                        [[BlogsViewController alloc] initWithUserID:_user.userID]
                                                                        ]];
    
    [self addChildViewController:self.swipeableVC];
}

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
    return section ? 1 : 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section ? 43 : 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {return nil;}
    return self.swipeableVC.titleBar;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        return self.view.frame.size.height - 43;
    } else if (indexPath.row) {
        return 51;
    } else {
        return 150;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    if (indexPath.section) {
        self.swipeableVC.viewPager.view.frame = cell.contentView.bounds;
        [cell.contentView addSubview:self.swipeableVC.viewPager.view];
        [self addChildViewController:self.swipeableVC.viewPager];
        [self.swipeableVC.viewPager didMoveToParentViewController:self];
        return cell;
    } else if (indexPath.row) {
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self setMiddleView:cell.contentView];
        return cell;
    } else {
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self setHeaderView:cell.contentView];
        [self setContent];
        return cell;
    }
}





#pragma mark - Layout

- (void)setHeaderView:(UIView *)headerView
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:40];
    [headerView addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    [headerView addSubview:_nameLabel];
    
    _countLabel = [UILabel new];
    [headerView addSubview:_countLabel];
    
    for (UIView *subView in [headerView subviews]) {subView.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_portrait, _nameLabel, _countLabel, headerView);
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_portrait(80)]-8-[_nameLabel]-8-[_countLabel]-5-|"
                                                                       options:NSLayoutFormatAlignAllCenterX
                                                                       metrics:nil
                                                                         views:viewsDict]];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(80)]" options:0 metrics:nil views:viewsDict]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerView]-<=1-[_portrait]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDict]];
    //[headerView addConstraint:[NSLayoutConstraint constraintWithItem:_portrait attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
    //                                                          toItem:_portrait.superview attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    
    //[headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[_portrait(80)]-(>=20)-|" options:0 metrics:nil views:viewsDict]];
}

- (void)setMiddleView:(UIView *)middleView
{
    void (^customizeButton)(UIButton *) = ^(UIButton *button) {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.layer.borderWidth = 0.5;
        [button setTitleColor:[UIColor colorWithHex:0x494949] forState:UIControlStateNormal];
        [button setCornerRadius:5.0];
        button.translatesAutoresizingMaskIntoConstraints = NO;
    };
    
    _followButton = [UIButton new];
    customizeButton(_followButton);
    [_followButton setTitle:@"关注" forState:UIControlStateNormal];         //需要修改
    [middleView addSubview:_followButton];
    
    UIButton *messageButton = [UIButton new];
    customizeButton(messageButton);
    [messageButton setTitle:@"留言" forState:UIControlStateNormal];
    [middleView addSubview:messageButton];
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_followButton, messageButton);
    
    [middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_followButton(30)]->=10-|" options:0 metrics:nil views:viewsDict]];
    [middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[_followButton(100)]->=10-[messageButton(100)]-20-|"
                                                                       options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                       metrics:nil views:viewsDict]];
}




#pragma mark - Content

- (void)setContent
{
    [_portrait sd_setImageWithURL:_user.portraitURL placeholderImage:nil];
    _nameLabel.text = self.user.name;
    _countLabel.text = [NSString stringWithFormat:@"关注 %lu | 粉丝 %lu | 积分 %ld", (unsigned long)_user.followersCount, (unsigned long)_user.fansCount, (long)_user.score];
    
    //NSString *action = _user.
}




@end
