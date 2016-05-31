//
//  NewsBlogDetailTableViewController.h
//  iosapp
//
//  Created by Holden on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCNewHotBlog.h"

@interface NewsBlogDetailTableViewController : UITableViewController
@property (nonatomic)BOOL isBlogDetail;
@property (nonatomic)int64_t blogId;
@end
