//
//  OSCObjsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "Utils.h"
#import "OSCAPI.h"

@interface OSCObjsViewController : UITableViewController <UIScrollViewDelegate>

@property Class objClass;
@property Class cellClass;
@property (nonatomic, strong) NSMutableArray *objects;

@property (nonatomic, copy) NSString * (^generateURL)(NSUInteger page, BOOL refresh);
@property (nonatomic, copy) void (^tableWillReload)();

@end
