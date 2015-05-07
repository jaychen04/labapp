//
//  WeeklyReportContentCell.h
//  iosapp
//
//  Created by AeternChan on 5/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamWeeklyReportDetail;

@interface WeeklyReportContentCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;

- (void)setContentWithReportDetail:(TeamWeeklyReportDetail *)detail;

@end
