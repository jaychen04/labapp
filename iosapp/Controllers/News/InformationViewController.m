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

#import <ReactiveCocoa.h>
#import <MJExtension.h>
#import <MBProgressHUD.h>

#define OSC_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define OSC_BANNER_HEIGHT 120

static NSString * const informationReuseIdentifier = @"InformationTableViewCellReuseIdenfitier";

@interface InformationViewController () <SDCycleScrollViewDelegate,networkingJsonDataDelegate>
@property (nonatomic,strong) SDCycleScrollView* cycleScrollView;

@property (nonatomic,strong) NSMutableArray* bannerTitles;
@property (nonatomic,strong) NSMutableArray* bannerImageUrls;

@property (nonatomic,strong) id netWorkingModel;
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
        
        self.netWorkingdelegate = self;
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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self bindingRAC];
    [self layoutUI];
    
}
-(void)dealloc{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

#pragma mark - method
-(void)layoutUI{
    self.tableView.tableHeaderView = self.cycleScrollView;
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
-(void)bindingRAC{
    [self.tableView registerNib:[UINib nibWithNibName:@"InformationTableViewCell" bundle:nil] forCellReuseIdentifier:informationReuseIdentifier];
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
    
//    NSLog(@"res:%@",self.responseJsonObject);
    return cell;
}

#pragma mark -- networkingDelegate
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh{
    NSDictionary *parameters = paraDic?:@{};
    [self.manager GET:self.generateUrl()
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"res:%@",responseObject);

              
              //              _allCount = [[[responseDocument.rootElement firstChildWithTag:@"allCount"] numberValue] intValue];
              //              NSArray *objectsXML = [self parseXML:responseDocument];
              //
              //              if (refresh) {
              //                  _page = 0;
              //                  [_objects removeAllObjects];
              //                  if (_didRefreshSucceed) {_didRefreshSucceed();}
              //              }
              //
              //              if (_parseExtraInfo) {_parseExtraInfo(responseDocument);}
              //
              //              for (ONOXMLElement *objectXML in objectsXML) {
              //                  BOOL shouldBeAdded = YES;
              //                  id obj = [[_objClass alloc] initWithXML:objectXML];
              //
              //                  for (OSCBaseObject *baseObj in _objects) {
              //                      if ([obj isEqual:baseObj]) {
              //                          shouldBeAdded = NO;
              //                          break;
              //                      }
              //                  }
              //                  if (shouldBeAdded) {
              //                      [_objects addObject:obj];
              //                  }
              //              }
              //
              //              if (_needAutoRefresh) {
              //                  [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
              //              }
              //
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                if (self.tableWillReload) {self.tableWillReload(objectsXML.count);}
//                                else {
//                                    if (_page == 0 && objectsXML.count == 0) {
//                                        _lastCell.status = LastCellStatusEmpty;
//                                    } else if (objectsXML.count == 0 || (_page == 0 && objectsXML.count < 20)) {
//                                        _lastCell.status = LastCellStatusFinished;
//                                    } else {
//                                        _lastCell.status = LastCellStatusMore;
//                                    }
//                                }
              //
                    self.lastCell.status = LastCellStatusFinished;
              
                                if (self.tableView.mj_header.isRefreshing) {
                                    [self.tableView.mj_header endRefreshing];
                                }
              //
                    [self.tableView reloadData];
              //              });
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

@end
