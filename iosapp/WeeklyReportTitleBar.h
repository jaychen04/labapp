//
//  WeeklyReportTitleBar.h
//  iosapp
//
//  Created by AeternChan on 5/4/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeeklyReportTitleBar : UIView

- (instancetype)initWithFrame:(CGRect)frame andWeek:(NSInteger)week;
- (void)updateWeek:(NSInteger)week;

@end
