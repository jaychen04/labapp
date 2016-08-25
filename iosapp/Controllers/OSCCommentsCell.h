//
//  OSCCommentsCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentItem;
@interface OSCCommentsCell : UITableViewCell
+ (instancetype)returnReuseCommentsCellWithTableView:(UITableView* )tableView
                                           indexPath:(NSIndexPath* )indexPath
                                          identifier:(NSString* )reuseIdentifier;

@property (nonatomic,strong) CommentItem* commentItem;

@end
