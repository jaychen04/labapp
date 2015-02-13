//
//  MessageBubbleCell.m
//  iosapp
//
//  Created by ChanAetern on 2/12/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "MessageBubbleCell.h"
#import "Utils.h"

@interface MessageBubbleCell ()

@property (nonatomic, strong) UIView *bubbleContainer;
@property (nonatomic, strong) UIImageView *bubbleImageView;

@end

@implementation MessageBubbleCell

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
    [_portrait setCornerRadius:18];
    [self.contentView addSubview:_portrait];
    
    _bubbleContainer = [UIView new];
    [self.contentView addSubview:_bubbleContainer];
    
    UIImage *bubbleImage = [UIImage imageNamed:@"bubble"];
    bubbleImage = [self jsq_horizontallyFlippedImageFromImage:bubbleImage];
    bubbleImage = [bubbleImage resizableImageWithCapInsets:[self jsq_centerPointEdgeInsetsForImageSize:bubbleImage.size]
                                              resizingMode:UIImageResizingModeStretch];
    
    _bubbleImageView = [UIImageView new];
    _bubbleImageView.image = [UIImage imageNamed:@"bubble"];
    [_bubbleContainer addSubview:_bubbleImageView];
    
    _messageTextView = [UITextView new];
    _messageTextView.bounces = NO;
    [_bubbleContainer addSubview:_messageTextView];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _bubbleContainer);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_bubbleContainer]-8-|"
                                                                             options:NSLayoutFormatAlignAllBottom metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_bubbleContainer]-8-|" options:0 metrics:nil views:views]];
}


- (UIImage *)jsq_horizontallyFlippedImageFromImage:(UIImage *)image
{
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}


- (UIEdgeInsets)jsq_centerPointEdgeInsetsForImageSize:(CGSize)bubbleImageSize
{
    // make image stretchable from center point
    CGPoint center = CGPointMake(bubbleImageSize.width / 2.0f, bubbleImageSize.height / 2.0f);
    return UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
}

@end
