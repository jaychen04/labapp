//
//  OSCSoftwareDetails.h
//  iosapp
//
//  Created by ChanAetern on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCSoftwareDetails : OSCBaseObject

@property (nonatomic, assign) int64_t softwareID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *extensionTitle;
@property (nonatomic, copy) NSString *license;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *os;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *recordTime;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSURL *homepageURL;
@property (nonatomic, copy) NSURL *documentURL;
@property (nonatomic, copy) NSURL *downloadURL;
@property (nonatomic, copy) NSURL *logoURL;
@property (nonatomic, assign) int favoriteCount;
@property (nonatomic, assign) int tweetCount;

@end
