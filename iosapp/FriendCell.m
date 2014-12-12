//
//  FriendCell.m
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "FriendCell.h"
#import "Utils.h"

@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    
    return self;
}

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.numberOfLines = 0;
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textColor = [UIColor colorWithHex:0x6A5ACD];
    [self.contentView addSubview:_nameLabel];
    
    _expertiseLabel = [UILabel new];
    _expertiseLabel.numberOfLines = 0;
    _expertiseLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _expertiseLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_expertiseLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _nameLabel, _expertiseLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_nameLabel]-8-|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_nameLabel]-2-[_expertiseLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:views]];
}


@end
