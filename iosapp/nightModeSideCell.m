//
//  nightModeSideCell.m
//  iosapp
//
//  Created by 李萍 on 15/6/17.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "nightModeSideCell.h"
#import "Utils.h"
#import "Config.h"

@implementation nightModeSideCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self initSubviews];
        [self setLayout];
    }
    return self;
}

- (void)initSubviews
{
    _image = [UIImageView new];
    [self.contentView addSubview:_image];
    
    _nightTextLabel = [UILabel new];
    _nightTextLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    _nightTextLabel.font = [UIFont systemFontOfSize:19];
    [self.contentView addSubview:_nightTextLabel];
    
    _isNightSwitch = [UISwitch new];
    _isNightSwitch.onTintColor = [UIColor nameColor];
    _isNightSwitch.tintColor = [UIColor colorWithRed:157.0/255 green:157.0/255 blue:159.0/255 alpha:1.0];
    _isNightSwitch.on = [Config getMode];
    [self.contentView addSubview:_isNightSwitch];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_image, _nightTextLabel, _isNightSwitch);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_image(20)]-15-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[_image(20)]-15-[_nightTextLabel]-15-[_isNightSwitch]"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}

@end
