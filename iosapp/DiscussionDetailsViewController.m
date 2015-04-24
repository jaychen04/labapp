//
//  DiscussionDetailsViewController.m
//  iosapp
//
//  Created by AeternChan on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "DiscussionDetailsViewController.h"
#import "Utils.h"
#import "TeamAPI.h"
#import "TeamDiscussionDetails.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

#define HTML_STYLE @"<style>\
                        #oschina_title {color: #000000; margin-bottom: 6px; font-weight:bold;}\
                        #oschina_outline {color: #707070; font-size: 12px;}\
                     </style>"

@interface DiscussionDetailsViewController () <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView *detailsView;
@property (nonatomic, assign) int discussionID;
@property (nonatomic, strong) TeamDiscussionDetails *discussionDetails;

@end

@implementation DiscussionDetailsViewController

- (instancetype)initWithDiscussionID:(int)discussionID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
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
                   @"teamid":@(12375),
                   @"discussid": @(_discussionID)
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _discussionDetails = [[TeamDiscussionDetails alloc] initWithXML:[responseObject.rootElement firstChildWithTag:@"discuss"]];
             
             NSString *titleHTML = [NSString stringWithFormat:@"<p><font size=1>%@发表于%@ %d赞 / %d回</font></p>", _discussionDetails.author.name,
                                                                                              [Utils intervalSinceNow:_discussionDetails.createTime],
                                                                                              _discussionDetails.voteUpCount, _discussionDetails.answerCount];
             NSString *HTML = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr>%@@<div style='margin-bottom:60px'/></body>",
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



@end
