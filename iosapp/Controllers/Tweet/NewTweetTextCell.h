//
//  newTweetTextCell.h
//  iosapp
//
//  Created by Graphic-one on 16/6/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OSCTweet;
@interface NewTweetTextCell : UITableViewCell

@property (strong, nonatomic) UIImageView *userPortrait;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UITextView *descTextView;

//@property (nonatomic, strong) UIImageView *tweetImageView;//不包含图片动弹
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *likeCountLabel;
@property (strong, nonatomic) UIButton *likeCountButton;

@property (nonatomic, strong) UIImageView *commentImage;
@property (strong, nonatomic) UILabel *commentCountLabel;

@property (strong, nonatomic) UIView *imageBackView;

@property (nonatomic, strong) OSCTweet *tweet;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);
@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);


- (void)copyText:(id)sender;
- (void)deleteObject:(id)sender;

+ (void)initContetTextView:(UITextView*)textView;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

@end
