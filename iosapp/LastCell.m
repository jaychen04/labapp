//
//  LastCell.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-18.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "LastCell.h"
#import "UIColor+Util.h"

@interface LastCell ()

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (readwrite, nonatomic, assign) LastCellStatus status;

@end

@implementation LastCell

- (instancetype)initCell {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor themeColor];
        self.status = LastCellStatusNotVisible;
        
        [self setLayout];
    }
    
    return self;
}

- (void)setLayout
{
    self.textLabel.backgroundColor = [UIColor themeColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin |
                                  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _indicator.color = [UIColor colorWithRed:54/255 green:54/255 blue:54/255 alpha:1.0];
    _indicator.center = self.center;
    [self.contentView addSubview:_indicator];
}

- (void)statusMore
{
    [_indicator stopAnimating];
    self.textLabel.text = @"More...";
    self.userInteractionEnabled = YES;
    self.status = LastCellStatusMore;
}

- (void)statusLoading
{
    [_indicator startAnimating];
    self.textLabel.text = @"";
    self.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.status = LastCellStatusLoading;
}

- (void)statusFinished
{
    [_indicator stopAnimating];
    self.textLabel.text = @"全部加载完毕";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.status = LastCellStatusFinished;
}

- (void)statusError
{
    [_indicator stopAnimating];
    self.textLabel.text = @"加载数据出错";
    self.userInteractionEnabled = YES;
    self.status = LastCellStatusError;
}


@end
