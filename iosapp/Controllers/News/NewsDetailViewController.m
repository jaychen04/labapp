//
//  NewsDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/7/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "OSCInformationDetails.h"
#import "NewCommentListViewController.h"//新评论列表
#import "SoftWareViewController.h"      //软件详情
#import "NewCommentCell.h"

#import "Utils.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <TOWebViewController.h>
#import "UMSocial.h"

static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";
static NSString *contentWebReuseIdentifier = @"contentWebTableViewCell";
static NSString *newCommentReuseIdentifier = @"NewCommentCell";
static NSString *relatedSoftWareReuseIdentifier = @"RelatedSoftWareCell";

#define Large_Frame  (CGRect){{0,0},{40,25}}
#define Medium_Frame (CGRect){{0,0},{30,25}}
#define Small_Frame  (CGRect){{0,0},{25,25}}

@interface NewsDetailViewController ()<UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic)int64_t newsId;
@property (nonatomic, strong) OSCInformationDetails *newsDetails;
@property (nonatomic, strong) NSMutableArray *newsDetailRecommends;
@property (nonatomic, strong) NSMutableArray *newsDetailComments;
@property (nonatomic) BOOL isExistRelatedSoftware;      //存在相关软件的信息

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIButton *rightBarBtn;
@property (nonatomic,assign) BOOL isReboundTop;
@property (nonatomic,assign) CGPoint readingOffest;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation NewsDetailViewController

- (instancetype)initWithNewsId:(NSInteger)newsId {
    if(self) {
        self.newsId = newsId;
        _newsDetailRecommends = [NSMutableArray new];
        _newsDetailComments = [NSMutableArray new];
    }
    return self;
}
- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:self.view.bounds];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    _hud = [[MBProgressHUD alloc] initWithWindow:window];
    _hud.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
    [window addSubview:_hud];
    [self.view addSubview:coverView];
    [_hud show:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}
- (void)hideHubView {
    [_hud hide:YES];
    [[self.view viewWithTag:10] removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"资讯";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTextField.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContentWebViewCell" bundle:nil] forCellReuseIdentifier:contentWebReuseIdentifier];
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:newCommentReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RelatedSoftWareCell" bundle:nil] forCellReuseIdentifier:relatedSoftWareReuseIdentifier];
    self.tableView.estimatedRowHeight = 250;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor separatorColor];
    
    
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarBtn.userInteractionEnabled = YES;
    //    _rightBarBtn.frame  = CGRectMake(0, 0, 27, 20);
    _rightBarBtn.hidden = YES;
    _rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_rightBarBtn addTarget:self action:@selector(rightBarButtonScrollToNewsCommitSection) forControlEvents:UIControlEventTouchUpInside];
    [_rightBarBtn setTitle:@"" forState:UIControlStateNormal];
    _rightBarBtn.titleEdgeInsets = UIEdgeInsetsMake(-4, 0, 0, 0);
    [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
    //    _rightBarBtn.hidden = NO;
    
    // 添加等待动画
    [self showHubView];
    //获取资讯详情和资讯评论
    [self getNewsData];
    [self getNewsComments];


    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - 获取资讯详情
-(void)getNewsData{
    //    74510
    NSString *newsDetailUrlStr = [NSString stringWithFormat:@"%@news?id=%lld", OSCAPI_V2_PREFIX, self.newsId];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:newsDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                _newsDetails = [OSCInformationDetails mj_objectWithKeyValues:responseObject[@"result"]];
                _newsDetailRecommends= [OSCBlogDetailRecommend mj_objectArrayWithKeyValuesArray:_newsDetails.abouts];
                NSDictionary *data = @{@"content":  _newsDetails.body?:@""};
                _newsDetails.body = [Utils HTMLWithData:data
                                          usingTemplate:@"blog"];
                
                _isExistRelatedSoftware = _newsDetails.software.allKeys.count > 0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNewsFavButtonWithIsCollected:_newsDetails.favorite];
                [self updateNewsRightButton:_newsDetails.commentCount];
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

#pragma mark - 获取资讯详情评论
-(void)getNewsComments{
    NSString *newsDetailUrlStr = [NSString stringWithFormat:@"%@comment", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:newsDetailUrlStr
     parameters:@{@"pageToken":@"",
                  @"sourceId":@(self.newsId),
                  @"type":@(6),
                  @"parts":@"refer,reply",
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                _newsDetailComments = [OSCNewComment mj_objectArrayWithKeyValuesArray:responseObject[@"result"][@"items"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}
#pragma mark - collect 收藏

- (void)updateNewsFavButtonWithIsCollected:(BOOL)isCollected
{
    if (isCollected) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    }else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}
#pragma mark --- update RightButton
-(void)updateNewsRightButton:(NSInteger)commentCount{
    _rightBarBtn.hidden = NO;
    if (commentCount >= 999) {
        _rightBarBtn.frame = Large_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_4_appbar"] forState:UIControlStateNormal];
        [_rightBarBtn setTitle:@"999+" forState:UIControlStateNormal];
    }else if (commentCount >= 100){
        _rightBarBtn.frame = Medium_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_3_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",_newsDetails.commentCount];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    }else{
        _rightBarBtn.frame = Small_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",_newsDetails.commentCount] ;
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    }
}
#pragma mark - 右导航栏按钮
- (void)rightBarButtonScrollToNewsCommitSection
{
    if (self.isReboundTop == NO) {
        self.readingOffest = self.tableView.contentOffset;
        NSIndexPath* lastSectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:(self.tableView.numberOfSections - 1)];
        [self.tableView scrollToRowAtIndexPath:lastSectionIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //        跳转到reading位置
        //        [self.tableView setContentOffset:self.readingOffest animated:YES];
    }
    self.isReboundTop = !self.isReboundTop;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 收藏
- (IBAction)favClick:(id)sender {
    
}

#pragma mark - 分享
- (IBAction)shareClick:(id)sender {
    [_commentTextField resignFirstResponder];
    
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
//    [self sendComment];
    
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
    
    _bottomConstraint.constant = _keyboardHeight;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _bottomConstraint.constant = 0;
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentTextField resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
