//
//  OSCPrivateChat.m
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChat.h"
#import "Config.h"
#import "Utils.h"
#import "OSCPrivateChatCell.h"

@implementation OSCPrivateChat

- (void)setType:(NSInteger)type{
    _type = type;
    
    if (type == 1) {
        _privateChatType = OSCPrivateChatTypeText;
    }else if (type == 3){
        _privateChatType = OSCPrivateChatTypeImage;
        _imageFrame = (CGRect){{0,0},{PRIVATE_IMAGE_DEFAULT_W,PRIVATE_IMAGE_DEFAULT_H}};
        _popFrame = (CGRect){{0,0},{PRIVATE_IMAGE_DEFAULT_W,PRIVATE_IMAGE_DEFAULT_H}};
        _timeTipFrame = (CGRect){{0,0},{PRIVATE_TIME_TIP_W,PRIVATE_TIME_TIP_H}};
    }else if (type == 5){
        _privateChatType = OSCPrivateChatTypeFile;
        _fileFrame = (CGRect){{0,0},{PRIVATE_FILE_TIP_W,PRIVATE_FILE_TIP_H}};
        _popFrame = (CGRect){{0,0},{PRIVATE_FILE_TIP_W + 10,PRIVATE_FILE_TIP_H + 10}};
        _timeTipFrame = (CGRect){{0,0},{PRIVATE_TIME_TIP_W,PRIVATE_TIME_TIP_H}};
    }else{
        _privateChatType = NSNotFound;
    }
}

- (void)setContent:(NSString *)content{
    _content = content;

    if (_content != nil) {
        NSAttributedString* string =[Utils contentStringFromRawString:_content];
        CGSize size = [string.string boundingRectWithSize:(CGSize){PRIVATE_MAX_WIDTH,MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:CHAT_TEXT_FONT_SIZE]} context:nil].size;
        _textFrame = (CGRect){{0,0},size};
        _popFrame = (CGRect){{0,0},{size.width + PRIVATE_POP_PADDING_LEFT + PRIVATE_POP_PADDING_RIGHT,size.height + PRIVATE_POP_PADDING_TOP + PRIVATE_POP_PADDING_BOTTOM}};
        _timeTipFrame = (CGRect){{0,0},{PRIVATE_TIME_TIP_W,PRIVATE_TIME_TIP_H}};
    }
}

@end


@implementation OSCSender

- (void)setId:(NSInteger)id{
    _id = id;
    
    if([Config getOwnID] == _id){
        _bySelf = YES;
    }else{
        _bySelf = NO;
    }
}

@end


