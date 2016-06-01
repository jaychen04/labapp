//
//  NewsBlogDetailTableViewController.m
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewsBlogDetailTableViewController.h"
#import "FollowAuthorTableViewCell.h"
#import "TitleInfoTableViewCell.h"
#import "RecommandBlogTableViewCell.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCBlog.h"
#import "OSCNewHotBlogDetails.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>

static NSString *followAuthorReuseIdentifier = @"FollowAuthorTableViewCell";
static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";

@interface NewsBlogDetailTableViewController ()

@property  (nonatomic,strong) OSCNewHotBlogDetails *detail;

@end




@implementation NewsBlogDetailTableViewController

-(instancetype) initWithBlogId:(NSInteger)blogId
                  isBlogDetail:(BOOL)isBlogDetail {
    if(self) {
        self.blogId = blogId;
        self.isBlogDetail = isBlogDetail;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"FollowAuthorTableViewCell" bundle:nil] forCellReuseIdentifier:followAuthorReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];    
    self.tableView.tableFooterView = [UIView new];
    
    [self getBlogData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)getBlogData{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@blog?id=%lld", OSCAPI_V2_PREFIX,self.blogId];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:blogDetailUrlStr parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //TODO
        NSLog(@"result object is %@",responseObject);
        self.detail = [[OSCNewHotBlogDetails alloc] init];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        //TODO

    }];
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
            RecommandBlogTableViewCell *recommandBlogCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
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
