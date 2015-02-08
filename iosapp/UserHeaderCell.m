//
//  UserHeaderCell.m
//  iosapp
//
//  Created by ChanAetern on 2/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "UserHeaderCell.h"
#import "Utils.h"
#import "OSCUser.h"

@implementation UserHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithHex:0x00CD66];
        
        [self setLayout];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setLayout
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:25];
    _portrait.userInteractionEnabled = YES;
    [self.contentView addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    [self.contentView addSubview:_nameLabel];
    
    UIView *countView = [UIView new];
    [self.contentView addSubview:countView];
    
    _creditsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _followsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fansButton    = [UIButton buttonWithType:UIButtonTypeCustom];
    
    void (^setButtonStyle)(UIButton *, NSString *) = ^(UIButton *button, NSString *title) {
        [button setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:title forState:UIControlStateNormal];
        [countView addSubview:button];
    };
    
    setButtonStyle(_creditsButton, @"积分\n");
    setButtonStyle(_followsButton, @"关注\n");
    setButtonStyle(_fansButton,    @"粉丝\n");
    
    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    for (UIView *view in countView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _nameLabel, _creditsButton, _followsButton, _fansButton, countView);
    NSDictionary *metrics = @{@"width": @(self.frame.size.width / 3)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_portrait(50)]-8-[_nameLabel]-15-[countView(50)]|"
                                                                   options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(50)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[countView]|" options:0 metrics:nil views:views]];
    
    
    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_creditsButton(width)]->=0-[_followsButton(width)]->=0-[_fansButton(width)]|"
                                                                      options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_creditsButton]|" options:0 metrics:nil views:views]];
}


- (void)setContentWithUser:(OSCUser *)user
{
    [_portrait loadPortrait:user.portraitURL];
    _nameLabel.text = user.name;
    
    [_creditsButton setTitle:[NSString stringWithFormat:@"积分\n%d", user.score]          forState:UIControlStateNormal];
    [_followsButton setTitle:[NSString stringWithFormat:@"关注\n%d", user.followersCount] forState:UIControlStateNormal];
    [_fansButton    setTitle:[NSString stringWithFormat:@"粉丝\n%d", user.fansCount]      forState:UIControlStateNormal];
}


@end
