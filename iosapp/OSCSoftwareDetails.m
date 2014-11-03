//
//  OSCSoftwareDetails.m
//  iosapp
//
//  Created by ChanAetern on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCSoftwareDetails.h"

static NSString *kID = @"id";
static NSString *kTitle = @"title";
static NSString *kExtensionTitle = @"extensionTitle";
static NSString *kLicense = @"license";
static NSString *kBody = @"body";
static NSString *kOS = @"os";
static NSString *kLanguage = @"language";
static NSString *kRecordTime = @"recordtime";
static NSString *kURL = @"url";
static NSString *kHomepage = @"homepage";
static NSString *kDocument = @"document";
static NSString *kDownload = @"download";
static NSString *kLogo = @"logo";
static NSString *kFavorite = @"favorite";
static NSString *kTweetCount = @"tweetCount";

@implementation OSCSoftwareDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        self.softwareID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        self.title = [[xml firstChildWithTag:kTitle] stringValue];
        self.extensionTitle = [[xml firstChildWithTag:kExtensionTitle] stringValue];
        self.license = [[xml firstChildWithTag:kLicense] stringValue];
        self.body = [[xml firstChildWithTag:kBody] stringValue];
        self.os = [[xml firstChildWithTag:kOS] stringValue];
        self.language = [[xml firstChildWithTag:kLanguage] stringValue];
        self.recordTime = [[xml firstChildWithTag:kRecordTime] stringValue];
        self.url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
        self.homepageURL = [NSURL URLWithString:[[xml firstChildWithTag:kHomepage] stringValue]];
        self.documentURL = [NSURL URLWithString:[[xml firstChildWithTag:kDocument] stringValue]];
        self.downloadURL = [NSURL URLWithString:[[xml firstChildWithTag:kDownload] stringValue]];
        self.logoURL = [NSURL URLWithString:[[xml firstChildWithTag:kLogo] stringValue]];
        self.favoriteCount = [[[xml firstChildWithTag:kFavorite] numberValue] intValue];
        self.tweetCount = [[[xml firstChildWithTag:kTweetCount] numberValue] intValue];
    }
    
    return self;
}

@end
