//
//  DiscussionDetailsViewController.m
//  iosapp
//
//  Created by AeternChan on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "DiscussionDetailsViewController.h"
#import "Utils.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamDiscussionDetails.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

#define HTML_STYLE @"<style>\
                        #oschina_title {color: #000000; margin-bottom: 6px; font-weight:bold;}\
                        #oschina_outline {color: #707070; font-size: 12px;}\
                     </style>"

@interface DiscussionDetailsViewController () <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView *detailsView;
@property (nonatomic, assign) int teamID;
@property (nonatomic, assign) int discussionID;
@property (nonatomic, strong) TeamDiscussionDetails *discussionDetails;

@end

@implementation DiscussionDetailsViewController

- (instancetype)initWithTeamID:(int)teamID andDiscussionID:(int)discussionID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        _teamID = teamID;
        _discussionID = discussionID;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"帖子详情";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _detailsView = [UIWebView new];
    _detailsView.delegate = self;
    _detailsView.scrollView.delegate = self;
    _detailsView.scrollView.bounces = NO;
    _detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_detailsView];
    
    [self.view bringSubviewToFront:self.editingBar];
    
    NSDictionary *views = @{@"detailsView": _detailsView, @"bottomBar": self.editingBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailsView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_DISCUSS_DETAIL]
      parameters:@{
                   @"teamid":@(_teamID),
                   @"discussid": @(_discussionID)
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _discussionDetails = [[TeamDiscussionDetails alloc] initWithXML:[responseObject.rootElement firstChildWithTag:@"discuss"]];
             
             NSString *titleHTML = [NSString stringWithFormat:@"<p><font size=1>%@发表于%@ %d赞 / %d回</font></p>", _discussionDetails.author.name,
                                                                                              [Utils intervalSinceNow:_discussionDetails.createTime],
                                                                                              _discussionDetails.voteUpCount, _discussionDetails.answerCount];
             NSString *HTML = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr>%@<div style='margin-bottom:60px'/></body>",
                               HTML_STYLE, _discussionDetails.title, titleHTML, _discussionDetails.body];
             [_detailsView loadHTMLString:HTML baseURL:nil];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.editingBar.editView) {
        [self.editingBar.editView resignFirstResponder];
        [self hideEmojiPageView];
    }
}



#pragma mark - 发表评论

- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_DISCUSS_REPLY]
       parameters:@{
                    @"uid": @([Config getOwnID]),
                    @"teamid": @(_teamID),
                    @"discussid": @(_discussionID),
                    @"content": [Utils convertRichTextToRawText:self.editingBar.editView]
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.labelText = @"评论发表成功";
              } else {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", error);
          }];
}


@end
