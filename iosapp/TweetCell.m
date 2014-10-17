//
//  TweetCell.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TweetCell.h"
#import "Utils.h"

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.backgroundColor = [Tools uniformColor];
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubviews];
        [self setLayout];
        
#if 0
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = UIColorFromRGB(0xdadbdc);
        [self setSelectedBackgroundView:selectedBackground];
#endif
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)initSubviews
{
    self.portrait = [UIImageView new];
    self.portrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.portrait];

    self.authorLabel = [UILabel new];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:14];
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
    
    self.contentText = [UITextView new];
    self.contentText.scrollEnabled = NO;
    self.contentText.editable = NO;
    [self.contentView addSubview:self.contentText];
    
    self.commentCount = [UILabel new];
    self.commentCount.font = [UIFont systemFontOfSize:14];
    self.commentCount.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:self.commentCount];
    
    self.image = [UIImageView new];
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.image];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _appclientLabel, _contentText, _commentCount, _image);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]-8-[_contentText]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_contentText]-8-|"
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
}

@end
