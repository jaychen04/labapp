//
//  TweetCell.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kTweeWithoutImagetCellID = @"TweetWithoutImageCell";
static NSString * const kTweetWithImageCellID = @"TweetWithImageCell";

@class OSCTweet;

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentCount;
@property (nonatomic, strong) UILabel *appclientLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *thumbnail;

@property (nonatomic, strong) NSArray *thumbnailConstraints;
@property (nonatomic, strong) NSArray *noThumbnailConstraints;

- (void)setContentWithTweet:(OSCTweet *)tweet;
- (void)copyText:(id)sender;

@end
