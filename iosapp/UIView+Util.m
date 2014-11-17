//
//  UIView+Util.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-17.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "UIView+Util.h"

@implementation UIView (Util)

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setBorderWidth:(CGFloat)width andColor:(CGColorRef)color
{
    self.layer.borderWidth = width;
    self.layer.borderColor = color;
}

@end
