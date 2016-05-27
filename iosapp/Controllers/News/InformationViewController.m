//
//  InformationViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/5/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "InformationViewController.h"
#import "TokenManager.h"
#import "SDCycleScrollView.h"
#import "InformationTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import "OSCInformation.h"
#import "OSCBanner.h"

#import <ReactiveCocoa.h>
#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>

#define OSC_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define OSC_BANNER_HEIGHT 120

static NSString * const informationReuseIdentifier = @"InformationTableViewCell";

@interface InformationViewController () <SDCycleScrollViewDelegate,networkingJsonDataDelegate>
@property (nonatomic,strong) SDCycleScrollView* cycleScrollView;

@property (nonatomic,strong) NSMutableArray* bannerTitles;
@property (nonatomic,strong) NSMutableArray* bannerImageUrls;

@property (nonatomic,strong) NSMutableArray* bannerModels;
@property (nonatomic,strong) NSMutableArray* dataModels;

@property (nonatomic,strong) NSString* nextToken;
@end

@implementation InformationViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        __weak InformationViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return @"http://192.168.1.15:8000/action/apiv2/news";
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        self.objClass = [OSCInformation class];
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        self.parametersDic = @{};
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getBannerData];
    [self layoutUI];
}


#pragma mark - method
#pragma mark --- 维护用作tableView数据源的数组
-(void)handleData:(id)responseJSON isRefresh:(BOOL)isRefresh{
    if (responseJSON) {
        NSDictionary* result = responseJSON[@"result"];
        NSArray* items = result[@"items"];
        NSArray* modelArray = [OSCInformation mj_objectArrayWithKeyValuesArray:items];
//        NSLog(@"%@",modelArray);
        if (isRefresh) {//上拉得到的数据
            [self.dataModels removeAllObjects];
        }
        [self.dataModels addObjectsFromArray:modelArray];
    }
}

-(void)getBannerData{
    NSString* urlStr = @"http://192.168.1.15:8000/action/apiv2/banner";
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager manager];
    [manger GET:urlStr
     parameters:@{@"catalog" : @1}
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSDictionary* resultDic = responseObject[@"result"];
            NSArray* responseArr = resultDic[@"items"];
            NSArray* bannerModels = [OSCBanner mj_objectArrayWithKeyValuesArray:responseArr];
            self.bannerModels = bannerModels.mutableCopy;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configurationCycleScrollView];
            });
}
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
}];
}
-(void)layoutUI{
    [self.tableView registerNib:[UINib nibWithNibName:@"InformationTableViewCell" bundle:nil] forCellReuseIdentifier:informationReuseIdentifier];
    
    self.tableView.tableHeaderView = self.cycleScrollView;
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)configurationCycleScrollView{
    for (OSCBanner* bannerItem in self.bannerModels) {
//        NSLog(@"%@",bannerItem);
        [self.bannerTitles addObject:bannerItem.name];
        [self.bannerImageUrls addObject:bannerItem.img];
    }
    
    self.cycleScrollView.imageURLStringsGroup = self.bannerImageUrls.copy;
    self.cycleScrollView.titlesGroup = self.bannerTitles.copy;
    
//    NSLog(@"banner Imgs %@",self.cycleScrollView.imageURLStringsGroup);
//    NSLog(@"banner titles %@",self.cycleScrollView.titlesGroup);
    
    [self.tableView reloadData];
}


#pragma mark - tableView datasource && delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataModels.count;
}
-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationTableViewCell* cell = [InformationTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:informationReuseIdentifier];
    cell.viewModel = self.dataModels[indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:informationReuseIdentifier configuration:^(InformationTableViewCell* cell) {
        cell.viewModel = self.dataModels[indexPath.row];
    }];
}

#pragma mark -- networking Delegate
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh{//yes 下拉 no 上拉
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
//        NSLog(@"%@",paraMutableDic);
    }
    [self.manager GET:self.generateUrl()
       parameters:paraMutableDic.copy
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              NSLog(@"res:%@",responseObject);
              [self handleData:responseObject isRefresh:isRefresh];
              NSDictionary* resultDic = responseObject[@"result"];
              NSArray* items = resultDic[@"items"];
              self.nextToken = resultDic[@"nextPageToken"];
//              NSLog(@"%@",self.nextToken);
              dispatch_async(dispatch_get_main_queue(), ^{
                  self.lastCell.status = items.count < 20 ? LastCellStatusFinished : LastCellStatusMore;
                  
                  if (self.tableView.mj_header.isRefreshing) {
                      [self.tableView.mj_header endRefreshing];
                  }
                  [self.tableView reloadData];
              });
            }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabelText = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
              
              [HUD hide:YES afterDelay:1];
              
              self.lastCell.status = LastCellStatusError;
              if (self.tableView.mj_header.isRefreshing) {
                  [self.tableView.mj_header endRefreshing];
              }
              [self.tableView reloadData];
          }
     ];
}

#pragma mark - banner delegate 
/** 点击banner触发 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{

}
/** 滚动banner触发 */
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{

}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.cycleScrollView clearCache];
}




#pragma mark - lazy loading

- (SDCycleScrollView *)cycleScrollView {
	if(_cycleScrollView == nil) {
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:(CGRect){{0,0},{OSC_SCREEN_WIDTH,OSC_BANNER_HEIGHT}} delegate:self placeholderImage:[UIImage imageNamed:@""]];
        _cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleNone;
        
	}
	return _cycleScrollView;
}

- (NSMutableArray *)bannerTitles {
	if(_bannerTitles == nil) {
		_bannerTitles = [NSMutableArray arrayWithCapacity:5];
	}
	return _bannerTitles;
}

- (NSMutableArray *)bannerImageUrls {
	if(_bannerImageUrls == nil) {
		_bannerImageUrls = [NSMutableArray arrayWithCapacity:5];
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
		_bannerModels = [NSMutableArray arrayWithCapacity:5];
	}
	return _bannerModels;
}
@end
