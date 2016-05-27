//
//  NewHotBlogTableViewController.m
//  iosapp
//
//  Created by Holden on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewHotBlogTableViewController.h"
#import "NewHotBlogTableViewCell.h"
#import "OSCBlog.h"
#import "Config.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "DetailsViewController.h"
#import "OSCNewHotBlog.h"
#import <MBProgressHUD.h>
#import <MJExtension.h>
static NSString *reuseIdentifier = @"NewHotBlogTableViewCell";

@interface NewHotBlogTableViewController ()<networkingJsonDataDelegate>

@property (nonatomic, strong) NSMutableArray *newsBlogObjects;
@property (nonatomic, strong) NSMutableArray *hotBlogObjects;

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
        self.parametersDic = @{@"catalog":@1};
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _newsBlogObjects = [NSMutableArray new];
    _hotBlogObjects = [NSMutableArray new];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NewHotBlogTableViewCell class])
                                               bundle:[NSBundle mainBundle]]
     
        forCellReuseIdentifier:reuseIdentifier];
    
    [self getJSONDataWithNewBlog:@{@"catalog":@2} isRefresh:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - 获取最热博客
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh {
    NSDictionary *parameters = @{@"catalog":@1};
    
    [self.manager GET:self.generateUrl()
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"res:%@",responseObject);
                  
                  if ([[responseObject objectForKey:@"code"]integerValue] == 1) {
                      NSArray* blogModels = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:[[responseObject objectForKey:@"result"] objectForKey:@"items"]];
                      if (isRefresh) {
                          [_hotBlogObjects removeAllObjects];
                      }
                      [_hotBlogObjects addObjectsFromArray:blogModels];
                  }
                  
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

#pragma mark - 获取最新博客
- (void)getJSONDataWithNewBlog:(NSDictionary *)paraDic isRefresh:(BOOL)isRefresh
{
    [self.manager GET:self.generateUrl()
           parameters:paraDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"res:%@",responseObject);
                  
                  if ([[responseObject objectForKey:@"code"]integerValue] == 1) {
                      NSArray* blogModels = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:[[responseObject objectForKey:@"result"] objectForKey:@"items"]];
                      if (isRefresh) {
                          [_newsBlogObjects removeAllObjects];
                      }
                      [_newsBlogObjects addObjectsFromArray:blogModels];
                  }
                  
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    lineView.backgroundColor = [UIColor colorWithHex:0xd2d2d2];
    [headerView addSubview:lineView];
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = section == 0 ? self.hotBlogObjects : self.newsBlogObjects;

    return array.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *seriesTitle = section==0?@"最热":@"最新";
    NSURL *seriesUrl = section==0?nil:nil;
    return [self setUpHeaderViewWithSectionTitle:seriesTitle iconUrl:seriesUrl];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewHotBlogTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor themeColor];
    cell.titleLabel.textColor = [UIColor titleColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    NSMutableArray *array = indexPath.section == 0 ? self.hotBlogObjects : self.newsBlogObjects;
    
    if (array.count > 0) {
        OSCNewHotBlog *blog = array[indexPath.row];
        
        [cell setNewHotBlogContent:blog];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = indexPath.section == 0 ? self.hotBlogObjects : self.newsBlogObjects;
     UILabel *label = [UILabel new];
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (array.count > 0) {
        OSCNewHotBlog *blog = array[indexPath.row];
        
        label.font = [UIFont boldSystemFontOfSize:15];
        [label setAttributedText:blog.attributedTitleString];
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 32, MAXFLOAT)].height;
        
        label.text = blog.body;
        label.font = [UIFont systemFontOfSize:13];
        height += [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 32, MAXFLOAT)].height;
        
        return height + 51;
    }
    return 87;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *array = indexPath.section == 0 ? self.hotBlogObjects : self.newsBlogObjects;
    OSCNewHotBlog *blog;
    
    if (array.count > 0) {
        blog = array[indexPath.row];
    }
    
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithNewHotBlog:blog];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

@end
