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
#import "webAndAbsTableViewCell.h"
#import "RecommandBlogTableViewCell.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCBlogDetail.h"
#import "Utils.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>

static NSString *followAuthorReuseIdentifier = @"FollowAuthorTableViewCell";
static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";
static NSString *webAndAbsReuseIdentifier = @"webAndAbsTableViewCell";

@interface NewsBlogDetailTableViewController () <UIWebViewDelegate>

@property (nonatomic, strong) OSCBlogDetail *blogDetails;
@property (nonatomic, strong) NSMutableArray *blogDetailComments;
@property (nonatomic, strong) NSMutableArray *blogDetailRecommends;

@end

@implementation NewsBlogDetailTableViewController

-(instancetype) initWithBlogId:(NSInteger)blogId
                  isBlogDetail:(BOOL)isBlogDetail {
    if(self) {
        self.blogId = blogId;
        self.isBlogDetail = isBlogDetail;
        
        _blogDetailRecommends = [NSMutableArray new];
        _blogDetailComments = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"FollowAuthorTableViewCell" bundle:nil] forCellReuseIdentifier:followAuthorReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"webAndAbsTableViewCell" bundle:nil] forCellReuseIdentifier:webAndAbsReuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    
    [self getBlogData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)getBlogData{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@/blog?id=%lld", OSCAPI_V2_PREFIX, self.blogId];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

            if ([responseObject[@"code"]integerValue] == 1) {
                _blogDetails = [OSCBlogDetail mj_objectWithKeyValues:responseObject[@"result"]];
                _blogDetailRecommends = [OSCBlogDetailRecommend mj_objectArrayWithKeyValuesArray:_blogDetails.abouts];
                _blogDetailComments = [OSCBlogDetailComment mj_objectArrayWithKeyValuesArray:_blogDetails.comments];
                
                _blogDetails.body = [Utils HTMLWithData:@{
                                              @"content" : _blogDetails.body,
//                                              @"night"   : @([Config getMode]),
                                              }
                              usingTemplate:@"activity"];
                
                NSLog(@"blogDetail = %@", _blogDetails);
                
            }
            [self.tableView reloadData];
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    topLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:topLineView];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    bottomLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:bottomLineView];
    
    return headerView;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            if (_blogDetails.abstract.length > 0) {
                return 4;
            } else {
                return 3;
            }
            break;
        }
        case 1://相关文章
        {
            if (_blogDetailRecommends.count > 0) {
                return _blogDetailRecommends.count;
            }
            return 0;
            break;
        }
        case 2://讨论
        {
            return 2;
            break;
        }
        default:
            break;
    }
    return 0;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return [self headerViewWithSectionTitle:@"相关文章"];
    }else if (section == 2) {
        if (_blogDetailComments.count > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_blogDetailComments.count]];
        }
        return [self headerViewWithSectionTitle:@"评论"];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    return [tableView fd_heightForCellWithIdentifier:followAuthorReuseIdentifier configuration:^(FollowAuthorTableViewCell *cell) {
                        cell.blogDetail = _blogDetails;
                    }];
                    break;
                case 1:
                    return [tableView fd_heightForCellWithIdentifier:titleInfoReuseIdentifier configuration:^(TitleInfoTableViewCell *cell) {
                        cell.blogDetail = _blogDetails;
                    }];
                    break;
                case 2:
                {
                    if (_blogDetails.abstract.length > 0) {
                        return [tableView fd_heightForCellWithIdentifier:webAndAbsReuseIdentifier configuration:^(webAndAbsTableViewCell *cell) {
                            cell.blogDetail = _blogDetails;
                        }];
                    } else if (_blogDetails.abstract.length == 0) {
                        return [tableView fd_heightForCellWithIdentifier:webAndAbsReuseIdentifier configuration:^(webAndAbsTableViewCell *cell) {
                            cell.blogDetail = _blogDetails;
                        }];
                    }
                    break;
                }
                case 3:
                    return [tableView fd_heightForCellWithIdentifier:webAndAbsReuseIdentifier configuration:^(webAndAbsTableViewCell *cell) {
                        cell.blogDetail = _blogDetails;
                    }];
                    break;
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            if (_blogDetailRecommends.count > 0) {
                return [tableView fd_heightForCellWithIdentifier:recommandBlogReuseIdentifier configuration:^(RecommandBlogTableViewCell *cell) {
                    OSCBlogDetailRecommend *blogRecommend = _blogDetailRecommends[indexPath.row];
                    cell.abouts = blogRecommend;
                }];
            }
            return 54;
            break;
        }
        case 2:
        {
            return 50;
            break;
        }
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            
            break;
        case 1:
            return 32;
            break;
        case 2:
            return 32;
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
                followAuthorCell.blogDetail = _blogDetails;
                
                followAuthorCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [followAuthorCell.followBtn addTarget:self action:@selector(favSelected) forControlEvents:UIControlEventTouchUpInside];
                
                return followAuthorCell;
            }else if (indexPath.row==1) {
                TitleInfoTableViewCell *titleInfoCell = [tableView dequeueReusableCellWithIdentifier:titleInfoReuseIdentifier forIndexPath:indexPath];
                titleInfoCell.blogDetail = _blogDetails;
                
                titleInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return titleInfoCell;
            } else{
                if (_blogDetails.abstract.length > 0) {
                    if (indexPath.row == 2) {
                        webAndAbsTableViewCell *abstractCell = [tableView dequeueReusableCellWithIdentifier:webAndAbsReuseIdentifier forIndexPath:indexPath];
                        
                        abstractCell.cellType = @"abstractType";
                        abstractCell.blogDetail = _blogDetails;
                        
                        abstractCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        return abstractCell;
                    } else if (indexPath.row == 3) {
                        webAndAbsTableViewCell *websCell = [tableView dequeueReusableCellWithIdentifier:webAndAbsReuseIdentifier forIndexPath:indexPath];
                        
                        websCell.cellType = @"bodyType";
                        websCell.bodyWebView.delegate = self;
                        websCell.blogDetail = _blogDetails;
                        
                        websCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        return websCell;
                    }
                } else {
                    if (indexPath.row == 2) {
                        webAndAbsTableViewCell *websCell = [tableView dequeueReusableCellWithIdentifier:webAndAbsReuseIdentifier forIndexPath:indexPath];

                        websCell.cellType = @"bodyType";
                        websCell.bodyWebView.delegate = self;
                        websCell.blogDetail = _blogDetails;
                        
                        websCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        return websCell;
                    }
                }
            }
        }
            break;
        case 1:
        {
            RecommandBlogTableViewCell *recommandBlogCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
            
            if (_blogDetailRecommends.count > 0) {
                OSCBlogDetailRecommend *about = _blogDetailRecommends[indexPath.row];
                recommandBlogCell.abouts = about;
            }
            
            recommandBlogCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - fav
- (void)favSelected
{
    
}

@end
