//
//  OperationBar.m
//  iosapp
//
//  Created by ChanAetern on 1/19/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OperationBar.h"

@implementation OperationBar

- (id)initWithModeSwitchButton:(BOOL)hasAModeSwitchButton
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        [self addBorder];
        [self setLayoutWithModeSwitchButton:hasAModeSwitchButton];
    }
    
    return self;
}


- (void)setLayoutWithModeSwitchButton:(BOOL)hasAModeSwitchButton
{
    _modeSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_modeSwitchButton setImage:[UIImage imageNamed:@"button_keyboard_normal"] forState:UIControlStateNormal];
    
    _commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentsButton setImage:[UIImage imageNamed:@"button_emoji_normal"] forState:UIControlStateNormal];
    
    _starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_starButton setImage:[UIImage imageNamed:@"button_comment_normal"] forState:UIControlStateNormal];
    
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setImage:[UIImage imageNamed:@"button_comment_normal"] forState:UIControlStateNormal];
    
    _reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reportButton setImage:[UIImage imageNamed:@"button_comment_normal"] forState:UIControlStateNormal];
    
    [self addSubview:_modeSwitchButton];
    [self addSubview:_commentsButton];
    [self addSubview:_starButton];
    [self addSubview:_shareButton];
    [self addSubview:_reportButton];
    
    for (UIView *view in self.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_modeSwitchButton, _commentsButton, _starButton, _shareButton, _reportButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_modeSwitchButton]-3-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_modeSwitchButton]-5-[_commentsButton]-5-[_starButton]-5-[_shareButton]-5-[_reportButton]-5-|"
                                                                 options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                 metrics:nil views:views]];
}


- (void)addBorder
{
    UIView *upperBorder = [UIView new];
    upperBorder.backgroundColor = [UIColor lightGrayColor];
    upperBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:upperBorder];
    
    UIView *bottomBorder = [UIView new];
    bottomBorder.backgroundColor = [UIColor lightGrayColor];
    bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bottomBorder];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(upperBorder, bottomBorder);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[upperBorder]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[upperBorder(0.5)]->=0-[bottomBorder(0.5)]|"
                                                                 options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                 metrics:nil views:views]];
}

@end
