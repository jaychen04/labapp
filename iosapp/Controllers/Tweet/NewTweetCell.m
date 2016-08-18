//
//  NewTweetCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/21.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewTweetCell.h"
#import "Utils.h"
#import "OSCTweetItem.h"
#import "ImageDownloadHandle.h"
#import "UIImageView+RadiusHandle.h"
#import "UIImageView+CornerRadius.h"

#import <Masonry.h>

@implementation NewTweetCell{
    __weak UIView* _colorLine;
    __weak UIImageView* _imageTypeLogo;
}

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
    [_userPortrait zy_cornerRadiusAdvance:22 rectCornerType:UIRectCornerAllCorners];
    [self.contentView addSubview:_userPortrait];
    
//    CALayer* maskLayer = [CALayer new];
//    maskLayer.frame = (CGRect){{0,0},_userPortrait.bounds.size};
//    maskLayer.backgroundColor = [UIColor redColor].CGColor;
//    maskLayer.contents = (id)[UIImage imageNamed:@"avatar_mask"].CGImage;
//    [_userPortrait.layer addSublayer:maskLayer];
//    [_userPortrait.layer insertSublayer:maskLayer atIndex:0];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor newTitleColor];
    [self.contentView addSubview:_nameLabel];
    
    _descTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [NewTweetCell initContetTextView:_descTextView];
    [self.contentView addSubview:_descTextView];
    
    _tweetImageView = [UIImageView new];
    _tweetImageView.contentMode = UIViewContentModeScaleAspectFill;
    _tweetImageView.clipsToBounds = YES;
    _tweetImageView.userInteractionEnabled = YES;
    _tweetImageView.hidden = YES;
    [self.contentView addSubview:_tweetImageView];
    
//    imageTypeLogo
    UIImageView* imageTypeLogo = [[UIImageView alloc]init];
    _imageTypeLogo = imageTypeLogo;
    _imageTypeLogo.userInteractionEnabled = NO;
    _imageTypeLogo.hidden = YES;
    [_tweetImageView addSubview:_imageTypeLogo];
    
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
    
    UIView* colorView = [[UIView alloc]init];
    colorView.backgroundColor = [UIColor separatorColor];
    _colorLine = colorView;
    [self.contentView addSubview:colorView];
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
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_tweetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
    }];
    
    [_imageTypeLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(_tweetImageView).with.offset(-2);
        make.width.equalTo(@18);
        make.height.equalTo(@11);
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

    [_colorLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.and.right.equalTo(self.contentView);
        make.height.equalTo(@0.5);
    }];
}

+ (void)initContetTextView:(UITextView*)textView
{
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.textColor = [UIColor newTitleColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
//    textView.backgroundColor = [UIColor redColor];
    textView.textContainer.lineFragmentPadding = 0;
    [textView setContentInset:UIEdgeInsetsMake(0, -1, 0, 1)];
    textView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    [textView setTextAlignment:NSTextAlignmentLeft];
    textView.text = @" ";
}

#pragma mark - set Tweet
- (void)setTweet:(OSCTweetItem *)model{
    UIImage* portrait = [ImageDownloadHandle retrieveMemoryAndDiskCache:model.author.portrait];
    if (!portrait) {
        _userPortrait.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loading"]];
        [ImageDownloadHandle downloadImageWithUrlString:model.author.portrait SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _userPortrait.userInteractionEnabled = YES;
                [_userPortrait setImage:image];
//                [_userPortrait addCorner:22];
            });
        }];
    }else{
        [_userPortrait setImage:portrait];
//        [_userPortrait addCorner:22];
    }
    
    _nameLabel.text = model.author.name;
    _descTextView.attributedText = [Utils contentStringFromRawString:model.content];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:model.pubDate] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)model.appClient]];
    _timeLabel.attributedText = att;
    
     if (model.liked) {
         [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_actived"] forState:UIControlStateNormal];
     } else {
         [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
     }

    _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)model.likeCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)model.commentCount];
    
    
    if (model.images.count == 1) {
        OSCTweetImages* imageData = [model.images lastObject];
        if ([imageData.thumb hasSuffix:@".gif"]) {
            _imageTypeLogo.image = [UIImage imageNamed:@"gif"];
            _imageTypeLogo.hidden = NO;
        }
        [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tweetImageView.mas_bottom).with.offset(6);
        }];
    } else {
        [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tweetImageView.mas_bottom).with.offset(0);
        }];
    }
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
    _tweetImageView.hidden = YES;
    _tweetImageView.image = nil;
    _descTextView.text = @" ";
    _imageTypeLogo.image = nil;
    _imageTypeLogo.hidden = YES;
}

@end
