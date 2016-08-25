//
//  OSCPrivateChat.m
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChat.h"
#import "Config.h"

@implementation OSCPrivateChat

- (void)setType:(NSInteger)type{
    _type = type;
    
    if (type == 1) {
        _privateChatType = OSCPrivateChatTypeText;
    }else if (type == 3){
        _privateChatType = OSCPrivateChatTypeImage;
    }else if (type == 5){
        _privateChatType = OSCPrivateChatTypeFile;
    }else{
        _privateChatType = NSNotFound;
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


