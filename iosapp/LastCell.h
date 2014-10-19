//
//  LastCell.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-18.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastCell : UITableViewCell

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *statusLabel;

- (instancetype)initCell;
- (void)normal;
- (void)loading;
- (void)finishedLoad;
- (void)empty;

@end
