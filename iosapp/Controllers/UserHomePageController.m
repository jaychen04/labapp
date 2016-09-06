//
//  UserHomePageController.m
//  iosapp
//
//  Created by Graphic-one on 16/9/5.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "UserHomePageController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import "UserDrawHeaderView.h"
#import "FriendsViewController.h"
#import "OSCUserItem.h"

#import "UIColor+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <AFNetworking.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define HEADER_VIEW_HEIGHT 350
#define SECTION_HEADER_VIEW_HEIGHT 64

@interface UserHomePageController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSUInteger _currentIndex;
}
@property (nonatomic,strong) NSMutableArray<UIButton* >* buttons;
@property (nonatomic,strong) OSCUserHomePageItem* user;

@property (nonatomic,strong) UserDrawHeaderView* headerCanvasView;
@property (nonatomic,strong) UIView* sectionHeaderView;
@property (nonatomic,strong) UITableView* tableView;

@end

@implementation UserHomePageController{
//请求参数
    NSInteger _userID;
    NSString* _userName;
}
#pragma mark --- Initialization method
- (instancetype)initWithUserID:(NSInteger)userID{
    self = [super init];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _userID = userID;
        _userName = nil;
        [self settingSubControllers];
    }
    return self;
}
- (instancetype)initWithUserName:(NSString *)userName{
    self = [super init];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _userName = userName;
        _userID = NSNotFound;
        [self settingSubControllers];
    }
    return self;
}

- (void)settingSubControllers{

}


#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark --- networking
- (void)getCurrentUserInfo{
    NSString* urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_GET_USER_INFO];
    
    NSMutableDictionary* mutableDic = [NSMutableDictionary dictionaryWithCapacity:1];
    if (_userID != NSNotFound) {
        [mutableDic setObject:@(_userID) forKey:@"id"];
    }else if (_userName != nil){
        [mutableDic setObject:_userName forKey:@"name"];
    }else{
        mutableDic = nil;
    }
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    MBProgressHUD *HUD = [Utils createHUD];
    
    [manger GET:urlStr
     parameters:[mutableDic copy]
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* userResult = responseObject[@"result"];
                _user = [OSCUserHomePageItem mj_objectWithKeyValues:userResult];
            }else{
                HUD.label.text = @"未知错误";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self assemblyHeaderView];
                
                [HUD hideAnimated:YES afterDelay:0.3];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                HUD.label.text = @"网络异常，操作失败";
                [HUD hideAnimated:YES afterDelay:0.3];
            });
        }];
}
//- (void)getDataThroughDropdown:(BOOL)dropDown{//YES:下拉  NO:上拉
//    NSMutableDictionary* parameterDic = @{}.mutableCopy;
//    
//    NSDictionary* materialDic = [self getRequestMaterial:_currentIndex];
//    NSString* urlStr = materialDic[requestUrl];
//    NSString* parameterStr = materialDic[requestParameter];
//    
//    [parameterDic setValue:@(_user.id) forKey:parameterStr];
//    if (!dropDown && self.nextTokens[_currentIndex].length > 0) {
//        [parameterDic setValue:self.nextTokens[_currentIndex] forKey:@"nextPageToken"];
//    }
//    
//    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
//    
//    MBProgressHUD *HUD = [Utils createHUD];
//    
//    [manger GET:urlStr
//     parameters:[parameterDic copy]
//        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            if ([responseObject[@"code"] integerValue] == 1) {
//                NSDictionary* resultDic = responseObject[@"result"];
//                self.nextTokens[_currentIndex] = resultDic[@"nextPageToken"];
//                
//                NSArray* models = [self handleOriginal_JSON:resultDic currentIndex:_currentIndex];
//                if (dropDown) {
//                    [self.dataSources[_currentIndex] removeAllObjects];
//                }
//                [self.dataSources[_currentIndex] addObjectsFromArray:models];
//                
//            }else{
//                HUD.label.text = @"未知错误";
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//                [HUD hideAnimated:YES afterDelay:0.3];
//            });
//        }
//        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                HUD.label.text = @"网络异常，操作失败";
//                [HUD hideAnimated:YES afterDelay:0.3];
//            });
//        }];
//}








#pragma mark --- 装配HeaderView
- (void) assemblyHeaderView{
    [self.headerCanvasView setContentWithUserItem:_user];
    self.headerCanvasView.followsBtn.tag = 1;
    self.headerCanvasView.fansBtn.tag = 2;
    
    [self.headerCanvasView.followsBtn addTarget:self action:@selector(pushFriendsVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerCanvasView.fansBtn addTarget:self action:@selector(pushFriendsVC:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttons[0] setTitle:[NSString stringWithFormat:@"%ld\n动弹",_user.statistics.tweet] forState:UIControlStateNormal];
    [self.buttons[1] setTitle:[NSString stringWithFormat:@"%ld\n博客",_user.statistics.blog] forState:UIControlStateNormal];
    [self.buttons[2] setTitle:[NSString stringWithFormat:@"%ld\n问答",_user.statistics.answer] forState:UIControlStateNormal];
    [self.buttons[3] setTitle:[NSString stringWithFormat:@"%ld\n讨论",_user.statistics.discuss] forState:UIControlStateNormal];
}
#pragma mark - 处理页面跳转
- (void)pushFriendsVC:(UIButton *)button{
    if (button.tag == 1) {//关注
        FriendsViewController* followsVC = [[FriendsViewController alloc]initUserId:_user.id andRelation:OSCAPI_USER_FOLLOWS];
        followsVC.title = @"关注";
        [self.navigationController pushViewController:followsVC animated:YES];
    }else{//粉丝
        FriendsViewController* fansVC = [[FriendsViewController alloc]initUserId:_user.id andRelation:OSCAPI_USER_FANS];
        fansVC.title = @"粉丝";
        [self.navigationController pushViewController:fansVC animated:YES];
    }
}

#pragma mark - 切换tableView & 选择性发送请求
- (void)changeTableViewDataSourceWithButton:(UIButton* )button{

}





#pragma mark --- lazy loading
- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (UserDrawHeaderView *)headerCanvasView {
    if(_headerCanvasView == nil) {
        _headerCanvasView = [[UserDrawHeaderView alloc] initWithFrame:(CGRect){{0,0},{[UIScreen mainScreen].bounds.size.width,HEADER_VIEW_HEIGHT}}];
    }
    return _headerCanvasView;
}
- (UIView *)sectionHeaderView {
    if(_sectionHeaderView == nil) {
        _sectionHeaderView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{SCREEN_WIDTH,SECTION_HEADER_VIEW_HEIGHT}}];
        for (UIButton* button in self.buttons) {
            [_sectionHeaderView addSubview:button];
        }
    }
    return _sectionHeaderView;
}
- (NSMutableArray<UIButton* > *)buttons {
	if(_buttons == nil) {
        for (int i = 0; i < 4; i++) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = (CGRect){{(SCREEN_WIDTH * 0.25) * i,0},{SCREEN_WIDTH * 0.25,SECTION_HEADER_VIEW_HEIGHT}};
            [btn setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateSelected];
            btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn addTarget:self action:@selector(changeTableViewDataSourceWithButton:) forControlEvents:UIControlEventTouchUpInside];
            [_buttons addObject:btn];
        }
    }
	return _buttons;
}

@end
