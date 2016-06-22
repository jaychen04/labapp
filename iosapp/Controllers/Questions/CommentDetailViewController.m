//
//  CommentDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "QuestCommentHeadDetailCell.h"

#import "Utils.h"
static NSString* const CommentHeadDetailCellIdentifier = @"QuestCommentHeadDetailCell";
@interface CommentDetailViewController () <UITableViewDelegate, UITableViewDataSource>

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

@end

@implementation CommentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"QuestCommentHeadDetailCell" bundle:nil] forCellReuseIdentifier:CommentHeadDetailCellIdentifier];
    
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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_upImageView setImage:[UIImage imageNamed:@"ic_vote_up_big_normal"] forState:UIControlStateNormal];
    [subView addSubview:_upImageView];
    [_upImageView addTarget:self action:@selector(voteUpQuestions:) forControlEvents:UIControlEventTouchUpInside];
    
    _upLabel = [UILabel new];
    _upLabel.textAlignment = NSTextAlignmentCenter;
    _upLabel.font = [UIFont systemFontOfSize:13];
    _upLabel.textColor = [UIColor newAssistTextColor];
    _upLabel.text = @"顶";
    [subView addSubview:_upLabel];
    
    _downImageView = [UIButton new];
    [_downImageView setImage:[UIImage imageNamed:@"ic_vote_down_big_normal"] forState:UIControlStateNormal];
    [subView addSubview:_downImageView];
    [_downImageView addTarget:self action:@selector(voteDownQuestions:) forControlEvents:UIControlEventTouchUpInside];
    
    _downLabel = [UILabel new];
    _downLabel.textAlignment = NSTextAlignmentCenter;
    _downLabel.font = [UIFont systemFontOfSize:13];
    _downLabel.textColor = [UIColor newAssistTextColor];
    _downLabel.text = @"踩";
    [subView addSubview:_downLabel];
    
    
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

#pragma MARK - 踩/顶
- (void)roteUpOrDown
{
    [self customPopUpBoxView];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        QuestCommentHeadDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentHeadDetailCellIdentifier forIndexPath:indexPath];
        [cell.downOrUpButton addTarget:self action:@selector(roteUpOrDown) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    } else {
        return 200;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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

@end
