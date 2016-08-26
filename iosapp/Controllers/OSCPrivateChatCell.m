//
//  OSCPrivateChatCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChatCell.h"
#import "OSCPrivateChat.h"
#import "ImageDownloadHandle.h"
#import "Utils.h"

#import <YYKit.h>

@interface PrivateChatNodeView : UIView

- (void)handleTimeLabel:(UILabel* )timeLabel;

- (UIImage* )selfPopImage;

- (UIImage* )otherPopImage;

- (UIImage* )fileTipImage;

@end

@implementation PrivateChatNodeView

- (void)handleTimeLabel:(UILabel *)timeLabel{
    timeLabel.font = [UIFont systemFontOfSize:CHAT_TIME_FONT_SIZE];
    timeLabel.textColor = CHAT_TIME_COLOR;
}

//image source...
static UIImage* _selfPopImage;
- (UIImage *)selfPopImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _selfPopImage = [UIImage imageNamed:@"bg_balloon_right"];
    });
    return _selfPopImage;
}
static UIImage* _otherPopImage;
- (UIImage *)otherPopImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _otherPopImage = [UIImage imageNamed:@"bg_balloon_left"];
    });
    return _otherPopImage;
}
static UIImage* _fileTipImage;
- (UIImage *)fileTipImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fileTipImage = [UIImage imageNamed:@""];
    });
    return _fileTipImage;
}
@end

#pragma mark --- 文本类型
@interface PrivateChatNodeTextView : PrivateChatNodeView{
    __weak UIImageView* _popImageView;
    __weak UITextView* _textView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@end

@implementation PrivateChatNodeTextView{
    CGRect _popFrame,_textFrame,_timeTipFrame;
    CGFloat _rowHeight;
    BOOL _isSelf;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImageView* popImageView = [UIImageView new];
            _popImageView = popImageView;
            _popImageView;
        })];
        [self addSubview:({
            UITextView* textView = [UITextView new];
            _textView = textView;
            _textView;
        })];
        [self addSubview:({
            UILabel* timeLabel = [UILabel new];
            _timeLabel = timeLabel;
            [self handleTimeLabel:_timeLabel];
            _timeLabel;
        })];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize popSize = _popFrame.size;
    CGSize textSize = _textFrame.size;
    if (_isSelf) {
        CGRect popFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width,SCREEN_PADDING_TOP},popSize};
        _popFrame = popFrame;
        CGRect textFrame = (CGRect){kScreen_Width - SCREEN_PADDING_RIGHT - PRIVATE_POP_PADDING_RIGHT - textSize.width,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP,textSize};
        _textFrame = textFrame;
    }else{
    
    }
    
    _popImageView.frame = _popFrame;
    _textView.frame = _textFrame;
    _timeLabel.frame = _timeTipFrame;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
    
    _isSelf = privateChatItem.sender.isBySelf;

    if (_isSelf) {
        [_popImageView setImage:[self selfPopImage]];
    }else{
        [_popImageView setImage:[self otherPopImage]];
    }
    _textView.attributedText = [Utils contentStringFromRawString:privateChatItem.content];
    _timeLabel.text = privateChatItem.pubDate;
    
    _popFrame = privateChatItem.popFrame;
    _textFrame = privateChatItem.textFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
    self.height = _rowHeight;
}

//长按处理
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}
- (void)copy:(id)sender{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_textView.text];
}

@end



#pragma mark --- 图片类型
@interface PrivateChatNodeImageView : PrivateChatNodeView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _photoView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@end

@implementation PrivateChatNodeImageView{
    CGRect _popFrame,_imageFrame,_timeTipFrame;
    CGFloat _rowHeight;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImageView* popImageView = [UIImageView new];
            _popImageView = popImageView;
            _popImageView;
        })];
        [self addSubview:({
            UIImageView* photoView = [UIImageView new];
            _photoView = photoView;
            _photoView;
        })];
        [self addSubview:({
            UILabel* timeLabel = [UILabel new];
            _timeLabel = timeLabel;
            [self handleTimeLabel:_timeLabel];
            _timeLabel;
        })];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _popImageView.frame = _popFrame;
    _photoView.frame = _imageFrame;
    _timeLabel.frame = _timeTipFrame;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
    
    if (privateChatItem.sender.isBySelf) {
        [_popImageView setImage:[self selfPopImage]];
    }else{
        [_popImageView setImage:[self otherPopImage]];
    }

    UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:privateChatItem.resource];
    if (!image) {
        [ImageDownloadHandle downloadImageWithUrlString:privateChatItem.resource SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _photoView.image = image;
            });
        }];
    }else{
        _photoView.image = image;
    }
    
    _popFrame = privateChatItem.popFrame;
    _imageFrame = privateChatItem.imageFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
}

@end



#pragma mark --- 文件类型
@interface PrivateChatNodeFileView : PrivateChatNodeView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _fileTipView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@end

@implementation PrivateChatNodeFileView{
    CGRect _popFrame,_fileFrame,_timeTipFrame;
    CGFloat _rowHeight;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImageView* popImageView = [UIImageView new];
            _popImageView = popImageView;
            _popImageView;
        })];
        [self addSubview:({
            UIImageView* fileTipView = [UIImageView new];
            _fileTipView = fileTipView;
            _fileTipView.image = [self fileTipImage];
            _fileTipView;
        })];
        [self addSubview:({
            UILabel* timeLabel = [UILabel new];
            _timeLabel = timeLabel;
            [self handleTimeLabel:_timeLabel];
            _timeLabel;
        })];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _popImageView.frame = _popFrame;
    _fileTipView.frame = _fileFrame;
    _timeLabel.frame = _timeTipFrame;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
    
    if (privateChatItem.sender.isBySelf) {
        [_popImageView setImage:[self selfPopImage]];
    }else{
        [_popImageView setImage:[self otherPopImage]];
    }
    _popFrame = privateChatItem.popFrame;
    _fileFrame = privateChatItem.fileFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
}

@end

























@interface OSCPrivateChatCell ()
@property (nonatomic,weak) PrivateChatNodeTextView* textChatView;
@property (nonatomic,weak) PrivateChatNodeImageView* imageChatView;
@property (nonatomic,weak) PrivateChatNodeFileView* fileChatView;
@end

@implementation OSCPrivateChatCell

+ (instancetype)returnReusePrivateChatCellWithTableView:(UITableView *)tableView
                                             identifier:(NSString *)identifier
{
    OSCPrivateChatCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[OSCPrivateChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (void)setPrivateChat:(OSCPrivateChat *)privateChat{
    if (!privateChat || _privateChat == privateChat) { return; }
    
    _privateChat = privateChat;

    [self _removeContentView];
    
    switch (_privateChat.privateChatType) {
        case OSCPrivateChatTypeText:{
            [self.contentView addSubview:self.textChatView];
            self.textChatView.privateChatItem = _privateChat;
            break;
        }
            
        case OSCPrivateChatTypeImage:{
            [self.contentView addSubview:self.imageChatView];
            self.imageChatView.privateChatItem = _privateChat;
            break;
        }
            
        case OSCPrivateChatTypeFile:{
            [self.contentView addSubview:self.fileChatView];
            self.fileChatView.privateChatItem = _privateChat;
            break;
        }
            
        default:
            NSLog(@"privateChatType is NSNotFound");
            break;
    }
    
}

- (void)_removeContentView{
    for (UIView* view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
}

#pragma mark --- lazy loading
- (PrivateChatNodeTextView *)textChatView {
    if(_textChatView == nil) {
        PrivateChatNodeTextView* textChatView = [[PrivateChatNodeTextView alloc] initWithFrame:self.contentView.bounds];
        _textChatView = textChatView;
    }
    return _textChatView;
}
- (PrivateChatNodeImageView *)imageChatView {
    if(_imageChatView == nil) {
        PrivateChatNodeImageView* imageChatView = [[PrivateChatNodeImageView alloc] initWithFrame:self.contentView.bounds];
        _imageChatView = imageChatView;
    }
    return _imageChatView;
}
- (PrivateChatNodeFileView *)fileChatView {
    if(_fileChatView == nil) {
        PrivateChatNodeFileView* fileChatView = [[PrivateChatNodeFileView alloc] initWithFrame:self.contentView.bounds];
        _fileChatView = fileChatView;
    }
    return _fileChatView;
}
@end








