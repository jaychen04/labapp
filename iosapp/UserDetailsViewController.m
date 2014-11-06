//
//  UserDetailsViewController.m
//  iosapp
//
//  Created by ChanAetern on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "OSCUser.h"
#import "Utils.h"
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

- (instancetype)initWithUser:(OSCUser *)user
{
    self = [super init];
    if (!self) {return nil;}
    
    self.user = user;
    self.swipeableVC = [[SwipeableViewController alloc] initWithTitle:nil
                                                         andSubTitles:@[@"动态", @"博客"]
                                                       andControllers:@[
                                                                        [[TweetsViewController alloc] initWithUserID:user.userID],
                                                                        [[BlogsViewController alloc] initWith
                                                                        ]];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor themeColor];
    
    [self setLayout];
    [self setContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Layout

- (void)setLayout
{
    UIView *headerView = [UIView new];
    [self setHeaderView:headerView];
    [self.view addSubview:headerView];
    
    UIView *middleView = [UIView new];
    [self setMiddleView:middleView];
    [self.view addSubview:middleView];
    
    UIView *mainView = self.swipeableVC.view;
    [self.view addSubview:mainView];
    
    for (UIView *subView in [self.view subviews]) {subView.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(headerView, middleView, mainView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerView][middleView][mainView]|"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[headerView]|" options:0 metrics:nil views:viewsDict]];
}

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
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_portrait(80)]-8-[_nameLabel]-8-[_countLabel]-5-|"
                                                                       options:NSLayoutFormatAlignAllCenterX
                                                                       metrics:nil
                                                                         views:viewsDict]];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(80)]" options:0 metrics:nil views:viewsDict]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerView]-<=1-[_portrait]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDict]];
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
    
    [middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_followButton(30)]-10-|" options:0 metrics:nil views:viewsDict]];
    [middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[_followButton(100)]->=10-[messageButton(100)]-20-|"
                                                                       options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                       metrics:nil views:viewsDict]];
}




#pragma mark - Content

- (void)setContent
{
    [_portrait sd_setImageWithURL:_user.portraitURL placeholderImage:nil];
    _nameLabel.text = self.user.name;
    _countLabel.text = [NSString stringWithFormat:@"关注 %lu | 粉丝 %lu | 积分 %ld", _user.followersCount, _user.fansCount, _user.score];
    
    //NSString *action = _user.
}




@end
