//
//  NewTweetCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/21.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewTweetCell.h"
#import "Utils.h"

@implementation NewTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
//    _nameLabel.userInteractionEnabled = YES;
    _nameLabel.textColor = [UIColor newTitleColor];
    [self.contentView addSubview:_nameLabel];
    
    _descTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [NewTweetCell initContetTextView:_descTextView];
    [self.contentView addSubview:_descTextView];
    
    _tweetImageView = [UIImageView new];
    _tweetImageView.contentMode = UIViewContentModeScaleAspectFill;
    _tweetImageView.clipsToBounds = YES;
    _tweetImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_tweetImageView];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_timeLabel];
    
//    _likeImage = [UIImageView new];
//    _likeImage.image = [UIImage imageNamed:@"ic_thumbup_normal"];
//    [self.contentView addSubview:_likeImage];
    
    _likeCountLabel = [UILabel new];
    _likeCountLabel.font = [UIFont systemFontOfSize:12];
    _likeCountLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_likeCountLabel];
    
    _likeCountButton = [UIButton new];
    [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
    [self.contentView addSubview:_likeCountButton];

    _commentImage = [UIImageView new];
    _commentImage.image = [UIImage imageNamed:@"ic_comment_30"];
    [self.contentView addSubview:_commentImage];
    
    _commentCountLabel = [UILabel new];
    _commentCountLabel.font = [UIFont systemFontOfSize:12];
    _commentCountLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_commentCountLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_userPortrait, _nameLabel, _descTextView, _tweetImageView, _timeLabel, _likeCountButton, _likeCountLabel, _commentImage, _commentCountLabel);
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_userPortrait(45)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[_userPortrait(45)]-8-[_nameLabel]-16-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_nameLabel]-5-[_descTextView]-<=8-[_tweetImageView]-<=6-[_timeLabel]-16-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_likeCountButton(15)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_commentImage(15)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel(150)]->=5-[_likeCountButton(20)]-4-[_likeCountLabel]-8-[_commentImage(15)]-5-[_commentCountLabel]-16-|"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_descTextView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0]];
}

+ (void)initContetTextView:(UITextView*)textView
{
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textView.backgroundColor = [UIColor clearColor];
//    textView.font = [UIFont fontWithName:@"font-family:PingFangSC-Light" size:14];
    textView.font = [UIFont boldSystemFontOfSize:14.0];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
    textView.linkTextAttributes = @{
                                    NSFontAttributeName : @"PingFangSC-Light",
                                    NSForegroundColorAttributeName: [UIColor newTitleColor],
                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)
                                    };
}

/*
#pragma mark -  数组图片集
- (void)initImagesSubview
{
    
    int arrayCount = 1;
    
    int x = (int)(arrayCount-1)%3;//_images.count/3;
    int y = (int)(arrayCount-1)/3;//_images.count%3;
    
    if (arrayCount > 2) {
        x = 2;
        
    } else {
        x = arrayCount;
    }
    
    for (int i = 0; i <= x; i++) {
        for (int j = 0; j <= y; j++) {
            NSLog(@"(%d:%d)", i, j);
            UIImageView *image = [UIImageView new];
            image.frame = CGRectMake(68*i, 68*j, 60, 60);
//            image.backgroundColor = [UIColor yellowColor];
            [image loadPortrait:_tweet.smallImgURL];
            [self.imageBackView addSubview:image];
            if (j*3+i+1 > arrayCount) {
                image.hidden = YES;
            } else {
                image.hidden = NO;
            }
            image.tag = 3*i+j;
            [image addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)]];
        }
    }
}

- (void)clickImage:(UITapGestureRecognizer *)tap
{
    NSLog(@"tap");
}
*/
#pragma mark - set Tweet
- (void)setTweet:(OSCTweet *)tweet
{
    [_userPortrait loadPortrait:tweet.portraitURL];
    _nameLabel.text = tweet.author;
    _descTextView.attributedText = [NewTweetCell contentStringFromRawString:tweet.body];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:tweet.pubDateString] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:tweet.appclient]];
    _timeLabel.attributedText = att;
    
     if (tweet.isLike) {
         [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_actived"] forState:UIControlStateNormal];
     } else {
         [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
         
     }
//    [_likeCountButton setTitle:[NSString stringWithFormat:@"%d", tweet.likeCount] forState:UIControlStateNormal];
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
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(0, mutableAttrString.length)];
    
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
