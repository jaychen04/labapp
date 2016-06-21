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
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "LoginViewController.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <TOWebViewController.h>
#import "UMSocial.h"
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

static NSString *quesAnsDetailHeadReuseIdentifier = @"QuesAnsDetailHeadCell";
@interface QuesAnsDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic, strong) OSCQuestion *questionDetail;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) CGFloat webViewHeight;

@property (nonatomic, copy) NSString *nextPageToken;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation QuesAnsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _comments = [NSMutableArray new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsDetailHeadCell" bundle:nil] forCellReuseIdentifier:quesAnsDetailHeadReuseIdentifier];
    
    self.commentTextField.delegate = self;
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarButtonClicked)];
    [self getDetailForQuestion];
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
                [self setFavButtonImage:_questionDetail.favorite];
                
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
//                  @"parts"     : @"refer,replay",
                  @"pageToken" : _nextPageToken,
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                //
                NSDictionary* result = responseObject[@"result"];
                NSArray* JsonItems = result[@"items"];
                NSArray *models = [OSCBlogDetailComment mj_objectArrayWithKeyValuesArray:JsonItems];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - 右导航栏按钮
- (void)rightBarButtonClicked
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"举报"
                                                        message:[NSString stringWithFormat:@"链接地址：%@", _questionDetail.href]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].placeholder = @"举报原因";
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode)
    {
        [alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
    }
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:@"http://www.oschina.net/action/communityManage/report"
           parameters:@{
                        @"memo":        [alertView textFieldAtIndex:0].text.length == 0? @"其他原因": [alertView textFieldAtIndex:0].text,
                        @"obj_id":      @(self.questionID),
                        @"obj_type":    @"2",
                        @"reason":      @"4",
                        @"url":         _questionDetail.href
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.labelText = @"举报成功";
                  
                  [HUD hide:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = @"网络异常，操作失败";
                  
                  [HUD hide:YES afterDelay:1];
              }];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"send mesage");
    
    
    /* 
     发评论
     */
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
    _bottomLayoutConstraint.constant = _keyboardHeight;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _bottomLayoutConstraint.constant = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentTextField resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

#pragma mark - 按钮功能
- (IBAction)buttonClick:(UIButton *)sender {
    //先判断是否登录
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        if (sender.tag == 1) {
            [self favOrNoFavType];
        }
    }
    if (sender.tag == 2) {
        [self shareForOthers];
    }
}

- (void)favOrNoFavType
{
    //收藏
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@favorite_reverse", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:@{
                  @"id"  : @(self.questionID),
                  @"type"      : @(2),
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue]== 1) {
                _questionDetail.favorite = [responseObject[@"result"][@"favorite"] boolValue];
            }
            
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = _questionDetail.favorite? @"收藏成功": @"取消收藏";
            
            [HUD hide:YES afterDelay:1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setFavButtonImage:_questionDetail.favorite];

                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

- (void)setFavButtonImage:(BOOL)isFav
{
    if (isFav) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    } else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

- (void)shareForOthers
{
    //分享
    [_commentTextField resignFirstResponder];
    
    NSString *trimmedHTML = [_questionDetail.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    NSString *digest = [trimmedHTML substringToIndex:length];
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = _questionDetail.href;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _questionDetail.href;
    [UMSocialData defaultData].extConfig.title = _questionDetail.title;
    
    // 手机QQ相关设置
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = _questionDetail.title;
    //[UMSocialData defaultData].extConfig.qqData.shareText = weakSelf.objectTitle;
    [UMSocialData defaultData].extConfig.qqData.url = _questionDetail.href;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:_questionDetail.href];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"54c9a412fd98c5779c000752"
                                      shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, _questionDetail.href]
                                     shareImage:[UIImage imageNamed:@"logo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}

@end
