//
//  BubbleChatViewController.m
//  iosapp
//
//  Created by ChanAetern on 2/15/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "BubbleChatViewController.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCPrivateChatController.h"

#import <MBProgressHUD.h>

@interface BubbleChatViewController () <UIWebViewDelegate>

@property (nonatomic, assign) int64_t userID;
@property (nonatomic, strong) OSCPrivateChatController *messageBubbleVC;

@end

@implementation BubbleChatViewController

- (instancetype)initWithUserID:(int64_t)userID andUserName:(NSString *)userName
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.navigationItem.title = userName;
        
        _userID = userID;
        _messageBubbleVC = [[OSCPrivateChatController alloc] initWithAuthorId:userID];
        [self addChildViewController:_messageBubbleVC];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setUpBlock
{
    __weak BubbleChatViewController *weakSelf = self;
    
    _messageBubbleVC.didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
        [weakSelf hideEmojiPageView];
    };
}


- (void)setLayout
{
    [self.view addSubview:_messageBubbleVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"messageBubbleTableView": _messageBubbleVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[messageBubbleTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[messageBubbleTableView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}


- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manager POST:[NSString stringWithFormat:@"%@messages_pub", OSCAPI_V2_PREFIX]
       parameters:@{
                    @"authorId": @(_userID),
                    @"content": [Utils convertRichTextToRawText:self.editingBar.editView],
                    @"resource": @(0)
                    }
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              NSInteger errorCode = [responseObject[@"code"] integerValue];
              
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];

                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = @"发送私信成功";
              } else {
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
              }
              [HUD hideAnimated:YES afterDelay:1];
              
              [_messageBubbleVC.tableView setContentOffset:CGPointZero animated:NO];
              [_messageBubbleVC refresh];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.label.text = @"网络异常，私信发送失败";

              [HUD hideAnimated:YES afterDelay:1];
          }];
    
}




@end
