//
//  NewMultipleTweetCell.h
//  iosapp
//
//  Created by Graphic-one on 16/7/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCTweetItem;

@interface NewMultipleTweetCell : UITableViewCell

+ (instancetype) returnReuseMultipeTweetCellWithTableView:(UITableView* )tableView
                                               identifier:(NSString* )reuseIdentifier
                                                indexPath:(NSIndexPath* )indexPath;

@property (nonatomic,weak) UIButton* likeCountButton;

@property (nonatomic,strong) OSCTweetItem* tweetItem;

@end