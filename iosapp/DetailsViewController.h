//
//  DetailsViewController.h
//  iosapp
//
//  Created by ChanAetern on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DetailsType)
{
    DetailsTypeNews,
    DetailsTypeBlog,
    DetailsTypeSoftware,
};

@interface DetailsViewController : UIViewController

- (instancetype)initWithDetailsType:(DetailsType)type andID:(int64_t)detailsID;

@end
