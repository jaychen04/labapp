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
#import "OSCPhotoGroupView.h"
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

@property (nonatomic,weak) OSCPrivateChatCell* privateChatCell;

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
    CGSize timeSize = _timeTipFrame.size;
    if (_isSelf) {
        CGRect popFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width,SCREEN_PADDING_TOP},popSize};
        _popFrame = popFrame;
        CGRect textFrame = (CGRect){kScreen_Width - SCREEN_PADDING_RIGHT - PRIVATE_POP_PADDING_RIGHT - textSize.width,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP,textSize};
        _textFrame = textFrame;
        CGRect timeTipFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width - PRIVATE_TIME_TIP_PADDING - timeSize.width,_rowHeight - SCREEN_PADDING_BOTTOM - timeSize.height},timeSize};
        _timeTipFrame = timeTipFrame;
    }else{
        CGRect popFrame = (CGRect){{SCREEN_PADDING_LEFT,SCREEN_PADDING_TOP},popSize};
        _popFrame = popFrame;
        CGRect textFrame = (CGRect){{SCREEN_PADDING_LEFT + PRIVATE_POP_PADDING_LEFT,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP},textSize};
        _textFrame = textFrame;
        CGRect timeTipFrame = (CGRect){{SCREEN_PADDING_LEFT + popSize.width + PRIVATE_TIME_TIP_PADDING,_rowHeight - SCREEN_PADDING_BOTTOM - timeSize.height},timeSize};
        _timeTipFrame = timeTipFrame;
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

#define MAX_IMAGE_SIZE_W PRIVATE_MAX_WIDTH

@interface PrivateChatNodeImageView : PrivateChatNodeView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _photoView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@property (nonatomic,weak) OSCPrivateChatCell* privateChatCell;

@end

@implementation PrivateChatNodeImageView{
    CGRect _popFrame,_imageFrame,_timeTipFrame;
    CGFloat _rowHeight;
    BOOL _isSelf;
    BOOL _trackingTouch_PhotoImageView;
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
    
    CGSize popSize = _popFrame.size;
    CGSize imageSize = _imageFrame.size;
    CGSize timeSize = _timeTipFrame.size;
    
    if (_isSelf){
        CGRect popFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width,SCREEN_PADDING_TOP},popSize};
        _popFrame = popFrame;
        CGRect imageFrame = (CGRect){kScreen_Width - SCREEN_PADDING_RIGHT - PRIVATE_POP_PADDING_RIGHT - imageSize.width,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP,imageSize};
        _imageFrame = imageFrame;
        CGRect timeTipFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width - PRIVATE_TIME_TIP_PADDING - timeSize.width,_rowHeight - SCREEN_PADDING_BOTTOM - timeSize.height},timeSize};
        _timeTipFrame = timeTipFrame;
    }else{
        CGRect popFrame = (CGRect){{SCREEN_PADDING_LEFT,SCREEN_PADDING_TOP},popSize};
        _popFrame = popFrame;
        CGRect imageFrame = (CGRect){{SCREEN_PADDING_LEFT + PRIVATE_POP_PADDING_LEFT,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP},imageSize};
        _imageFrame = imageFrame;
        CGRect timeTipFrame = (CGRect){{SCREEN_PADDING_LEFT + popSize.width + PRIVATE_TIME_TIP_PADDING,_rowHeight - SCREEN_PADDING_BOTTOM - timeSize.height},timeSize};
        _timeTipFrame = timeTipFrame;
    }
    
    _popImageView.frame = _popFrame;
    _photoView.frame = _imageFrame;
    _timeLabel.frame = _timeTipFrame;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
    
    _isSelf = privateChatItem.sender.isBySelf;;
    
    if (_isSelf) {
        [_popImageView setImage:[self selfPopImage]];
    }else{
        [_popImageView setImage:[self otherPopImage]];
    }

    UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:privateChatItem.resource];
    if (!image) {
        _photoView.backgroundColor = [UIColor grayColor];
        [ImageDownloadHandle downloadImageWithUrlString:privateChatItem.resource SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            CGSize resultSize = [self adjustImage:image];
            privateChatItem.imageFrame = (CGRect){{0,0},resultSize};
            privateChatItem.popFrame = privateChatItem.imageFrame;
            privateChatItem.rowHeight = resultSize.height + SCREEN_PADDING_TOP + SCREEN_PADDING_BOTTOM;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_privateChatCell.delegate respondsToSelector:@selector(privateChatNodeImageViewloadThumbImageDidFinsh:)]) {
                    [_privateChatCell.delegate privateChatNodeImageViewloadThumbImageDidFinsh:_privateChatCell];
                }
            });
        }];
    }else{
        _photoView.image = image;
        [self maskView:_photoView image:_popImageView.image];
    }
    
    _popFrame = privateChatItem.popFrame;
    _imageFrame = privateChatItem.imageFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
    self.height = _rowHeight;
}

#pragma mark --- 图片大小 & 遮罩处理
- (CGSize)adjustImage:(UIImage* )image{
    if (!image) {return CGSizeZero;}
    CGSize resultSize ;
    if (image.size.width > MAX_IMAGE_SIZE_W) {
        resultSize = (CGSize){MAX_IMAGE_SIZE_W,(MAX_IMAGE_SIZE_W * image.size.height) / image.size.width};
    }else{
        resultSize = image.size;
    }
    return resultSize;
}
- (void)maskView:(UIView *)view image:(UIImage *)image {
    NSParameterAssert(view != nil);
    NSParameterAssert(image != nil);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0, 0);
    
    view.layer.mask = imageViewMask.layer;
}
#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_PhotoImageView = NO;
    UITouch* t = [touches anyObject];
    CGPoint p = [t locationInView:_photoView];
    if (CGRectContainsPoint(_photoView.bounds, p)) {
        _trackingTouch_PhotoImageView = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_PhotoImageView) {
        UIImageView* fromView = _photoView;
        
        OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
        currentPhotoItem.largeImageURL = [NSURL URLWithString:_privateChatItem.resource];
        currentPhotoItem.thumbView = fromView;
        
        OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
        if ([_privateChatCell.delegate respondsToSelector:@selector(privateChatNodeImageViewloadLargerImageDidFinsh:photoGroupView:fromView:)]) {
            [_privateChatCell.delegate privateChatNodeImageViewloadLargerImageDidFinsh:_privateChatCell photoGroupView:photoGroup fromView:fromView];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch_PhotoImageView) {
        [super touchesCancelled:touches withEvent:event];
    }
}
@end



#pragma mark --- 文件类型
@interface PrivateChatNodeFileView : PrivateChatNodeView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _fileTipView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@property (nonatomic,weak) OSCPrivateChatCell* privateChatCell;

@end

@implementation PrivateChatNodeFileView{
    CGRect _popFrame,_fileFrame,_timeTipFrame;
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
    
    CGSize popSize = _popFrame.size;
    CGSize fileSize = _fileFrame.size;
    CGSize timeSize = _timeTipFrame.size;
    
    if (_isSelf) {
        CGRect popFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width,SCREEN_PADDING_TOP},popSize};
        _popFrame = popFrame;
        CGRect fileFrame = (CGRect){kScreen_Width - SCREEN_PADDING_RIGHT - PRIVATE_POP_PADDING_RIGHT - fileSize.width,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP,fileSize};
        _fileFrame = fileFrame;
        CGRect timeTipFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width - PRIVATE_TIME_TIP_PADDING - timeSize.width,_rowHeight - SCREEN_PADDING_BOTTOM - timeSize.height},timeSize};
        _timeTipFrame = timeTipFrame;
    }else{
        CGRect popFrame = (CGRect){{SCREEN_PADDING_LEFT,SCREEN_PADDING_TOP},popSize};
        _popFrame = popFrame;
        CGRect fileFrame = (CGRect){{SCREEN_PADDING_LEFT + PRIVATE_POP_PADDING_LEFT,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP},fileSize};
        _fileFrame = fileFrame;
        CGRect timeTipFrame = (CGRect){{SCREEN_PADDING_LEFT + popSize.width + PRIVATE_TIME_TIP_PADDING,_rowHeight - SCREEN_PADDING_BOTTOM - timeSize.height},timeSize};
        _timeTipFrame = timeTipFrame;
    }
    
    _popImageView.frame = _popFrame;
    _fileTipView.frame = _fileFrame;
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
    
    _popFrame = privateChatItem.popFrame;
    _fileFrame = privateChatItem.fileFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
    self.height = _rowHeight;
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
            self.textChatView.privateChatCell = self;
            self.textChatView.privateChatItem = _privateChat;
            break;
        }
        case OSCPrivateChatTypeImage:{
            [self.contentView addSubview:self.imageChatView];
            self.imageChatView.privateChatCell = self;
            self.imageChatView.privateChatItem = _privateChat;
            break;
        }
        case OSCPrivateChatTypeFile:{
            [self.contentView addSubview:self.fileChatView];
            self.fileChatView.privateChatCell = self;
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








