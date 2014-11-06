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
@property (nonatomic, strong) UILabel *statusLabel;
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
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.contentView.bounds.size.width, 20)];
    _statusLabel.backgroundColor = [UIColor themeColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.contentView addSubview:_statusLabel];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.color = [UIColor colorWithRed:54/255 green:54/255 blue:54/255 alpha:1.0];
    _indicator.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2 + 5);
    [self.contentView addSubview:_indicator];
}

- (void)statusMore
{
    [_indicator stopAnimating];
    _statusLabel.text = @"More...";
    self.userInteractionEnabled = YES;
    self.status = LastCellStatusMore;
}

- (void)statusLoading
{
    [_indicator startAnimating];
    _statusLabel.text = @"";
    self.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.status = LastCellStatusLoading;
}

- (void)statusFinished
{
    [_indicator stopAnimating];
    _statusLabel.text = @"全部加载完毕";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.status = LastCellStatusFinished;
}

- (void)statusError
{
    [_indicator stopAnimating];
    _statusLabel.text = @"加载数据出错";
    self.userInteractionEnabled = YES;
    self.status = LastCellStatusError;
}


@end
