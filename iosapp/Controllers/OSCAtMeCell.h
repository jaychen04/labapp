//
//  OSCAtMeCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AtMeItem;
@interface OSCAtMeCell : UITableViewCell
+ (instancetype)returnReuseAtMeCellWithTableView:(UITableView* )tableView
                                       indexPath:(NSIndexPath* )indexPath
                                      identifier:(NSString* )reuseIdentifier;

@property (nonatomic,strong) AtMeItem* atMeItem;

@end
