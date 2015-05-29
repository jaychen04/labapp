//
//  TeamCalendarView.h
//  iosapp
//
//  Created by Holden on 15/5/28.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZDayPicker.h"
@interface TeamCalendarView : UIView <MZDayPickerDelegate, MZDayPickerDataSource>
@property (nonatomic,strong)MZDayPicker *dayPicker;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

-(instancetype)initTeamCalendarViewWithFrame:(CGRect)frame;
@end
