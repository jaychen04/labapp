//
//  CommentDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "QuestCommentHeadDetailCell.h"
#import "NewCommentCell.h"
#import "ContentWebViewCell.h"

#import "Utils.h"
#import "OSCAPI.h"
#import "Config.h"
#import "LoginViewController.h"

#import <MJExtension.h>


static NSString* const CommentHeadDetailCellIdentifier = @"QuestCommentHeadDetailCell";
static NSString *contentWebReuseIdentifier = @"contentWebTableViewCell";
static NSString * const newCommentReuseIdentifier = @"NewCommentCell";

@interface CommentDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstrait;


@property (nonatomic, strong) UIView *popUpBoxView;
@property (nonatomic, strong) UIButton *upImageView;
@property (nonatomic, strong) UILabel *upLabel;
@property (nonatomic, strong) UIButton *downImageView;
@property (nonatomic, strong) UILabel *downLabel;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;

@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, copy) OSCNewComment *commentDetail;

@end

@implementation CommentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"回答详情";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"QuestCommentHeadDetailCell" bundle:nil] forCellReuseIdentifier:CommentHeadDetailCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContentWebViewCell" bundle:nil] forCellReuseIdentifier:contentWebReuseIdentifier];
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:newCommentReuseIdentifier];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarButtonClicked)];
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self getDataForCommentDetail];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)getDataForCommentDetail
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@comment", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:@{
                  @"id"  : @(self.commentId),
                  @"type"      : @(2),
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"] integerValue] == 1) {
                _commentDetail = [OSCNewComment mj_objectWithKeyValues:responseObject[@"result"]];
                NSDictionary *data = @{@"content":  _commentDetail.content};
                _commentDetail.content = [Utils HTMLWithData:data
                                             usingTemplate:@"newTweet"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
            
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {

            NSLog(@"error = %@",error);
        }];
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonClicked
{
    //
    NSLog(@"右导航栏按钮");
}

#pragma mark - 自定义弹出框
- (void)customPopUpBoxView
{
    UIWindow *selfWindow = [UIApplication sharedApplication].keyWindow;
    _popUpBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(selfWindow.frame), CGRectGetHeight(selfWindow.frame))];
    _popUpBoxView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.5];
    _popUpBoxView.userInteractionEnabled = YES;
    [_popUpBoxView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenPopUpBoxView)]];
    [selfWindow addSubview:_popUpBoxView];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(selfWindow.frame)-240)/2, (CGRectGetHeight(selfWindow.frame)-200)/2, 240, 120)];
    subView.backgroundColor = [UIColor whiteColor];
    [subView setCornerRadius:3.0];
    [_popUpBoxView addSubview:subView];
    
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor newSecondTextColor];
    label.text = @"为这个回答投票";
    [subView addSubview:label];
    
    _upImageView = [UIButton new];
    
    [subView addSubview:_upImageView];
    [_upImageView addTarget:self action:@selector(voteUpQuestions:) forControlEvents:UIControlEventTouchUpInside];
    
    _upLabel = [UILabel new];
    _upLabel.textAlignment = NSTextAlignmentCenter;
    _upLabel.font = [UIFont systemFontOfSize:13];
    _upLabel.textColor = [UIColor newAssistTextColor];
    _upLabel.text = @"顶";
    [subView addSubview:_upLabel];
    
    _downImageView = [UIButton new];
    
    [subView addSubview:_downImageView];
    [_downImageView addTarget:self action:@selector(voteDownQuestions:) forControlEvents:UIControlEventTouchUpInside];
    
    _downLabel = [UILabel new];
    _downLabel.textAlignment = NSTextAlignmentCenter;
    _downLabel.font = [UIFont systemFontOfSize:13];
    _downLabel.textColor = [UIColor newAssistTextColor];
    _downLabel.text = @"踩";
    [subView addSubview:_downLabel];
    
    //按钮状态样式
    [self judgeVoteState];
    
    //布局
    for (UIView *view in subView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(label, _upImageView, _upLabel, _downImageView, _downLabel);
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]"
                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                    metrics:nil views:views]];
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[label]-16-|"
                                                                    options:0
                                                                    metrics:nil views:views]];
    
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-10-[_upImageView(45)]-10-[_upLabel]"
                                                                    options:0
                                                                    metrics:nil views:views]];
    
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-10-[_downImageView(45)]-10-[_downLabel]"
                                                                    options:0
                                                                    metrics:nil views:views]];
    
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-55-[_upImageView(45)]-40-[_downImageView(45)]"
                                                                             options:0
                                                                             metrics:nil views:views]];
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-55-[_upLabel(45)]-40-[_downLabel(45)]"
                                                                    options:0
                                                                    metrics:nil views:views]];
}

- (void)judgeVoteState
{
    switch (_commentDetail.voteState) {
        case 0:
        {
            [_upImageView setImage:[UIImage imageNamed:@"ic_vote_up_big_normal"] forState:UIControlStateNormal];
            [_downImageView setImage:[UIImage imageNamed:@"ic_vote_down_big_normal"] forState:UIControlStateNormal];
            break;
        }
        case 1://已顶
        {
            [_upImageView setImage:[UIImage imageNamed:@"ic_vote_up_big_actived"] forState:UIControlStateNormal];
            [_downImageView setImage:[UIImage imageNamed:@"ic_vote_down_big_normal"] forState:UIControlStateNormal];
            break;
        }
        case 2://已踩
        {
            [_upImageView setImage:[UIImage imageNamed:@"ic_vote_up_big_normal"] forState:UIControlStateNormal];
            [_downImageView setImage:[UIImage imageNamed:@"ic_vote_down_big_actived"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 顶

- (void)voteUpQuestions:(UIButton *)button
{
    NSLog(@"顶");
    [_popUpBoxView removeFromSuperview];
}

#pragma mark - 踩
- (void)voteDownQuestions:(UIButton *)button
{
    NSLog(@"踩");
    
    [_popUpBoxView removeFromSuperview];
}

- (void)hidenPopUpBoxView
{
    [_popUpBoxView removeFromSuperview];
}

#pragma MARK - 踩/顶
- (void)roteUpOrDown
{
    [self customPopUpBoxView];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            QuestCommentHeadDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentHeadDetailCellIdentifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.downOrUpButton addTarget:self action:@selector(roteUpOrDown) forControlEvents:UIControlEventTouchUpInside];
            
            cell.commentDetail = _commentDetail;
            
            return cell;
        } else {
            ContentWebViewCell *webViewCell = [tableView dequeueReusableCellWithIdentifier:contentWebReuseIdentifier forIndexPath:indexPath];
            webViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            webViewCell.contentWebView.delegate = self;
            [webViewCell.contentWebView loadHTMLString:_commentDetail.content baseURL:[NSBundle mainBundle].resourceURL];
            webViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return webViewCell;
        }
    } else if (indexPath.section == 1) {
        NewCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:newCommentReuseIdentifier forIndexPath:indexPath];
        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_commentDetail.reply.count > 0) {
            OSCNewCommentReply *reply = _commentDetail.reply[indexPath.row];
            [commentCell setDataForQuestionCommentReply:reply];
            
            commentCell.commentButton.tag = indexPath.row;
            [commentCell.commentButton addTarget:self action:@selector(selectedToComment:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return commentCell;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60;
        } else {
            return _webViewHeight+30;
        }
    } else if (indexPath.section == 1) {
        if (_commentDetail.reply.count > 0) {
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            
            OSCNewCommentReply *quesCommentReply = _commentDetail.reply[indexPath.row];
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:quesCommentReply.content]];
            label.attributedText = contentString;
            
            CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 32, MAXFLOAT)].height;
            
            return height + 71;
        } else {
            return 0;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSLog(@"click = %ld", (long)indexPath.row);
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_commentDetail.reply.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return _commentDetail.reply.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerViewHeight = 0.001;
    if (section != 0) {
        headerViewHeight = 32;
    }
    return headerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        if (_commentDetail.reply.count > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_commentDetail.reply.count]];
        }
        return [self headerViewWithSectionTitle:@"评论"];
    }
    
    return [UIView new];
}

#pragma mark -- DIY_headerView
- (UIView *)headerViewWithSectionTitle:(NSString *)title {
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
    
//    if (_isReply) {
//        OSCBlogDetailComment *comment = _blogDetailComments[_selectIndexPath];
//        [self sendComment:comment.id authorID:comment.authorId];
//    } else {
//        [self sendComment:0 authorID:0];
//    }
    
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
    
    _bottomConstrait.constant = _keyboardHeight;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _bottomConstrait.constant = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentField resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

#pragma mark - 评论
- (void)selectedToComment:(UIButton *)button
{
    OSCNewCommentReply *reply = _commentDetail.reply[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
        _commentField.placeholder = [NSString stringWithFormat:@"@%@", reply.author];
    } else {
        _commentField.placeholder = @"我要评论";
    }
    
    
}

#pragma mark - 发评论
- (void)sendComment:(NSInteger)replyID authorID:(NSInteger)authorID
{
    //
    MBProgressHUD *HUD = [Utils createHUD];
    //    HUD.labelText = @"评论发送中";
    
    
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//        
//        NSString *urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_PREFIX,OSCAPI_COMMENT_PUB];
//        NSDictionary *parameters =  @{
//                                        @"catalog": @(1),
//                                        @"id": @(_commentDetail.id),
//                                        @"uid": @([Config getOwnID]),
//                                        @"replyid": @(replyID),
//                                        @"authorid": @(authorID),
//                                        @"content": _commentField.text,
//                                        @"isPostToMyZone": @(0)
//                                        };
//        [manager POST:urlStr
//           parameters:parameters
//              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
//                  ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
//                  int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
//                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
//                  
//                  HUD.mode = MBProgressHUDModeCustomView;
//                  
//                  if (errorCode == 1) {
//                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
//                      HUD.labelText = @"评论发表成功";
//                      
//                      [self.tableView reloadData];
//                      _commentTextField.text = @"";
//                  } else {
//                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//                      HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
//                  }
//                  
//                  [HUD hide:YES afterDelay:1];
//                  
//                  
//              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                  HUD.mode = MBProgressHUDModeCustomView;
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//                  HUD.labelText = @"网络异常，动弹发送失败";
//                  
//                  [HUD hide:YES afterDelay:1];
//              }];
        
    }
}

@end
