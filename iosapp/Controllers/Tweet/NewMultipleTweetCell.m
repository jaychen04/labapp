//
//  NewMultipleTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/7/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewMultipleTweetCell.h"
#import "OSCTweetItem.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "UIView+Util.h"
#import "NSDate+Util.h"

#import "UserDetailsViewController.h"

#import <SDWebImage/SDImageCache.h>
#import <SDWebImageDownloaderOperation.h>
#import <Masonry.h>

#define Trumpet_Height 60
#define Medium_Height 136
#define Large_Height 212
#define ImageItemSize 60
#define ImageItemPadding 16

@interface NewMultipleTweetCell () {
    NSMutableArray* _imageViewsArray;   //二维数组 _imageViewsArray[line][row]
}
@end

@implementation NewMultipleTweetCell{
    __weak UIImageView* _userPortrait;
    __weak UILabel* _nameLabel;
//    __weak UITextView* _descTextView;
    
    __weak UIView* _imagesView;
    __weak UIView* _colorLine;
    
    __weak UILabel* _timeLabel;
    __weak UILabel* _likeCountLabel;
    __weak UIImageView* _commentImage;
    __weak UILabel* _commentCountLabel;
}
#pragma mark -
#pragma mark --- 初始化cell
+(instancetype)returnReuseMultipeTweetCellWithTableView:(UITableView *)tableView
                                             identifier:(NSString *)reuseIdentifier
                                              indexPath:(NSIndexPath *)indexPath
{
    NewMultipleTweetCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NewMultipleTweetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSubViews];
        [self setLayout];
    }
    return self;
}



#pragma mark - 
#pragma mark --- set SubViews
-(void)setSubViews{
    UIImageView* userPortrait = [[UIImageView alloc]init];
    userPortrait.userInteractionEnabled = YES;
    userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    [userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userPortraitDidClickMethod:)]];
    [userPortrait setCornerRadius:22];
    _userPortrait = userPortrait;
    [self.contentView addSubview:_userPortrait];

    UILabel* nameLabel = [[UILabel alloc]init];
    nameLabel.font = [UIFont boldSystemFontOfSize:15];
    nameLabel.numberOfLines = 1;
    nameLabel.textColor = [UIColor newTitleColor];
    _nameLabel = nameLabel;
    [self.contentView addSubview:_nameLabel];
    
    UITextView* descTextView = [[UITextView alloc]init];
    descTextView.userInteractionEnabled = YES;
    descTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    descTextView.backgroundColor = [UIColor clearColor];
    descTextView.font = [UIFont systemFontOfSize:14];
    descTextView.textColor = [UIColor newTitleColor];
    descTextView.editable = NO;
    descTextView.scrollEnabled = NO;
    [descTextView setTextContainerInset:UIEdgeInsetsZero];
    descTextView.textContainer.lineFragmentPadding = 0;
    _descTextView = descTextView;
    [self.contentView addSubview:_descTextView];

    UIView* imagesView = [[UIView alloc]init];
    _imagesView = imagesView;
    [self.contentView addSubview:_imagesView];
    
    UILabel* timeLabel = [[UILabel alloc]init];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor newAssistTextColor];
    _timeLabel = timeLabel;
    [self.contentView addSubview:_timeLabel];
    
    UIButton* likeCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
    [likeCountButton setImageEdgeInsets:UIEdgeInsetsMake(0, 25, 2, 0)];
    _likeCountButton = likeCountButton;
    [self.contentView addSubview:_likeCountButton];
    
    UILabel* likeCountLabel = [[UILabel alloc]init];
    likeCountLabel.textAlignment = NSTextAlignmentRight;
    likeCountLabel.font = [UIFont systemFontOfSize:12];
    likeCountLabel.textColor = [UIColor newAssistTextColor];
    _likeCountLabel = likeCountLabel;
    [self.contentView addSubview:_likeCountLabel];
    
    UIImageView* commentImage = [[UIImageView alloc]init];
    commentImage.image = [UIImage imageNamed:@"ic_comment_30"];
    _commentImage = commentImage;
    [self.contentView addSubview:_commentImage];
    
    UILabel* commentCountLabel = [[UILabel alloc]init];
    commentCountLabel.textAlignment = NSTextAlignmentRight;
    commentCountLabel.font = [UIFont systemFontOfSize:12];
    commentCountLabel.textColor = [UIColor newAssistTextColor];
    _commentCountLabel = commentCountLabel;
    [self.contentView addSubview:_commentCountLabel];
    
    UIView* colorLine = [[UIView alloc]init];
    colorLine.backgroundColor = [UIColor grayColor];
    _colorLine = colorLine;
    [self.contentView addSubview:_colorLine];
    
    [self addMultiples];
}

#pragma mark --- set Layout （ Masnory ）
-(void)setLayout{
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
        make.right.equalTo(self.contentView).with.offset(-8);
    }];
    
    [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
        make.width.equalTo(@212);
        make.height.equalTo(@Trumpet_Height);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_imagesView.mas_bottom).with.offset(3);
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



#pragma mark -
#pragma mark --- setting Model
-(void)setTweetItem:(OSCTweetItem *)tweetItem{
    _tweetItem = tweetItem;
    
    [self settingContentForSubViews:tweetItem];
}

#pragma mrak --- 设置内容给子视图
-(void)settingContentForSubViews:(OSCTweetItem* )model{
    UIImage* portrait = [self retrieveMemoryAndDiskCache:model.author.portrait];
    if (!portrait) {
        _userPortrait.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loading"]];
        [self downloadImageWithUrlString:model.author.portrait displayNode:_userPortrait];
    }else{
        [_userPortrait setImage:portrait];
    }
    
    _nameLabel.text = model.author.name;
    
    _descTextView.text = model.content;
    
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
    
//    Assignment and update the layout
    [self assemblyContentToImageViewsWithImagesCount:model.images.count];
}


#pragma mark -
#pragma mark --- Using a for loop
//add NewMultipleTweetCell
-(void)addMultiples{
    _imageViewsArray = [NSMutableArray arrayWithCapacity:3];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    for (int i = 0 ; i < 3; i++) {//line
        originY = i * (ImageItemSize + ImageItemPadding);
        NSMutableArray* lineNodes = [NSMutableArray arrayWithCapacity:3];
        for (int j = 0; j < 3; j++) {//row
            originX = j * (ImageItemSize + ImageItemPadding);
            UIImageView* imageView = [[UIImageView alloc]init];
            imageView.backgroundColor = [UIColor redColor];
            imageView.frame = (CGRect){{originX,originY},{ImageItemSize,ImageItemSize}};
            [_imagesView addSubview:imageView];
            [lineNodes addObject:imageView];
        }
        [_imageViewsArray addObject:lineNodes];
    }
}
//assembly NewMultipleTweetCell
-(void)assemblyContentToImageViewsWithImagesCount:(NSInteger)count{
    if (count <= 3) {   //Single line layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@Trumpet_Height);
        }];
        for (int i = 0; i < count; i++) {
            OSCTweetImages* imageData = _tweetItem.images[i];
            UIImageView* imageView = (UIImageView* )_imageViewsArray[0][i];
            imageView.hidden = NO;
            UIImage* image = [self retrieveMemoryAndDiskCache:imageData.href];
            if (!image) {
                [self downloadImageWithUrlString:imageData.href displayNode:imageView];
            }else{
                [imageView setImage:image];
            }
        }
    }else if (count <= 6){  //Double row layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@Medium_Height);
        }];
        if (count == 4) {
            [self loopAssemblyContentWithLine:2 row:2];
        }else{
            [self loopAssemblyContentWithLine:2 row:((int)count - 3)];
        }
    }else{  //Three lines layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@Large_Height);
        }];
        [self loopAssemblyContentWithLine:3 row:((int)count - 6)];
    }
}

-(void)loopAssemblyContentWithLine:(int)line row:(int)row{
    int dataIndex = 0;
    for (int i = 0; i < line; i++) {
        for (int j = 0; j < row; j++) {
            OSCTweetImages* imageData = _tweetItem.images[dataIndex];
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.hidden = NO;
            UIImage* image = [self retrieveMemoryAndDiskCache:imageData.href];
            if (!image) {
                [self downloadImageWithUrlString:imageData.href displayNode:imageView];
            }else{
                [imageView setImage:image];
            }
            dataIndex++;
        }
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


#pragma mark --- click Method
-(void)userPortraitDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(userPortraitDidClick: tapGestures:)]) {
        [_delegate userPortraitDidClick:self tapGestures:tap];
    }
}


#pragma mark --- emoji Handle
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    NSMutableAttributedString *mutableAttrString = [[Utils emojiStringFromAttrString:attrString] mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, mutableAttrString.length)];
    
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

#pragma mark --- retrieve && download image
-(nullable UIImage *)retrieveMemoryAndDiskCache:(NSString* )imageKey{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageKey];
    if (!image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageKey];
        if (!image) {
            return nil;
        }else{
            return image;
        }
    }else{
        return image;
    }
}

-(void)downloadImageWithUrlString:(NSString* )url displayNode:(UIImageView* )node{
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url]
                                                        options:SDWebImageDownloaderUseNSURLCache
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                          
      [[SDImageCache sharedImageCache] storeImage:image forKey:url toDisk:YES];
          dispatch_async(dispatch_get_main_queue(), ^{
              [node setImage:image];
              if ([_delegate respondsToSelector:@selector(assemblyMultipleTweetCellDidFinsh:)]) {
                  [_delegate assemblyMultipleTweetCellDidFinsh:self];
              }
          });
    }];

}

#pragma mark - prepare for reuse
- (void)prepareForReuse
{
    [super prepareForReuse];

    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.hidden = YES;
            imageView.image = nil;
        }
    }
}

@end
