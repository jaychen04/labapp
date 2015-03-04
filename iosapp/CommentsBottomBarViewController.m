//
//  CommentsBottomBarViewController.m
//  iosapp
//
//  Created by ChanAetern on 1/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "CommentsBottomBarViewController.h"
#import "CommentsViewController.h"
#import "OSCComment.h"
#import "Config.h"
#import <MBProgressHUD.h>

@interface CommentsBottomBarViewController ()

@property (nonatomic, strong) CommentsViewController *commentsVC;
@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) int64_t objectUID;
@property (nonatomic, assign) int64_t replyID;
@property (nonatomic, assign) CommentType commentType;

@end

@implementation CommentsBottomBarViewController


- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _objectID = objectID;
        _commentType = commentType;
        
        _commentsVC = [[CommentsViewController alloc] initWithCommentType:commentType andObjectID:objectID];
        [self addChildViewController:_commentsVC];
        [self.editingBar.sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void)setUpBlock
{
    __weak CommentsBottomBarViewController *weakSelf = self;
    
    _commentsVC.didCommentSelected = ^(OSCComment *comment) {
        [weakSelf.editingBar.editView setPlaceholder:[NSString stringWithFormat:@"回复%@：", comment.author]];
    };
    
    _commentsVC.didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
    };
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setLayout
{
    [self.view addSubview:_commentsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"tableView": _commentsVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}


- (void)sendComment
{
    MBProgressHUD *HUD = [Utils createHUDInWindowOfView:self.view];
    if (self.editingBar.editView.text.length == 0) {
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        HUD.labelText = @"评论内容不能为空";
        [HUD hide:YES afterDelay:1];
        
        return;
    }
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    
    NSString *URL = _commentType == CommentTypeBlog? [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_BLOGCOMMENT_PUB] :
                                                     [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENT_PUB];
    
    NSDictionary *parameters = _commentType == CommentTypeBlog?
                                @{
                                  @"blog": @(_objectID),
                                  @"uid": @([Config getOwnID]),
                                  @"content": [Utils convertRichTextToRawText:self.editingBar.editView],
                                  @"reply_id": @(_replyID),
                                  @"objuid": @(_objectUID)
                                  }:
                                @{
                                  @"catalog": @(_commentType),
                                  @"id": @(_objectID),
                                  @"uid": @([Config getOwnID]),
                                  @"content": [Utils convertRichTextToRawText:self.editingBar.editView],
                                  @"isPostToMyZone": @(0)
                                };
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
              ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.labelText = @"评论发表成功";
              } else {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hide:YES afterDelay:2];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，动弹发送失败";
              
              [HUD hide:YES afterDelay:2];
          }];
}





@end
