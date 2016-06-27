//
//  NewTweetCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/21.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewTweetCell.h"
#import "Utils.h"
#import <Masonry.h>

@implementation NewTweetCell

#pragma mark - 留白处理frame算高
/**
-(CGSize)sizeThatFits:(CGSize)size{
    CGFloat cellRowHeight = 0;
    
    cellRowHeight += [self.nameLabel sizeThatFits:size].height;
    cellRowHeight += [self.descTextView sizeThatFits:size].height;
    cellRowHeight += [self.tweetImageView sizeThatFits:size].height;
    cellRowHeight += 61;
    cellRowHeight += 13;

    return CGSizeMake(size.width, cellRowHeight);
}
 */


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
        
        [self initWithSubViews];
        [self setLayout];
    }
    return self;
}

#pragma mark - 初始化
- (void)initWithSubViews
{
    _userPortrait = [UIImageView new];
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    _userPortrait.userInteractionEnabled = YES;
    [_userPortrait setCornerRadius:22];
    [self.contentView addSubview:_userPortrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    _nameLabel.textColor = [UIColor newTitleColor];
    [self.contentView addSubview:_nameLabel];
    
    _descTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [NewTweetCell initContetTextView:_descTextView];
    [self.contentView addSubview:_descTextView];
    
    _tweetImageView = [UIImageView new];
    _tweetImageView.contentMode = UIViewContentModeScaleAspectFill;
//    _tweetImageView.contentMode = UIViewContentModeLeft;
    _tweetImageView.clipsToBounds = YES;
    _tweetImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_tweetImageView];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_timeLabel];
    
    _likeCountLabel = [UILabel new];
    _likeCountLabel.textAlignment = NSTextAlignmentRight;
    _likeCountLabel.font = [UIFont systemFontOfSize:12];
    _likeCountLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_likeCountLabel];
    
    _likeCountButton = [UIButton new];
    [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
    [_likeCountButton setImageEdgeInsets:UIEdgeInsetsMake(0, 25, 2, 0)];
    [self.contentView addSubview:_likeCountButton];

    _commentImage = [UIImageView new];
    _commentImage.image = [UIImage imageNamed:@"ic_comment_30"];
    [self.contentView addSubview:_commentImage];
    
    _commentCountLabel = [UILabel new];
    _commentCountLabel.textAlignment = NSTextAlignmentRight;
    _commentCountLabel.font = [UIFont systemFontOfSize:12];
    _commentCountLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_commentCountLabel];
}

- (void)setLayout
{
    
#pragma mark - change using Masnory add Constraints
    
    [_userPortrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(16);
        make.width.and.height.equalTo(@45);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(16);
        make.left.equalTo(_userPortrait.mas_right).with.offset(8);
    }];
    
    [_descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.contentView).with.offset(-8);
    }];
    
    [_tweetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
//        make.right.equalTo(@(-16));
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_tweetImageView.mas_bottom).with.offset(6);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@15);
        make.right.equalTo(_commentCountLabel.mas_left).with.offset(-5);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_commentImage.mas_left).with.offset(-16);
    }];
    
    [_likeCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_likeCountLabel.mas_left).with.offset(-5);
    }];

}

+ (void)initContetTextView:(UITextView*)textView
{
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont fontWithName:@"PingFangSC-Light" size:14.0];
    textView.textColor = [UIColor newTitleColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
}

#pragma mark - set Tweet
- (void)setTweet:(OSCTweet *)tweet
{
    [_userPortrait loadPortrait:tweet.portraitURL];
    _nameLabel.text = tweet.author;
    _descTextView.attributedText = [NewTweetCell contentStringFromRawString:tweet.body];
//    <a href='http://my.oschina.net/javayou' class='referer' target='_blank'>@红薯</a>  真粉，有木有？
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:tweet.pubDateString] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:tweet.appclient]];
    _timeLabel.attributedText = att;
    
     if (tweet.isLike) {
         [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_actived"] forState:UIControlStateNormal];
     } else {
         [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
         
     }

    _likeCountLabel.text = [NSString stringWithFormat:@"%d", tweet.likeCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%d", tweet.commentCount];
    
    
    if (tweet.hasAnImage) {
        _tweetImageView.hidden = NO;
        [_tweetImageView loadPortrait:tweet.smallImgURL];
//        [self initImagesSubview];
    } else {
        _imageBackView.hidden = YES;
        _tweetImageView.hidden = YES;
    }
    
}

+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    NSMutableAttributedString *mutableAttrString = [[Utils emojiStringFromAttrString:attrString] mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Light" size:14.0] range:NSMakeRange(0, mutableAttrString.length)];
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, mutableAttrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
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
    [pasteBoard setString:_descTextView.text];
}

- (void)deleteObject:(id)sender
{
    _deleteObject(self);
}

#pragma mark - prepare for reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _tweetImageView.image = nil;
}

@end
