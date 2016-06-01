//
//  webAndAbsTableViewCell.h
//  iosapp
//
//  Created by 李萍 on 16/6/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"

@interface webAndAbsTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *cellType;/* cell类型 */

@property (nonatomic, weak) IBOutlet UILabel *abstractLabel;
@property (nonatomic, weak) IBOutlet UIWebView *bodyWebView;

@property (nonatomic, strong) OSCBlogDetail *blogDetail;

@end
