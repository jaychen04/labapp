//
//  NewTweetCell.h
//  iosapp
//
//  Created by 李萍 on 16/5/21.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCTweetItem;
@interface NewTweetCell : UITableViewCell

@property (strong, nonatomic) UIImageView *userPortrait;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UITextView *descTextView;
@property (nonatomic, strong) UIImageView *tweetImageView;

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *likeCountLabel;
@property (strong, nonatomic) UIButton *likeCountButton;

@property (nonatomic, strong) UIImageView *commentImage;
@property (strong, nonatomic) UILabel *commentCountLabel;

@property (strong, nonatomic) UIView *imageBackView;

@property (nonatomic, strong) OSCTweetItem *tweet;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);
@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);


- (void)copyText:(id)sender;
- (void)deleteObject:(id)sender;

+ (void)initContetTextView:(UITextView*)textView;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

@end

