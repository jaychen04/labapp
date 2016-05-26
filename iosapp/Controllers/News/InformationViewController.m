//
//  InformationViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/5/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "InformationViewController.h"
#import "SDCycleScrollView.h"
#import "OSCInformation.h"
#import "InformationTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import <ReactiveCocoa.h>
#import <MJExtension.h>

#define OSC_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define OSC_BANNER_HEIGHT 120

static NSString * const informationReuseIdentifier = @"InformationTableViewCell";

@interface InformationViewController () <SDCycleScrollViewDelegate>
@property (nonatomic,strong) SDCycleScrollView* cycleScrollView;

@property (nonatomic,strong) NSMutableArray* bannerTitles;
@property (nonatomic,strong) NSMutableArray* bannerImageUrls;

@property (nonatomic,strong) id netWorkingModel;
@property (nonatomic,strong) NSMutableArray* dataModels;
@end

@implementation InformationViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        __weak InformationViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return @"http://192.168.1.72:1104/action/apiv2/news";
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        self.objClass = [OSCInformation class];
        
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
    
    NSLog(@"%@",self.responseJsonObject);
    
    [self handleData];
    [self bindingRAC];
    [self layoutUI];
    
}



#pragma mark - method

-(void)handleData{
    if (self.responseJsonObject) {
        NSDictionary* result = self.responseJsonObject[@"result"];
        NSArray* items = result[@"items"];
        NSArray* modelArray = [OSCInformation mj_objectArrayWithKeyValuesArray:items];
    }
    
}

-(void)layoutUI{
    [self.tableView registerNib:[UINib nibWithNibName:@"InformationTableViewCell" bundle:nil] forCellReuseIdentifier:informationReuseIdentifier];
    
    self.tableView.tableHeaderView = self.cycleScrollView;
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)bindingRAC{
#warning TODO : netWorkingModel是解析好的model
//    RAC(self,bannerImageUrls) = RACObserve(self.netWorkingModel, imageUrls);
//    RAC(self,bannerTitles) = RACObserve(self.netWorkingModel, titles);
}
-(void)configurationCycleScrollView{
    self.cycleScrollView.imageURLStringsGroup = self.bannerImageUrls.copy;
    self.cycleScrollView.titlesGroup = self.bannerTitles.copy;
}


#pragma mark - tableView datasource && delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}
-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationTableViewCell* cell = [InformationTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:informationReuseIdentifier];
    
    return cell;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return [tableView fd_heightForCellWithIdentifier:informationReuseIdentifier configuration:^(id cell) {
//        //做和 cellForRowAtIndexPath: 一样的事
//    }];
//}



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
#pragma message "TODO: setting placeholderImage Name"
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:(CGRect){{0,0},{OSC_SCREEN_WIDTH,OSC_BANNER_HEIGHT}} delegate:self placeholderImage:[UIImage imageNamed:@""]];
        _cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleNone;
        
	}
	return _cycleScrollView;
}

- (NSMutableArray *)bannerTitles {
	if(_bannerTitles == nil) {
		_bannerTitles = @[].mutableCopy;
	}
	return _bannerTitles;
}

- (NSMutableArray *)bannerImageUrls {
	if(_bannerImageUrls == nil) {
		_bannerImageUrls = @[].mutableCopy;
	}
	return _bannerImageUrls;
}

- (NSMutableArray *)dataModels {
	if(_dataModels == nil) {
		_dataModels = [NSMutableArray array];
	}
	return _dataModels;
}

@end
