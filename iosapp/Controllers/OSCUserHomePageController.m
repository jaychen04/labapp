//
//  OSCUserHomePageController.m
//  iosapp
//
//  Created by Graphic-one on 16/9/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCUserHomePageController.h"
#import "UserDrawHeaderView.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "OSCUserItem.h"
#import "OSCTweetItem.h"
#import "OSCNewHotBlog.h"
#import "OSCQuestion.h"
#import "OSCDiscuss.h"

#import "AsyncDisplayTableViewCell.h"
#import "OSCTextTweetCell.h"
#import "OSCImageTweetCell.h"
#import "OSCMultipleTweetCell.h"
#import "NewHotBlogTableViewCell.h"
#import "QuesAnsTableViewCell.h"

#import "LoginViewController.h"
#import "FriendsViewController.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>

#define HEADER_VIEW_HEIGHT 350

/** key */
static NSString* const requestUrl = @"requestUrlString";
static NSString* const requestParameter = @"requestParameterString";

@interface OSCUserHomePageController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSUInteger _currentIndex;
}
@property (nonatomic,strong) NSMutableArray<UIButton* >* buttons;
@property (nonatomic,strong) NSMutableArray<NSString* >* nextTokens;
@property (nonatomic,strong) NSMutableArray<NSMutableArray* >* dataSources;

@property (nonatomic,strong) OSCUserHomePageItem* user;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) UserDrawHeaderView* headerCanvasView;
@property (nonatomic,strong) UIView* sectionHeaderView;

@end

@implementation OSCUserHomePageController{
//左右naviBarItem
    UIButton* _rightBarMessageBtn;
    UIButton* _rightBaFollowrBtn;
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
    }
    return self;
}
- (instancetype)initWithUserName:(NSString *)userName{
    self = [super init];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _userName = userName;
        _userID = NSNotFound;
    }
    return self;
}


#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self settingSomthing];
    [self layoutUI];
    [self getCurrentUserInfo];
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

#pragma mark --- Setting default value
- (void)settingSomthing{
}

#pragma mark --- layout
- (void)layoutUI{
    [self.view addSubview:self.tableView];

    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [self getDataThroughDropdown:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getDataThroughDropdown:NO];
    }];
    
    _currentIndex = 4;
    [self.tableView.mj_header beginRefreshing];
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
- (void)getDataThroughDropdown:(BOOL)dropDown{//YES:下拉  NO:上拉
    NSMutableDictionary* parameterDic = @{}.mutableCopy;
    
    NSDictionary* materialDic = [self getRequestMaterial:_currentIndex];
    NSString* urlStr = materialDic[requestUrl];
    NSString* parameterStr = materialDic[requestParameter];

    [parameterDic setValue:@(_user.id) forKey:parameterStr];
    if (!dropDown && self.nextTokens[_currentIndex].length > 0) {
        [parameterDic setValue:self.nextTokens[_currentIndex] forKey:@"nextPageToken"];
    }
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    MBProgressHUD *HUD = [Utils createHUD];

    [manger GET:urlStr
     parameters:[parameterDic copy]
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                self.nextTokens[_currentIndex] = resultDic[@"nextPageToken"];
                
                NSArray* models = [self handleOriginal_JSON:resultDic currentIndex:_currentIndex];
                if (dropDown) {
                    [self.dataSources[_currentIndex] removeAllObjects];
                }
                [self.dataSources[_currentIndex] addObjectsFromArray:models];
                
            }else{
                HUD.label.text = @"未知错误";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
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


#pragma mark --- UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSources[_currentIndex].count;
}
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* dataSource = [self.dataSources[_currentIndex] copy];

    
    return [UITableViewCell new];
}

#pragma mark --- setting NaviBar Item
//-(void)settingNaviBarItem{
//    _rightBarMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _rightBarMessageBtn.userInteractionEnabled = YES;
//    _rightBarMessageBtn.frame  = CGRectMake(0, 0, 36, 36);
//    [_rightBarMessageBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
//    [_rightBaFollowrBtn setTitle:@"" forState:UIControlStateNormal];
//    [_rightBarMessageBtn setBackgroundImage:[UIImage imageNamed:@"btn_pm_normal"] forState:UIControlStateNormal];
//    [_rightBarMessageBtn setBackgroundImage:[UIImage imageNamed:@"btn_pm_pressed"] forState:UIControlStateHighlighted];
//    
//    _rightBaFollowrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _rightBaFollowrBtn.userInteractionEnabled = YES;
//    _rightBaFollowrBtn.frame  = CGRectMake(0, 0, 36, 36);
//    [_rightBaFollowrBtn addTarget:self action:@selector(updateRelationship) forControlEvents:UIControlEventTouchUpInside];
//    [_rightBaFollowrBtn setTitle:@"" forState:UIControlStateNormal];
////    [self updateRelationshipImage];
//    
//    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:_rightBaFollowrBtn] ,[[UIBarButtonItem alloc] initWithCustomView:_rightBarMessageBtn]];;
//}
- (void)sendMessage{
    if ([Config getOwnID] == 0) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = @"请先登录";
        [HUD hideAnimated:YES afterDelay:0.5];
    } else {
//        [self.navigationController pushViewController:[[BubbleChatViewController alloc] initWithUserID:_user.userID andUserName:_user.name] animated:YES];
    }
}
//- (void)updateRelationship{
//    if ([Config getOwnID] == 0) {
//        [self.navigationController pushViewController:[LoginViewController new] animated:YES];
//    } else {
//        MBProgressHUD *HUD = [Utils createHUD];
//        
//        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
//        [manger POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_USER_RELATION_REVERSE] parameters:@{
//                                                                                                                          @"id" : @(_user.userID)
//                                                                                                                          }
//             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//                 if ([responseObject[@"code"] floatValue] == 1) {
//                     NSDictionary* resultDic = responseObject[@"result"];
//                     _user.relationship = [resultDic[@"relation"] intValue];
//                     
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         HUD.mode = MBProgressHUDModeCustomView;
//                         if (_user.relationship == 1 || _user.relationship == 2) {
//                             HUD.label.text = @"关注成功";
//                         }else{
//                             HUD.label.text = @"取消关注";
//                         }
//                         
//                         [HUD hideAnimated:YES afterDelay:1];
//                         [self updateRelationshipImage];
//                     });
//                 }else{
//                     HUD.mode = MBProgressHUDModeCustomView;
//                     HUD.label.text = @"数据异常";
//                     
//                     [HUD hideAnimated:YES afterDelay:1];
//                 }
//             }
//             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//                 HUD.mode = MBProgressHUDModeCustomView;
//                 HUD.label.text = @"网络异常，操作失败";
//                 
//                 [HUD hideAnimated:YES afterDelay:1];
//             }];
//    }
//}
//-(void)updateRelationshipImage{
//    UIImage* relationImageNomal;
//    UIImage* relationImagePress;
//    if (_user.relationship == 1) {
//        relationImageNomal = [UIImage imageNamed:@"btn_following_both_normal"];
//        relationImagePress = [UIImage imageNamed:@"btn_following_both_pressed"];
//    }else if (_user.relationship == 2){
//        relationImageNomal = [UIImage imageNamed:@"btn_following_normal"];
//        relationImagePress = [UIImage imageNamed:@"btn_following_pressed"];
//    }else{
//        relationImageNomal = [UIImage imageNamed:@"btn_follow_normal"];
//        relationImagePress = [UIImage imageNamed:@"btn_follow_pressed"];
//    }
//    
//    [_rightBaFollowrBtn setBackgroundImage:relationImageNomal forState:UIControlStateNormal];
//    [_rightBaFollowrBtn setBackgroundImage:relationImagePress forState:UIControlStateHighlighted];
//}

#pragma mark --- 路由分发
#pragma mark - 获取请求所需 url & parameter(请求的字段名字)
- (NSDictionary* )getRequestMaterial:(NSInteger)currentIndex{
    NSMutableDictionary* materialDic = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString* urlStr = nil;
    NSString* parameter = nil;
    
    if (currentIndex == 1) {
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS_LIST];
        parameter = @"authorId";
    }else if (currentIndex == 2){
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_BLOGS_LIST];
        parameter = @"authorId";
    }else if (currentIndex == 3){
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_QUESTION];
        parameter = @"authorId";
    }else if (currentIndex == 4){
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_ACTIVITY];
        parameter = @"id";
    }
    
    [materialDic setValue:urlStr forKey:requestUrl];
    [materialDic setValue:parameter forKey:requestParameter];
    
    return [materialDic copy];
}
#pragma mark - 处理请求返回的原始JSON
- (NSArray* )handleOriginal_JSON:(NSDictionary* )original_JSON
                    currentIndex:(NSInteger)currentIndex{
    NSArray* models = @[];
    
    switch (currentIndex) {
        case 1:{
            NSArray* items = original_JSON[@"items"];
            models = [OSCTweetItem mj_objectArrayWithKeyValuesArray:items];
            break;
        }
        case 2:{
            NSArray* items = original_JSON[@"items"];
            models = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:items];
            break;
        }
        case 3:{
            NSArray* items = original_JSON[@"items"];
            models = [OSCQuestion mj_objectArrayWithKeyValuesArray:items];
            break;
        }
        case 4:{
            NSArray* items = original_JSON[@"items"];
            models = [OSCDiscuss mj_objectArrayWithKeyValuesArray:items];
            break;
        }
        default:{
            return nil;
            break;
        }
    }
    return models;
}

#pragma mark --- 界面列表分发
- (UITableViewCell* )getCurrentDisplayCell:(NSInteger)currentIdenx{
    switch (currentIdenx) {
        case 1:
            return []
            break;
            
        default:
            break;
    }
}

#pragma mark --- 装配HeaderView
- (void) assemblyHeaderView{
    [self.headerCanvasView setContentWithUserItem:_user];
    self.headerCanvasView.followsBtn.tag = 1;
    self.headerCanvasView.fansBtn.tag = 2;
    
    [self.headerCanvasView.followsBtn addTarget:self action:@selector(pushFriendsVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerCanvasView.fansBtn addTarget:self action:@selector(pushFriendsVC:) forControlEvents:UIControlEventTouchUpInside];
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
		_sectionHeaderView = [[UIView alloc] init];
	}
	return _sectionHeaderView;
}

@end
