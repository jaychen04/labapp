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
        
        if ([reuseIdentifier isEqualToString:kTweeWithoutImagetCellID]) {
            [self.contentView addConstraints:_noThumbnailConstraints];
        } else if ([reuseIdentifier isEqualToString:kTweetWithImageCellID]) {
            [self.contentView addConstraints:_thumbnailConstraints];
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
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _appclientLabel, _contentLabel, _commentCount, _thumbnail);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_contentLabel]-8-|" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-5-[_authorLabel]->=5-[_commentCount]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_authorLabel]-2-[_timeLabel]-8-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]-5-[_appclientLabel]"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    _thumbnailConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-5-[_thumbnail]-8-|"
                                                                        options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
    
    _noThumbnailConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-|"
                                                                          options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
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





@end
