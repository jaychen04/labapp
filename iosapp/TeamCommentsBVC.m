//
//  TeamCommentsBVC.m
//  iosapp
//
//  Created by AeternChan on 5/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamCommentsBVC.h"
#import "Utils.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamActivity.h"
#import "TeamCommentsViewController.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

@interface TeamCommentsBVC ()

@property (nonatomic, assign) int teamID;
@property (nonatomic, strong) TeamActivity *activity;
@property (nonatomic, strong) TeamCommentsViewController *commentsVC;

@end

@implementation TeamCommentsBVC

- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        _teamID = teamID;
        _activity = activity;
        _commentsVC = [[TeamCommentsViewController alloc] initWithActivity:activity andTeamID:teamID];
        
        [self addChildViewController:_commentsVC];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:_commentsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"tableView": _commentsVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[Utils generateUserAgent] forHTTPHeaderField:@"User-Agent"];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_TWEET_REPLY]
       parameters:@{
                    @"teamid": @(_teamID),
                    @"uid": @([Config getOwnID]),
                    @"type": @(_activity.type),
                    @"tweetid": @(_activity.activityID),
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
                  
                  [_commentsVC.tableView setContentOffset:CGPointZero animated:NO];
                  [_commentsVC refresh];
              } else {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabelText = @"网络异常，评论发送失败";
              
              [HUD hide:YES afterDelay:1];
          }];
}



@end
