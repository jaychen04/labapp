//
//  WeeklyReportTitleBar.m
//  iosapp
//
//  Created by AeternChan on 5/4/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportTitleBar.h"
#import "Utils.h"

@interface WeeklyReportTitleBar ()

@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UIButton *previousWeekBtn;
@property (nonatomic, strong) UIButton *nextWeekBtn;

@end

@implementation WeeklyReportTitleBar

- (instancetype)initWithFrame:(CGRect)frame andWeek:(NSInteger)week
{
    self = [super init];
    
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor colorWithHex:0xE1E1E1];
        
        [self setLayout];
        _weekLabel.text = [NSString stringWithFormat:@"第%ld周周报总览", week];
    }
    
    return self;
}

- (void)setLayout
{
    _weekLabel = [UILabel new];
    _weekLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:_weekLabel];
    
    _previousWeekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previousWeekBtn setTitle:@"P" forState:UIControlStateNormal];
    [self addSubview:_previousWeekBtn];
    
    _nextWeekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextWeekBtn setTitle:@"N" forState:UIControlStateNormal];
    [self addSubview:_nextWeekBtn];
    
    for (UIView *view in self.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_weekLabel, _previousWeekBtn, _nextWeekBtn);
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self       attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                        toItem:_weekLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self       attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                        toItem:_weekLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_previousWeekBtn(15)]-8-[_weekLabel]-8-[_nextWeekBtn(15)]"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}

- (void)updateWeek:(NSInteger)week
{
    _weekLabel.text = [NSString stringWithFormat:@"第%ld周周报总览", week];
}

@end
