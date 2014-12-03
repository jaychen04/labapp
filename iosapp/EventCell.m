//
//  EventCell.m
//  iosapp
//
//  Created by ChanAetern on 12/1/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EventCell.h"
#import "OSCEvent.h"
#import "Utils.h"

@interface EventCell()

@property (nonatomic, strong) NSArray *extraInfoConstraints;
@property (nonatomic, strong) NSArray *noExtraInfoConstraints;

@end

@implementation EventCell

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
    _portrait.userInteractionEnabled = YES;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _authorLabel = [UILabel new];
    _authorLabel.font = [UIFont boldSystemFontOfSize:14];
    _authorLabel.userInteractionEnabled = YES;
    _authorLabel.textColor = [UIColor colorWithHex:0x0083FF];
    [self.contentView addSubview:_authorLabel];
    
    _actionLabel = [UILabel new];
    _actionLabel.numberOfLines = 0;
    _actionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _actionLabel.font = [UIFont systemFontOfSize:14];
    _actionLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_actionLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _appclientLabel = [UILabel new];
    _appclientLabel.font = [UIFont systemFontOfSize:14];
    _appclientLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_appclientLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_contentLabel];
    
    _commentCount = [UILabel new];
    _commentCount.font = [UIFont systemFontOfSize:14];
    _commentCount.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_commentCount];
    
    _thumbnail = [UIImageView new];
    _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnail.userInteractionEnabled = YES;
    [self.contentView addSubview:_thumbnail];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _actionLabel, _timeLabel, _appclientLabel, _contentLabel, _commentCount, _thumbnail);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_portrait(36)]-5-[_authorLabel]-5-[_timeLabel]-5-|"
                                                                             options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_authorLabel]-3-[_actionLabel]-5-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel]->=0-[_actionLabel]-5-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllRight metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_appclientLabel]->=0-[_commentCount]-5-|"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]->=5-[_appclientLabel]-5-|"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    _noExtraInfoConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-5-|" options:0 metrics:nil views:views];
    //[self.contentView addConstraints:_noExtraInfoConstraints];
    
    NSLayoutConstraint *topConstraint   = [NSLayoutConstraint constraintWithItem:_appclientLabel attribute:NSLayoutAttributeTop     relatedBy:NSLayoutRelationEqual
                                                                          toItem:_contentLabel   attribute:NSLayoutAttributeBottom  multiplier:1 constant:5];
    NSLayoutConstraint *leftConstraint  = [NSLayoutConstraint constraintWithItem:_appclientLabel attribute:NSLayoutAttributeLeft    relatedBy:NSLayoutRelationEqual
                                                                          toItem:_contentLabel   attribute:NSLayoutAttributeLeft    multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_commentCount   attribute:NSLayoutAttributeRight   relatedBy:NSLayoutRelationEqual
                                                                          toItem:_timeLabel      attribute:NSLayoutAttributeRight   multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_appclientLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:5];
    NSLayoutConstraint *alignConstraint = [NSLayoutConstraint constraintWithItem:_appclientLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                                          toItem:_commentCount   attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    _extraInfoConstraints = @[topConstraint, leftConstraint, rightConstraint, bottomConstraint, alignConstraint];
}

- (void)setContentWithEvent:(OSCEvent *)event
{
    [_portrait loadPortrait:event.portraitURL];
    [_authorLabel setText:event.author];
    [_timeLabel setText:[Utils intervalSinceNow:event.pubDate]];
    [_appclientLabel setText:[Utils getAppclient:event.appclient]];
    [_actionLabel setAttributedText:event.actionStr];
    if (event.commentCount) {
        [_commentCount setText:[NSString stringWithFormat:@"评论：%d", event.commentCount]];
    } else {
        _commentCount.hidden = YES;
    }

    [_contentLabel setText:event.message];
    
#if 0
    if (event.tweetImg) {
        [self.contentView removeConstraints:_extraInfoConstraints];
        [self.contentView addConstraints:_noExtraInfoConstraints];
    } else {
        [self.contentView removeConstraints:_extraInfoConstraints];
        [self.contentView addConstraints:_noExtraInfoConstraints];
    }
#endif
}







@end
