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
#import "NewCommentCell.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCBlogDetail.h"
#import "Utils.h"
#import "OSCBlog.h"
#import "OSCNewHotBlogDetails.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>

static NSString *followAuthorReuseIdentifier = @"FollowAuthorTableViewCell";
static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";
static NSString *webAndAbsReuseIdentifier = @"webAndAbsTableViewCell";
static NSString *newCommentReuseIdentifier = @"NewCommentCell";

@interface NewsBlogDetailTableViewController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) OSCBlogDetail *blogDetails;
@property (nonatomic, strong) NSMutableArray *blogDetailComments;
@property (nonatomic, strong) NSMutableArray *blogDetailRecommends;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property  (nonatomic,strong) OSCNewHotBlogDetails *detail;

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.commentTextField.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FollowAuthorTableViewCell" bundle:nil] forCellReuseIdentifier:followAuthorReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"webAndAbsTableViewCell" bundle:nil] forCellReuseIdentifier:webAndAbsReuseIdentifier];
    
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:newCommentReuseIdentifier];
//    [self.tableView registerNib:[UINib nibWithNibName:@"NewCommentCell" bundle:nil] forCellReuseIdentifier:newCommentReuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    
    [self getBlogData];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentTextField resignFirstResponder];
}

#pragma mark - 获取数据

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
//            if (_blogDetailComments.count > 0) {
//                return _blogDetailComments.count+1;
//            }
//            return 1;
            return 3;
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
                        return 200;
                    }
                    break;
                }
                case 3:
                    return 200;
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
//            if (_blogDetailComments.count > 0) {
//                return [tableView fd_heightForCellWithIdentifier:newCommentReuseIdentifier configuration:^(NewCommentCell *cell) {
//                    OSCBlogDetailComment *blogComment = _blogDetailComments[indexPath.row];
//                    cell.comment = blogComment;
//                }];
//            }
//            return 54;
            return 200;
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

                        abstractCell.blogDetail = _blogDetails;
                        
                        abstractCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        return abstractCell;
                    } else if (indexPath.row == 3) {
                        webAndAbsTableViewCell *websCell = [tableView dequeueReusableCellWithIdentifier:webAndAbsReuseIdentifier forIndexPath:indexPath];

                        websCell.abstractLabel.hidden = YES;
                        websCell.bodyWebView.hidden = NO;
                        websCell.bodyWebView.delegate = self;
                        websCell.blogDetail = _blogDetails;
                        [websCell.bodyWebView loadHTMLString:_blogDetails.body baseURL:[NSBundle mainBundle].resourceURL];
                        
                        websCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        return websCell;
                    }
                } else {
                    if (indexPath.row == 2) {
                        webAndAbsTableViewCell *websCell = [tableView dequeueReusableCellWithIdentifier:webAndAbsReuseIdentifier forIndexPath:indexPath];

                        websCell.abstractLabel.hidden = YES;
                        websCell.bodyWebView.hidden = NO;
                        websCell.bodyWebView.delegate = self;
                        websCell.blogDetail = _blogDetails;
                        [websCell.bodyWebView loadHTMLString:_blogDetails.body baseURL:[NSBundle mainBundle].resourceURL];
                        
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
//            if (_blogDetailComments.count == 0) {
//                UITableViewCell *cell = [UITableViewCell new];
//                cell.textLabel.text = @"还没有评论";
//                cell.textLabel.textAlignment = NSTextAlignmentCenter;
//                cell.textLabel.font = [UIFont systemFontOfSize:14];
//                cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                
//                return cell;
//            }
            NewCommentCell *commentBlogCell = [tableView dequeueReusableCellWithIdentifier:newCommentReuseIdentifier forIndexPath:indexPath];
            
//            if (_blogDetailComments.count > 0) {
//                OSCBlogDetailComment *detailComment = _blogDetailComments[indexPath.row];
//                commentBlogCell.comment = detailComment;
//                commentBlogCell.selectionStyle = UITableViewCellSelectionStyleDefault;
//                [commentBlogCell.commentButton addTarget:self action:@selector(selectedToComment) forControlEvents:UIControlEventTouchUpInside];
//                
//                if (indexPath.row == _blogDetailComments.count) {
//                    UITableViewCell *cell = [UITableViewCell new];
//                    cell.textLabel.text = @"更多评论";
//                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
//                    cell.textLabel.font = [UIFont systemFontOfSize:14];
//                    cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
//                    
//                    return cell;
//                }
//                
//                return commentBlogCell;
//            }
            return commentBlogCell;
            
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
    NSLog(@"fav");
}

#pragma mark - 评论
- (void)selectedToComment
{
    _commentTextField.placeholder = @"commentAuthor";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    _bottmTextFiled.constant = 0;
    
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
    _bottmTextFiled.constant = _keyboardHeight;
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _bottmTextFiled.constant = 0;
}

#pragma mark - collect
- (IBAction)collected:(UIButton *)sender {
    NSLog(@"collect");
}


#pragma mark - share
- (IBAction)share:(UIButton *)sender {
    NSLog(@"share");
}



@end
