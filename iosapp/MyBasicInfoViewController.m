//
//  MyBasicInfoViewController.m
//  iosapp
//
//  Created by 李萍 on 15/2/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "MyBasicInfoViewController.h"

#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "OSCMyInfo.h"
#import "Config.h"
#import "Utils.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <RESideMenu.h>

@interface MyBasicInfoViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) OSCMyInfo *myInfo;
@property (nonatomic, readonly, assign) int64_t myID;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation MyBasicInfoViewController

- (instancetype)initWithMyInformation:(OSCMyInfo *)myInfo
{
    self = [super self];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _myInfo = myInfo;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
    self.navigationItem.title = @"我的资料";
    self.view.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
}


#pragma mark - Table view data source

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
    _nameLabel.text = _myInfo.name;
    [header addSubview:_nameLabel];
    
    for (UIView *view in header.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _nameLabel);
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_portrait(50)]-8-[_nameLabel]-8-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(50)]" options:0 metrics:nil views:views]];
    
    [header addConstraint:[NSLayoutConstraint constraintWithItem:_portrait attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:header attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    
    return header;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[UIColor grayColor]};
    NSArray *title = @[@"加入时间：", @"所在地区：", @"开发平台：", @"专长领域："];
    
    NSString *joinTime = [_myInfo.joinTime componentsSeparatedByString:@" "][0];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title[indexPath.row]
                                                                                       attributes:titleAttributes];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@[
                                                                                       joinTime,
                                                                                       _myInfo.hometown,
                                                                                       _myInfo.developPlatform,
                                                                                       _myInfo.expertise
                                                                                       ][indexPath.row]]];
    
    cell.textLabel.attributedText = [attributedText copy];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 111;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tapPortrait
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"更换头像" otherButtonTitles:@"查看大头像", nil];
    
    [actionSheet showInView:self.view];
}









@end
