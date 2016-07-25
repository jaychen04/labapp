//
//  NewMultipleTweetCell.h
//  iosapp
//
//  Created by Graphic-one on 16/7/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewMultipleTweetCell,OSCPhotoGroupView;

@protocol NewMultipleTweetCellDelegate <NSObject>

- (void) userPortraitDidClick:(NewMultipleTweetCell* )multipleTweetCell
                  tapGestures:(UITapGestureRecognizer* )tap;

//- (void) descTextViewDidClick:(NewMultipleTweetCell* )multipleTweetCell
//                  tapGestures:(UITapGestureRecognizer* )tap;

- (void) assemblyMultipleTweetCellDidFinsh:(NewMultipleTweetCell* )multipleTweetCell;

- (void) loadLargeImageDidFinsh:(NewMultipleTweetCell* )multipleTweetCell
                 photoGroupView:(OSCPhotoGroupView* )groupView
                       fromView:(UIImageView* )fromView;

@end

@class OSCTweetItem;

@interface NewMultipleTweetCell : UITableViewCell

+ (instancetype) returnReuseMultipeTweetCellWithTableView:(UITableView* )tableView
                                               identifier:(NSString* )reuseIdentifier
                                                indexPath:(NSIndexPath* )indexPath;

@property (nonatomic,weak) UITextView* descTextView;

@property (nonatomic,weak) UIButton* likeCountButton;

@property (nonatomic,strong) OSCTweetItem* tweetItem;

@property (nonatomic,weak) id<NewMultipleTweetCellDelegate> delegate;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);

@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);

//@property (nonatomic,copy) void (^afterTheAssignment)(UITableViewCell* cell);

//+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

@end
