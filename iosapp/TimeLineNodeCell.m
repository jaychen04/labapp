//
//  TimeLineNodeCell.m
//  iosapp
//
//  Created by AeternChan on 5/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TimeLineNodeCell.h"
#import "Utils.h"

@implementation TimeLineNodeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor themeColor];
        
        [self setLayout];
    }
    return self;
}


- (void)setLayout
{
    UIView *node = [UIView new];
    node.backgroundColor = [UIColor colorWithHex:0x15A230];
    [node setCornerRadius:5];
    [self.contentView addSubview:node];
    
    _dayLabel = [UILabel new];
    _dayLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_dayLabel];
    
    _upperLine = [UIView new];
    _upperLine.backgroundColor = [UIColor colorWithHex:0x15A230];
    [self.contentView addSubview:_upperLine];
    
    _underLine = [UIView new];
    _underLine.backgroundColor = [UIColor colorWithHex:0x15A230];
    [self.contentView addSubview:_underLine];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_contentLabel];

    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(node, _dayLabel, _upperLine, _underLine, _contentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_upperLine(30)][node(10)][_underLine]|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_dayLabel]-8-[node(10)]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[node]-15-[_contentLabel]->=8-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_contentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                    toItem:_dayLabel     attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_upperLine(3)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_underLine(3)]" options:0 metrics:nil views:views]];
}

- (void)setContentWithString:(NSAttributedString *)HTML
{
    _contentLabel.attributedText = HTML;
}

@end
