//
//  SoftwareCommentsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 2/3/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "SoftwareCommentsViewController.h"
#import "TweetsViewController.h"
#import "Config.h"

#import <MBProgressHUD.h>

@interface SoftwareCommentsViewController ()

@property (nonatomic, readonly, assign) int64_t softwareID;
@property (nonatomic, readonly, copy) NSString *softwareName;
@property (nonatomic, strong) TweetsViewController *tweetsViewController;

@end

@implementation SoftwareCommentsViewController

- (instancetype)initWithSoftwareID:(int64_t)softwareID andSoftwareName:(NSString *)softwareName
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        _softwareID = softwareID;
        _softwareName = [softwareName copy];
        _tweetsViewController = [[TweetsViewController alloc] initWithSoftwareID:softwareID];
        [self addChildViewController:_tweetsViewController];
        [self.editingBar.sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setUpBlock
{
    __weak SoftwareCommentsViewController *weakSelf = self;
    
    _tweetsViewController.didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
    };
}


- (void)setLayout
{
    [self.view addSubview:_tweetsViewController.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"softwaresTableView": _tweetsViewController.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[softwaresTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[softwaresTableView][editingBar]"
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
        
        return;
    }
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    NSString *tweetContent = [Utils convertRichTextToRawText:self.editingBar.editView];
    tweetContent = [tweetContent stringByAppendingString:[NSString stringWithFormat:@" #%@#", _softwareName]];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_PUB]
       parameters:@{
                    @"uid": @([Config getOwnID]),
                    @"msg": tweetContent
                    }

          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
              ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
              
              switch (errorCode) {
                  case 1: {
                      self.editingBar.editView.text = @"";
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.labelText = @"评论发表成功";
                      break;
                  }
                  case 0:
                  case -2:
                  case -1: {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                      break;
                  }
                  default: break;
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
