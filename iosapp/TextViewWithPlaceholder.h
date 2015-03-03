//
//  TextViewWithPlaceholder.h
//  iosapp
//
//  Created by chenhaoxiang on 3/3/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewWithPlaceholder : UITextView

- (instancetype)initWithPlaceholder:(NSString *)placeholder;
- (void)setPlaceholder:(NSString *)placeholder;

@end
