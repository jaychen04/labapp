//
//  RandomMessageCell.m
//  iosapp
//
//  Created by ChanAetern on 1/21/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "RandomMessageCell.h"
#import "Utils.h"

@implementation RandomMessageCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self setUpSubViews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setUpSubViews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFill;
    [_portrait setCornerRadius:5.0];
    [self addSubview:_portrait];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    [self addSubview:_contentLabel];
    
    _authorLabel = [UILabel new];
    _authorLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_authorLabel];
    
    _commentCount = [UILabel new];
    _commentCount.font = [UIFont systemFontOfSize:12];
    [self addSubview:_commentCount];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_timeLabel];
}

- (void)setLayout
{
    for (UIView *view in self.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _titleLabel, _contentLabel, _authorLabel, _commentCount, _timeLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-5-[_titleLabel]-5-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleLabel]-2-[_contentLabel]"
                                                                 options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-5-[_authorLabel]-5-|"
                                                                 options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_authorLabel]-3-[_commentCount]-3-[_timeLabel]-5-|"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}


@end
