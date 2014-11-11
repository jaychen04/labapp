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

@interface TweetCell ()

@property (nonatomic, strong) NSArray *thumbnailConstraints;
@property (nonatomic, strong) NSArray *noThumbnailConstraints;

@end

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        self.thumbnailConstraints = [NSArray new];
        self.noThumbnailConstraints = [NSArray new];
        
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
    self.portrait = [UIImageView new];
    self.portrait.contentMode = UIViewContentModeScaleAspectFit;
    self.portrait.userInteractionEnabled = YES;
    [self.portrait setCornerRadius:5.0];
    [self.contentView addSubview:self.portrait];

    self.authorLabel = [UILabel new];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:14];
    self.authorLabel.userInteractionEnabled = YES;
    self.authorLabel.textColor = [UIColor colorWithHex:0x0083FF];
    [self.contentView addSubview:self.authorLabel];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:self.timeLabel];
    
    self.appclientLabel = [UILabel new];
    self.appclientLabel.font = [UIFont systemFontOfSize:14];
    self.appclientLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:self.appclientLabel];
    
    self.contentLabel = [UILabel new];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:self.contentLabel];
    
    self.commentCount = [UILabel new];
    self.commentCount.font = [UIFont systemFontOfSize:14];
    self.commentCount.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:self.commentCount];
    
    self.thumbnail = [UIImageView new];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.thumbnail];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _appclientLabel, _contentLabel, _commentCount, _thumbnail);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]-8-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_contentLabel]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-5-[_authorLabel]->=5-[_commentCount]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_authorLabel]-2-[_timeLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]-5-[_appclientLabel]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    self.thumbnailConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-5-[_thumbnail]-8-|"
                                                                     options:NSLayoutFormatAlignAllLeft
                                                                     metrics:nil
                                                                       views:viewsDict];
    
    self.noThumbnailConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-|"
                                                                          options:NSLayoutFormatAlignAllLeft
                                                                          metrics:nil
                                                                            views:viewsDict];
}





- (void)setContentWithTweet:(OSCTweet *)tweet
{
    [self.portrait sd_setImageWithURL:tweet.portraitURL placeholderImage:[UIImage imageNamed:@"portrait_loading"] options:0];
    [self.authorLabel setText:tweet.author];
    [self.timeLabel setText:[Utils intervalSinceNow:tweet.pubDate]];
    [self.appclientLabel setText:[Utils getAppclient:tweet.appclient]];
    [self.commentCount setText:[NSString stringWithFormat:@"评论：%d", tweet.commentCount]];
    [self.contentLabel setText:tweet.body];
    
    if (tweet.hasAnImage) {
#if 0   // iOS 8
        [NSLayoutConstraint deactivateConstraints:self.noThumbnailConstraints];
        [NSLayoutConstraint activateConstraints:self.thumbnailConstraints];
#else
        [self.contentView removeConstraints:self.noThumbnailConstraints];
        [self.contentView addConstraints:self.thumbnailConstraints];
#endif
    } else {
#if 0   // iOS 8
        [NSLayoutConstraint deactivateConstraints:self.thumbnailConstraints];
        [NSLayoutConstraint activateConstraints:self.noThumbnailConstraints];
#else
        [self.contentView removeConstraints:self.thumbnailConstraints];
        [self.contentView addConstraints:self.noThumbnailConstraints];
#endif
    }
}





@end
