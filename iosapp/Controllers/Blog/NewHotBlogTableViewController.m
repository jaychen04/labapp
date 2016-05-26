//
//  NewHotBlogTableViewController.m
//  iosapp
//
//  Created by Holden on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewHotBlogTableViewController.h"
#import "BlogCell.h"
#import "OSCBlog.h"
#import "Config.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "DetailsViewController.h"
#import "OSCNewHotBlog.h"
#import <MBProgressHUD.h>
#import <MJExtension.h>
static NSString *kBlogCellID = @"BlogCell";

@interface NewHotBlogTableViewController ()<networkingJsonDataDelegate>
@property (nonatomic, strong)NSMutableArray *blogObjects;
@property (nonatomic, strong)UILabel *utilLabel;
@end

@implementation NewHotBlogTableViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        __weak NewHotBlogTableViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return @"http://192.168.1.15:8000/action/apiv2/blog";
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
//        self.objClass = [OSCInformation class];
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
//        self.parametersDic = @{@"catalog":@1};
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _blogObjects = [NSMutableArray new];
    _utilLabel = [UILabel new];
    [self.tableView registerClass:[BlogCell class] forCellReuseIdentifier:kBlogCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh {
    NSDictionary *parameters = @{@"catalog":@1};
    [self.manager GET:self.generateUrl()
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"res:%@",responseObject);
                  
                  if ([[responseObject objectForKey:@"code"]integerValue] == 1) {
                      NSArray* blogModels = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:[[responseObject objectForKey:@"result"] objectForKey:@"items"]];
                      if (isRefresh) {
                          [_blogObjects removeAllObjects];
                      }
                      [_blogObjects addObjectsFromArray:blogModels];
                  }
                  //                  nextPageToken = "2_20";
                  //                  pageInfo =         {
                  //                      resultsPerPage = 1;
                  //                      totalResults = 1000;
                  //                  };
                  //                  prevPageToken = "1_20";
                  //              };
                  //     time = "2016-05-26 06:29:10:463";
                  //                  code = 1;
                  //                  message = success;
                  //                  result =     {
                  //                      items =         (
//                  {
                      //     {
                      //         author = "\U5f6d\U82cf\U4e91";
                      //         body = "\U95ee\U9898\U63cf\U8ff0\Uff1a \U5728portal6.1\U9875\U9762\U7ba1\U7406\U63a7\U5236\U53f0\U4e0a\U505a\U7528\U6237\U548c\U7ec4\U7684\U76f8\U5173\U64cd\U4f5c\U65f6\Uff08\U6dfb\U52a0\U7ec4...";
                      //         commentCount = 0;
                      //         href = "http://my.oschina.me/psuyun/blog/179520";
                      //         id = 179520;
                      //         original = 1;
                      //         pubDate = "2013-11-27 19:08:05:000";
                      //         recommend = 0;
                      //         title = "ITDS\U95ee\U9898-LDAP: error code 50 - Insufficient Access Rights";
                      //         type = 1;
                      //         viewCount = 19;
                      //     }

                                           
                                           
                  
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

                  [self.tableView reloadData];

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
#pragma mark -- DIY_headerView
- (UIView*)setUpHeaderViewWithSectionTitle:(NSString*)title iconUrl:(NSURL*)iconUrl {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xffffff];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 30, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:30];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *seriesTitle = section==0?@"最热":@"最新";
    NSURL *seriesUrl = section==0?nil:nil;
    return [self setUpHeaderViewWithSectionTitle:seriesTitle iconUrl:seriesUrl];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlogCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBlogCellID forIndexPath:indexPath];
    OSCNewHotBlog *blog = self.blogObjects[indexPath.row];
    
    cell.backgroundColor = [UIColor themeColor];
    
//    [cell.titleLabel setAttributedText:blog.attributedTittle];
//    [cell.bodyLabel setText:blog.body];
//    [cell.authorLabel setText:blog.author];
//    cell.titleLabel.textColor = [UIColor titleColor];
//    [cell.timeLabel setAttributedText:[Utils attributedTimeString:blog.pubDate]];
//    [cell.commentCount setAttributedText:blog.attributedCommentCount];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCBlog *blog = self.blogObjects[indexPath.row];
    self.utilLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.utilLabel setAttributedText:blog.attributedTittle];
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    self.utilLabel.text = blog.body;
    self.utilLabel.font = [UIFont systemFontOfSize:13];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    return height + 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCBlog *blog = self.blogObjects[indexPath.row];
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithBlog:blog];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

@end
