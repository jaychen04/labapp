//
//  BottomBarViewController.h
//  iosapp
//
//  Created by ChanAetern on 11/19/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BottomBar;
@class EmojiPageVC;

@interface BottomBarViewController : UIViewController

@property (nonatomic, strong) BottomBar *bottomBar;
@property (nonatomic, strong) EmojiPageVC *emojiPanelVC;
@property (nonatomic, strong) UIView *emojiPanel;
@property (nonatomic, strong) NSLayoutConstraint *bottomBarYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomBarHeightConstraint;

@end
