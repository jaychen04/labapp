//
//  GrowingTextView.h
//  iosapp
//
//  Created by ChanAetern on 11/17/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrowingTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, readonly) NSUInteger numberOfLines;
@property (nonatomic, assign) NSUInteger maxNumberOfLines;

@end
