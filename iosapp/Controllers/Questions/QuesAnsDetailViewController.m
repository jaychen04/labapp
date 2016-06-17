//
//  QuesAnsDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsDetailViewController.h"
#import "QuesAnsDetailHeadCell.h"
#import "NewCommentCell.h"
#import "OSCQuestion.h"
#import "OSCBlogDetail.h"
#import "CommentDetailViewController.h"

#import "Utils.h"
#import "OSCAPI.h"

#import <MJExtension.h>

static NSString *quesAnsDetailHeadReuseIdentifier = @"QuesAnsDetailHeadCell";
@interface QuesAnsDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic, strong) OSCQuestion *questionDetail;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) CGFloat webViewHeight;

@property (nonatomic, copy) NSString *nextPageToken;

@end

@implementation QuesAnsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _comments = [NSMutableArray new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsDetailHeadCell" bundle:nil] forCellReuseIdentifier:quesAnsDetailHeadReuseIdentifier];
    
//    [self getDetailForQuestion];
//    [self getCommentsForQuestion:NO];/* 待调试 */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)getDetailForQuestion
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@question?id=%ld", OSCAPI_V2_PREFIX, (long)self.questionID];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _questionDetail = [OSCQuestion mj_objectWithKeyValues:responseObject[@"result"]];
                NSDictionary *data = @{@"content":  _questionDetail.body};
                _questionDetail.body = [Utils HTMLWithData:data
                                          usingTemplate:@"newTweet"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

#pragma mark - 获取评论数组
- (void)getCommentsForQuestion:(BOOL)isRefresh
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@comment", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:@{
                  @"sourceId"  : @(self.questionID),
                  @"type"      : @(2),
                  @"parts"     : @"refer,replay",
                  @"pageToken" : _nextPageToken,
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                //
                NSDictionary* result = responseObject[@"result"];
                NSArray* JsonItems = result[@"items"];
                NSArray *models = [OSCQuestion mj_objectArrayWithKeyValuesArray:JsonItems];
                _nextPageToken = result[@"nextPageToken"];
                if (isRefresh) {
                    [_comments removeAllObjects];
                }
                [_comments addObjectsFromArray:models];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        QuesAnsDetailHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:quesAnsDetailHeadReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        cell.questioinDetail = _questionDetail;
//        cell.contentWebView.delegate = self;
//        [cell.contentWebView loadHTMLString:_questionDetail.body baseURL:[NSBundle mainBundle].resourceURL];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        NewCommentCell *commentBlogCell = [NewCommentCell new];
        
        commentBlogCell.isQuestion = YES;
        
        return commentBlogCell;
    }
    
    return [UITableViewCell new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        if (_questionDetail.commentCount > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"回答(%lu)", (unsigned long)_questionDetail.commentCount]];
        }
        return [self headerViewWithSectionTitle:@"回答"];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:22];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        label.text = _questionDetail.title;
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 32, MAXFLOAT)].height;
        
        height += _webViewHeight;
        
        return 80 + height;
    } else if (indexPath.section == 1) {
        return 100;
    }
    return 0;
}
                
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerViewHeight = 0.001;
    switch (section) {
        case 0:
            break;
        case 1:
            headerViewHeight = 32;
            break;
        default:
            break;
    }
    return headerViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        CommentDetailViewController *commentDetailVC = [CommentDetailViewController new];
        [self.navigationController pushViewController:commentDetailVC animated:YES];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webViewHeight == webViewHeight) {return;}
    _webViewHeight = webViewHeight;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
    
    return headerView;
}

@end
