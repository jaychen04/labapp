//
//  NewsBlogDetailTableViewController.m
//  iosapp
//
//  Created by Holden on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewsBlogDetailTableViewController.h"
#import "FollowAuthorTableViewCell.h"
#import "TitleInfoTableViewCell.h"
#import "recommandBlogTableViewCell.h"
#import "OSCNewHotBlogDetails.h"
#import "UIColor+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"

static NSString *followAuthorReuseIdentifier = @"FollowAuthorTableViewCell";
static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"recommandBlogTableViewCell";

@interface NewsBlogDetailTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation NewsBlogDetailTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FollowAuthorTableViewCell" bundle:nil] forCellReuseIdentifier:followAuthorReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"recommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    
    [self getBlogDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 获取博客详情
-(void)getBlogDetails {
    //    NSLog(@"hotPara:%@",@{@"catalog":@1});
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:@"http://192.168.1.15:8000/action/apiv2/blog"
           parameters:@{@"id":@(_blogId)}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSLog(@"hotres:%ld",[[responseObject[@"result"] objectForKey:@"items"] count]);
//                  if ([responseObject[@"code"]integerValue] == 1) {
//                      NSArray* blogModels = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:[responseObject[@"result"] objectForKey:@"items"]];
//                      if (isRefresh) {
//                          [_hottestBlogObjects removeAllObjects];
//                      }
//                      [_hottestBlogObjects addObjectsFromArray:blogModels];
//                  }
//                  [self.tableView reloadData];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
              }
     ];
}

#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor newCellColor];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    lineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:lineView];
    
    return headerView;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return [self headerViewWithSectionTitle:@"相关推荐"];
    }else if (section == 2) {
        return [self headerViewWithSectionTitle:@"评论"];
    }
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            
            break;
        case 1:
            return 50;
            break;
        case 2:
            return 35;
            break;
        default:
            break;
    }
    
    return 0.001;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row==0) {
                FollowAuthorTableViewCell *followAuthorCell = [tableView dequeueReusableCellWithIdentifier:followAuthorReuseIdentifier forIndexPath:indexPath];
                return followAuthorCell;
            }else if (indexPath.row==1) {
                TitleInfoTableViewCell *titleInfoCell = [tableView dequeueReusableCellWithIdentifier:titleInfoReuseIdentifier forIndexPath:indexPath];
                return titleInfoCell;
            }else if (indexPath.row==2) {
                
            }
        }
            break;
        case 1:
        {
            recommandBlogTableViewCell *recommandBlogCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
            return recommandBlogCell;
        }
            break;
        case 2:
        {
        }
            break;
        default:
            break;
    }
    return [UITableViewCell new];
}


@end
