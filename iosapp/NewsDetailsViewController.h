//
//  NewsDetailsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCNews;

@interface NewsDetailsViewController : UIViewController

- (instancetype)initWithNews:(OSCNews *)news;

@end
