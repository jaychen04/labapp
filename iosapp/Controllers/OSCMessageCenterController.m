//
//  OSCMessageCenterController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMessageCenterController.h"

#import "OSCAtMeController.h"
#import "OSCCommentsController.h"
#import "OSCMessageController.h"

@interface OSCMessageCenterController ()
@property (nonatomic,strong) NSArray* titles;
@property (nonatomic,strong) NSArray* controllers;
@end

@implementation OSCMessageCenterController

- (instancetype)init{
    self = [super initWithTitle:@"消息中心" andSubTitles:_titles andControllers:_controllers underTabbar:YES];
    if (self) {
        //do something...
    }
    return self;
}



#pragma mark --- lazy loading
- (NSArray *)titles {
    if(_titles == nil) {
        _titles = @[@"@我",@"评论",@"私信"];
    }
    return _titles;
}
- (NSArray *)controllers {
    if(_controllers == nil) {
        _controllers = @[
                         [[OSCAtMeController alloc]init],
                         [[OSCCommentsController alloc]init],
                         [[OSCMessageController alloc]init]
                         ];
    }
    return _controllers;
}

@end
