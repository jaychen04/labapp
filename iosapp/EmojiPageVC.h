//
//  EmojiPageVC.h
//  iosapp
//
//  Created by chenhaoxiang on 11/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextViewWithPlaceholder;

@interface EmojiPageVC : UIPageViewController

- (instancetype)initWithTextView:(TextViewWithPlaceholder *)textView;

@end
