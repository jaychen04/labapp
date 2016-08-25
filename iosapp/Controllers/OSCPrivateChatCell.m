//
//  OSCPrivateChatCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChatCell.h"
#import "OSCPrivateChat.h"

#pragma mark --- 文本类型
@interface PrivateChatNodeTextView : UIView

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@end

@implementation PrivateChatNodeTextView{
    __weak UIImageView* _popImageView;
    __weak UITextView* _textView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* popImageView = [UIImageView new];
        _popImageView = popImageView;
        [self addSubview:_popImageView];

        UITextView* textView = [UITextView new];
        _textView = textView;
        [self addSubview:_textView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
}

@end



#pragma mark --- 图片类型
@interface PrivateChatNodeImageView : UIView

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@end

@implementation PrivateChatNodeImageView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _photoView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* popImageView = [UIImageView new];
        _popImageView = popImageView;
        [self addSubview:_popImageView];
        
        UIImageView* photoView = [UIImageView new];
        _photoView = photoView;
        [self addSubview:_photoView];
    }
    return self;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
}


@end



#pragma mark --- 文件类型
@interface PrivateChatNodeFileView : UIView

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@end

@implementation PrivateChatNodeFileView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _fileTipView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* popImageView = [UIImageView new];
        _popImageView = popImageView;
        [self addSubview:_popImageView];
        
        UIImageView* fileTipView = [UIImageView new];
        _fileTipView = fileTipView;
        [self addSubview:_fileTipView];
    }
    return self;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
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
        PrivateChatNodeTextView* textChatView = [[PrivateChatNodeTextView alloc] init];
        _textChatView = textChatView;
    }
    return _textChatView;
}

- (PrivateChatNodeImageView *)imageChatView {
    if(_imageChatView == nil) {
        PrivateChatNodeImageView* imageChatView = [[PrivateChatNodeImageView alloc] init];
        _imageChatView = imageChatView;
    }
    return _imageChatView;
}

- (PrivateChatNodeFileView *)fileChatView {
    if(_fileChatView == nil) {
        PrivateChatNodeFileView* fileChatView = [[PrivateChatNodeFileView alloc] init];
        _fileChatView = fileChatView;
    }
    return _fileChatView;
}

@end








