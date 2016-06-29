//
//  SoftWareDetailBodyCell.m
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareDetailBodyCell.h"
#import "Utils.h"

@interface SoftWareDetailBodyCell ()

@end

@implementation SoftWareDetailBodyCell
-(void)awakeFromNib{
    _webView.scrollView.bounces = NO;
    _webView.scrollView.scrollEnabled = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor whiteColor];
}

@end
