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

@property (nonatomic, strong) NSMutableArray *clientAndCommentConstraints;
@property (nonatomic, strong) NSMutableArray *imageConstraints;
@property (nonatomic, strong) NSMutableArray *replyConstraints;

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
        
        if ([reuseIdentifier isEqualToString:kEventWitImageCellID]) {
            [self imageStyle];
        } else if ([reuseIdentifier isEqualToString:kEventWithReferenceCellID]) {
            [self referenceStyle];
        }
        
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
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_contentLabel];
    
    
// extra info
    _extraInfoView =  [UIView new];
    [self.contentView addSubview:_extraInfoView];
    
    _appclientLabel = [UILabel new];
    _appclientLabel.font = [UIFont systemFontOfSize:14];
    _appclientLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [_extraInfoView addSubview:_appclientLabel];
    
    _commentCount = [UILabel new];
    _commentCount.font = [UIFont systemFontOfSize:14];
    _commentCount.textColor = [UIColor colorWithHex:0xA0A3A7];
    [_extraInfoView addSubview:_commentCount];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    for (UIView *view in _extraInfoView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _actionLabel, _timeLabel, _appclientLabel, _contentLabel, _commentCount, _extraInfoView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_portrait(36)]-5-[_authorLabel]-5-[_timeLabel]-5-|"
                                                                             options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_authorLabel]-3-[_actionLabel]-5-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel]->=0-[_actionLabel]->=0-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllRight metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-5-[_extraInfoView]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    
    // constraints for extra information
    
    _clientAndCommentConstraints = (NSMutableArray *)[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_appclientLabel]|" options:0 metrics:nil views:views];
    [_clientAndCommentConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_appclientLabel]->=0-[_commentCount]-5-|"
                                                                                              options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}

- (void)setContentWithEvent:(OSCEvent *)event
{
    [_portrait loadPortrait:event.portraitURL];
    [_authorLabel setText:event.author];
    [_timeLabel setText:[Utils intervalSinceNow:event.pubDate]];
    [_appclientLabel setText:[Utils getAppclient:event.appclient]];
    [_actionLabel setAttributedText:event.actionStr];
    _commentCount.text = event.commentCount? [NSString stringWithFormat:@"评论：%d", event.commentCount] : @"";
    [_contentLabel setText:event.message];
    
    

    if (event.hasReference) {
        [_referenceText setText:[NSString stringWithFormat:@"%@: %@", event.objectReply[0], event.objectReply[1]]];
    }
    
    if (event.shouleShowClientOrCommentCount) {
        if (event.hasAnImage) {
            [_extraInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_thumbnail]-5-[_appclientLabel]"
                                                                                   options:0 metrics:nil views:NSDictionaryOfVariableBindings(_thumbnail, _appclientLabel)]];
        } else if (event.hasReference) {
            [_extraInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_referenceText]-5-[_appclientLabel]"
                                                                                   options:0 metrics:nil views:NSDictionaryOfVariableBindings(_referenceText, _appclientLabel)]];
        }
        [_extraInfoView addConstraints:_clientAndCommentConstraints];
    }
}

- (void)imageStyle
{
    _thumbnail = [UIImageView new];
    _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnail.userInteractionEnabled = YES;
    _thumbnail.translatesAutoresizingMaskIntoConstraints = NO;
    [_extraInfoView addSubview:_thumbnail];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_thumbnail);
    [_extraInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_thumbnail]->=0-|" options:0 metrics:nil views:views]];
    [_extraInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_thumbnail]" options:0 metrics:nil views:views]];
}

- (void)referenceStyle
{
    _referenceText = [UITextView new];
    _referenceText.scrollEnabled = NO;
    _referenceText.editable = NO;
    _referenceText.translatesAutoresizingMaskIntoConstraints = NO;
    [_extraInfoView addSubview:_referenceText];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_referenceText);
    [_extraInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_referenceText]->=0-|" options:0 metrics:nil views:views]];
    [_extraInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_referenceText]|" options:0 metrics:nil views:views]];
}






@end
