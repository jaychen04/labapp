//
//  MessageBubbleCell.h
//  iosapp
//
//  Created by ChanAetern on 2/12/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kMessageBubbleOthers = @"MessageBubbleOthers";
static NSString * const kMessageBubbleMe     = @"MessageBubbleMe";

@interface MessageBubbleCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;

- (void)setContent:(NSString *)content andPortrait:(NSURL *)portraitURL;

@end
