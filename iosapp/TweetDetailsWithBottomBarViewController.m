//
//  TweetDetailsWithBottomBarViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TweetDetailsWithBottomBarViewController.h"
#import "TweetDetailsViewController.h"
#import "CommentsViewController.h"
#import "UserDetailsViewController.h"
#import "ImageViewerController.h"
#import "OSCTweet.h"
#import "TweetDetailsCell.h"


@interface TweetDetailsWithBottomBarViewController () <UIWebViewDelegate>

@property (nonatomic, strong) TweetDetailsViewController *tweetDetailsVC;

@end

@implementation TweetDetailsWithBottomBarViewController

- (instancetype)initWithTweetID:(int64_t)tweetID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _tweetDetailsVC = [[TweetDetailsViewController alloc] initWithTweetID:tweetID];
        [self addChildViewController:_tweetDetailsVC];
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

- (void)setLayout
{
    [self.view addSubview:_tweetDetailsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"tableView": _tweetDetailsVC.view, @"bottomBar": self.bottomBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}







@end
