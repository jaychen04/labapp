//
//  CommentCell.h
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCComment;

@interface CommentCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *repliesView;

- (void)setContentWithComment:(OSCComment *)comment;
- (void)copyText:(id)sender;

@end
