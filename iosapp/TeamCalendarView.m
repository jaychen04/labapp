//
//  TeamCalendarView.m
//  iosapp
//
//  Created by Holden on 15/5/28.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamCalendarView.h"
#import "UIColor+Util.h"
#import "MZDayPickerCell.h"
@implementation TeamCalendarView

-(instancetype)initTeamCalendarViewWithFrame:(CGRect)frame{
    
    self=[super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

-(void)setUpView{
    
    self.dayPicker = [[MZDayPicker alloc]initWithFrame:self.bounds dayCellSize:CGSizeMake(CGRectGetHeight(self.bounds)*3/5, CGRectGetHeight(self.bounds)*2/3) dayCellFooterHeight:CGRectGetHeight(self.bounds)*1/3];

    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    
    self.dayPicker.dayNameLabelFontSize = 12.0f;
    self.dayPicker.dayLabelFontSize = 18.0f;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-M"];
    [self.dayPicker setStartDate:[NSDate date] endDate:[NSDate dateFromDay:28 month:10 year:2113]];
    [self.dayPicker setCurrentDate:[NSDate date] animated:NO];
    
    [self addSubview:self.dayPicker];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [self.dayPicker addGestureRecognizer:tapGesture];
    
}
#pragma mark - UITapGestureRecognizer

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGesture
{
    
    CGPoint location = [tapGesture locationInView:tapGesture.view];
    MZDayPickerCell *cell = (MZDayPickerCell*)[self.dayPicker.tableView cellForRowAtIndexPath:self.dayPicker.currentIndex];
//    cell.containerView.backgroundColor = [UIColor redColor];

    NSLog(@"%f,%f,%f,%f",cell.containerView.frame.origin.x,cell.containerView.frame.origin.x,cell.containerView.frame.size.width,cell.containerView.frame.size.height);
    NSLog(@"point:%f,%f",location.x,location.y);
    
    if(CGRectContainsPoint(cell.containerView.frame,location)) {
        NSLog(@"..........");
    }
    
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        
//        CGPoint location = [tapGesture locationInView:tapGesture.view];
//        NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
//        
//        if (NSRangeContainsRow(self.activeDays, indexPath.row - kDefaultInitialInactiveDays + 1))
//        {
//            if (indexPath.row != self.currentIndex.row) {
//                
//                if ([self.delegate respondsToSelector:@selector(dayPicker:willSelectDay:)])
//                    [self.delegate dayPicker:self willSelectDay:self.tableDaysData[indexPath.row]];
//                
//                _currentDay = indexPath.row-1;
//                _currentDate = [(MZDay *)self.tableDaysData[indexPath.row] date];
//                [self setCurrentIndex:indexPath];
//            }
//        }
    }
}


#pragma mark --MZDayPickerDataSource
- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
    return [self.dateFormatter stringFromDate:day.date];
}

#pragma mark --MZDayPickerDelegate
- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
    NSLog(@"Did select day %@",day.day);
}

- (void)dayPicker:(MZDayPicker *)dayPicker willSelectDay:(MZDay *)day
{
    NSLog(@"Will select day %@",day.day);
}

- (void)viewDidUnload {
    [self setDayPicker:nil];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
