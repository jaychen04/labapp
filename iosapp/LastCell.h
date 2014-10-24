//
//  LastCell.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-18.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LastCellStatus)
{
    LastCellStatusNotVisible,
    LastCellStatusMore,
    LastCellStatusLoading,
    LastCellStatusError,
    LastCellStatusFinished,
};

@interface LastCell : UITableViewCell

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign) LastCellStatus status;

- (instancetype)initCell;
- (void)statusMore;
- (void)statusLoading;
- (void)statusFinished;
- (void)statusError;

@end
