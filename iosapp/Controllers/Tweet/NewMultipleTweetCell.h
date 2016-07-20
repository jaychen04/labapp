//
//  NewMultipleTweetCell.h
//  iosapp
//
//  Created by Graphic-one on 16/7/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewMultipleTweetCell;

@protocol NewMultipleTweetCellDelegate <NSObject>

- (void) userPortraitDidClick:(NewMultipleTweetCell* )multipleTweetCell
                  tapGestures:(UITapGestureRecognizer* )tap;

//- (void) descTextViewDidClick:(NewMultipleTweetCell* )multipleTweetCell
//                  tapGestures:(UITapGestureRecognizer* )tap;

@end

@class OSCTweetItem;

@interface NewMultipleTweetCell : UITableViewCell
/**
 __weak UIImageView* _userPortrait;
 __weak UILabel* _nameLabel;
 __weak UITextView* _descTextView;
 
 __weak UIView* _imagesView;
 __weak UIView* _colorLine;
 
 __weak UILabel* _timeLabel;
 __weak UILabel* _likeCountLabel;
 __weak UIImageView* _commentImage;
 __weak UILabel* _commentCountLabel;
 */

+ (instancetype) returnReuseMultipeTweetCellWithTableView:(UITableView* )tableView
                                               identifier:(NSString* )reuseIdentifier
                                                indexPath:(NSIndexPath* )indexPath;
@property (nonatomic,weak) UITextView* descTextView;

@property (nonatomic,weak) UIButton* likeCountButton;

@property (nonatomic,strong) OSCTweetItem* tweetItem;

@property (nonatomic,weak) id<NewMultipleTweetCellDelegate> delegate;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);

@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);

@property (nonatomic,copy) void (^afterTheAssignment)(UITableViewCell* cell);

+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

@end
