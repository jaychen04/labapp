//
//  EmojiPanelVC.h
//  iosapp
//
//  Created by ChanAetern on 12/21/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiPanelVC : UIViewController

@property (nonatomic, readonly, assign) int pageIndex;

- (instancetype)initWithPageIndex:(int)pageIndex;

@end
