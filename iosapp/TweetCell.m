//
//  TweetCell.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TweetCell.h"
#import "OSCTweet.h"
#import "Utils.h"

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        _thumbnailConstraints = [NSArray new];
        _noThumbnailConstraints = [NSArray new];
        
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
    _authorLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_authorLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _appclientLabel = [UILabel new];
    _appclientLabel.font = [UIFont systemFontOfSize:12];
    _appclientLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_appclientLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_contentLabel];
    
    _commentCount = [UILabel new];
    _commentCount.font = [UIFont systemFontOfSize:12];
    _commentCount.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_commentCount];
    
    _thumbnail = [UIImageView new];
    _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnail.clipsToBounds = YES;
    _thumbnail.userInteractionEnabled = YES;
    [self.contentView addSubview:_thumbnail];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _appclientLabel, _contentLabel, _commentCount, _thumbnail);
    

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_authorLabel]-8-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_authorLabel]-5-[_contentLabel]-<=5-[_thumbnail(80)]-6-[_timeLabel]-5-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_thumbnail(80)]"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]-5-[_appclientLabel]->=5-[_commentCount]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_authorLabel  attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                                                    toItem:_contentLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}


- (void)setContentWithTweet:(OSCTweet *)tweet
{
    [_portrait loadPortrait:tweet.portraitURL];
    [_authorLabel setText:tweet.author];
    [_timeLabel setText:[Utils intervalSinceNow:tweet.pubDate]];
    [_appclientLabel setText:[Utils getAppclient:tweet.appclient]];
    [_commentCount setText:[NSString stringWithFormat:@"评论：%d", tweet.commentCount]];
    [_contentLabel setAttributedText:[Utils emojiStringFromRawString:tweet.body]];
}


#pragma mark - 处理长按操作

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return _canPerformAction(self, action);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)copyText:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_contentLabel.text];
}

- (void)deleteTweet:(id)sender
{
    _deleteTweet(self);
}



@end
