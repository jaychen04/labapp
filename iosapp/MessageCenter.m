//
//  MessageCenter.m
//  iosapp
//
//  Created by ChanAetern on 3/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "MessageCenter.h"
#import "Config.h"
#import "OSCObjsViewController.h"
#import "EventsViewController.h"
#import "FriendsViewController.h"
#import "MessagesViewController.h"

#import "UIButton+Badge.h"

@interface MessageCenter ()

@property (nonatomic, strong) NSArray *noticesCount;

@end

@implementation MessageCenter

- (instancetype)init//WithNoticeCounts:(NSArray *)noticeCounts
{
    self = [super initWithTitle:@"消息中心"
                   andSubTitles:@[@"@我", @"评论", @"留言", @"粉丝"]
                 andControllers:@[
                                  [[EventsViewController alloc] initWithCatalog:2],
                                  [[EventsViewController alloc] initWithCatalog:3],
                                  [MessagesViewController new],
                                  [[FriendsViewController alloc] initWithUserID:[Config getOwnID] andFriendsRelation:0]
                                  ]];
    
    if (self) {
        //_noticesCount = noticeCounts;
        
        [self.titleBar.titleButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            CGSize size = [button.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            button.badgeValue = @"1";
            button.badgeOriginX = (button.frame.size.width + size.width) / 2;
            button.badgeOriginY = (button.frame.size.height - button.badge.frame.size.height) / 2;
            button.badgeBGColor = [UIColor redColor];
            button.badgeTextColor = [UIColor whiteColor];
        }];
        
        __weak MessageCenter *weakSelf = self;
        [self.viewPager.controllers enumerateObjectsUsingBlock:^(OSCObjsViewController *vc, NSUInteger idx, BOOL *stop) {
            vc.didRefreshSucceed = ^ {
                UIButton *button = weakSelf.titleBar.titleButtons[idx];
                button.badgeValue = @"0";
            };
        }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
