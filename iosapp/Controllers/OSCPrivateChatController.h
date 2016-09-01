//
//  OSCPrivateChatController.h
//  iosapp
//
//  Created by Graphic-one on 16/8/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCPrivateChatController : UIViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithAuthorId:(NSInteger)authorId;

@end
