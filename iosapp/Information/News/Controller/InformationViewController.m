//
//  InformationViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/5/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "InformationViewController.h"
#import "TokenManager.h"
#import "enumList.h"
#import "BannerScrollView.h"

#import "ActivityDetailsWithBarViewController.h"
#import "DetailsViewController.h"
#import "ActivityDetailsWithBarViewController.h"
#import "InformationTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NewsBlogDetailTableViewController.h"
#import "ActivityDetailViewController.h"
#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "TranslationViewController.h"
#import "NewsDetailViewController.h"

#import "OSCInformation.h"
#import "OSCBanner.h"
#import "OSCSoftware.h"
#import "OSCNewHotBlog.h"
#import "OSCPost.h"
#import "Utils.h"
#import "OSCAPI.h"

#import <ReactiveCocoa.h>
#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <MJRefresh.h>


#define OSC_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define OSC_BANNER_HEIGHT 125

static NSString * const informationReuseIdentifier = @"InformationTableViewCell";

@interface InformationViewController () <UITableViewDelegate, UITableViewDataSource, BannerScrollViewDelegate>

@property (nonatomic,strong) BannerScrollView *bannerScrollView;

@property (nonatomic,strong) NSMutableArray* bannerTitles;
@property (nonatomic,strong) NSMutableArray* bannerImageUrls;
@property (nonatomic,strong) NSMutableArray* bannerModels;
@property (nonatomic,strong) NSMutableArray* dataModels;
@property (nonatomic,strong) NSString* nextToken;

@property (nonatomic, strong) NSString *systemDate;

@end


@implementation InformationViewController


#pragma mark - life cycle

- (void)dawnAndNightMode
{
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorColor = [UIColor separatorColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getBannerData];
    [self layoutUI];

    self.tableView.separatorColor = [UIColor separatorColor];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getJsonDataforNews:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getJsonDataforNews:NO];
    }];
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - method
#pragma mark --- 维护用作tableView数据源的数组

-(void)getBannerData{
    NSString* urlStr = [NSString stringWithFormat:@"%@banner", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
	manger.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manger GET:urlStr
     parameters:@{@"catalog" : @1}
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                NSArray* responseArr = resultDic[@"items"];
                NSArray* bannerModels = [OSCBanner mj_objectArrayWithKeyValuesArray:responseArr];
                self.bannerModels = bannerModels.mutableCopy;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self configurationCycleScrollView];
                });
            }
}
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
}];
}


-(void)layoutUI{
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self.tableView registerNib:[UINib nibWithNibName:@"InformationTableViewCell" bundle:nil] forCellReuseIdentifier:informationReuseIdentifier];
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.bannerScrollView = [[BannerScrollView alloc] initWithFrame:CGRectMake(0, 0, OSC_SCREEN_WIDTH, OSC_BANNER_HEIGHT)];
    self.bannerScrollView.delegate = self;
    self.tableView.tableHeaderView = self.bannerScrollView;
}


-(void)configurationCycleScrollView{
    self.bannerScrollView.banners = self.bannerModels;
    [self.tableView reloadData];
}


#pragma mark - tableView datasource && delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataModels.count;
}

-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationTableViewCell* cell = [InformationTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:informationReuseIdentifier];
    cell.contentView.backgroundColor = [UIColor newCellColor];
    
    if (self.dataModels.count > 0) {
        cell.systemTimeDate = _systemDate;
        cell.viewModel = self.dataModels[indexPath.row];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:informationReuseIdentifier configuration:^(InformationTableViewCell* cell) {
        cell.systemTimeDate = _systemDate;
        cell.viewModel = self.dataModels[indexPath.row];
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCInformation* informationModel = self.dataModels[indexPath.row];
    [self pushDetailInformationVC:informationModel];
}

#pragma mark - 列表跳转操作

-(void)pushDetailInformationVC:(OSCInformation* )model{
    switch (model.type) {
        case InformationTypeLinkNews:{
            [self.navigationController handleURL:[NSURL URLWithString:model.href] name:nil];
            break;
        }

        case InformationTypeSoftWare:{
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:model.id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:detailsViewController animated:YES];
            break;
        }
            
        case InformationTypeForum:{
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = model.id;
            detailVC.commentCount = model.commentCount;
            [self.navigationController pushViewController:detailVC animated:YES];
            break;
        }
            
        case InformationTypeBlog:{
            OSCNewHotBlog* blog = [[OSCNewHotBlog alloc]init];
            blog.id = model.id;
            
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:blog.id isBlogDetail:YES];
            newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
            break;
        }
            
        case InformationTypeTranslation:{
            TranslationViewController *translationVc = [TranslationViewController new];
            translationVc.hidesBottomBarWhenPushed = YES;
            translationVc.translationId = model.id;
            [self.navigationController pushViewController:translationVc animated:YES];
            break;
        }
            
        case InformationTypeActivity:{
            //新活动详情页面
            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:model.id];
            activityDetailCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:activityDetailCtl animated:YES];
            break;
        }
        case InformationTypeInfo:{
            //新版资讯详情界面
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:model.id isBlogDetail:NO];
            newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
            
//            NewsDetailViewController *newsDetailsVc = [[NewsDetailViewController alloc]initWithNewsId:model.id];
//            newsDetailsVc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:newsDetailsVc animated:YES];
            break;
        }
       
        default:
            break;
    }
}

#pragma mark -- networking Delegate
-(void)getJsonDataforNews:(BOOL)isRefresh{//yes 下拉 no 上拉
    
    NSString *strUrl = [NSString stringWithFormat:@"%@news",OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    if (isRefresh) {    //刷新banners
        [self getBannerData];
    }
    
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    [manager GET:strUrl
       parameters:paraMutableDic.copy
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if([responseObject[@"code"]integerValue] == 1) {
                  _systemDate = responseObject[@"time"];
                  
                  NSDictionary* resultDic = responseObject[@"result"];
                  NSArray* items = resultDic[@"items"];
                  NSArray* modelArray = [OSCInformation mj_objectArrayWithKeyValuesArray:items];
                  if (isRefresh) {//下拉得到的数据
                      [self.dataModels removeAllObjects];
                  }
                  [self.dataModels addObjectsFromArray:modelArray];
                  self.nextToken = resultDic[@"nextPageToken"];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (isRefresh) {
                          [self.tableView.mj_header endRefreshing];
                      } else {
                          if (modelArray.count < 1) {
                              [self.tableView.mj_footer endRefreshingWithNoMoreData];
                          } else {
                              [self.tableView.mj_footer endRefreshing];
                          }
                      }
                      [self.tableView reloadData];
                  });
              }
            }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
              
              [HUD hideAnimated:YES afterDelay:1];
              
              if (isRefresh) {
                  [self.tableView.mj_header endRefreshing];
              } else{
                  [self.tableView.mj_footer endRefreshing];
              }
              
              [self.tableView reloadData];
          }
     ];
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - BannerScrollViewDelegate
- (void)clickedScrollViewBanners:(NSInteger)bannerTag
{
    OSCBanner *model = _bannerModels[bannerTag];
    
    switch (model.type) {
        case InformationTypeLinkNews:{
            [self.navigationController handleURL:[NSURL URLWithString:model.href] name:nil];
            break;
        }
            
        case InformationTypeSoftWare:{
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:model.id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:detailsViewController animated:YES];
            break;
        }
            
        case InformationTypeForum:{
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = model.id;
            [self.navigationController pushViewController:detailVC animated:YES];
            
            break;
        }
            
        case InformationTypeBlog:{
            //轮播：博客详情
            NewsBlogDetailTableViewController *detailViewController = [[NewsBlogDetailTableViewController alloc] initWithObjectId:model.id isBlogDetail:YES];
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
            
            
            break;
        }
            
        case InformationTypeTranslation:{
            TranslationViewController *translationVc = [TranslationViewController new];
            translationVc.hidesBottomBarWhenPushed = YES;
            translationVc.translationId = model.id;
            [self.navigationController pushViewController:translationVc animated:YES];
            
            break;
        }
            
        case InformationTypeActivity:{
            //新活动详情页面
            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:model.id];
            activityDetailCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:activityDetailCtl animated:YES];
            
            break;
        }
        case InformationTypeInfo:{
            //新版资讯详情界面
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:model.id isBlogDetail:NO];
            newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
            
            break;
        }
        default:
            break;
    }
}

- (NSMutableArray *)bannerTitles {
	if(_bannerTitles == nil) {
		_bannerTitles = [NSMutableArray array];
	}
	return _bannerTitles;
}

- (NSMutableArray *)bannerImageUrls {
	if(_bannerImageUrls == nil) {
		_bannerImageUrls = [NSMutableArray array];
	}
	return _bannerImageUrls;
}

- (NSMutableArray *)dataModels {
	if(_dataModels == nil) {
		_dataModels = [NSMutableArray array];
	}
	return _dataModels;
}

- (NSMutableArray *)bannerModels {
	if(_bannerModels == nil) {
		_bannerModels = [NSMutableArray array];
	}
	return _bannerModels;
}
@end
