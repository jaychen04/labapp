//
//  OSCSoftwareDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 11/3/14.
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
        _softwareID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        _extensionTitle = [[xml firstChildWithTag:kExtensionTitle] stringValue];
        _license = [[xml firstChildWithTag:kLicense] stringValue];
        _body = [[xml firstChildWithTag:kBody] stringValue];
        _os = [[xml firstChildWithTag:kOS] stringValue];
        _language = [[xml firstChildWithTag:kLanguage] stringValue];
        _recordTime = [[xml firstChildWithTag:kRecordTime] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
        _homepageURL = [[xml firstChildWithTag:kHomepage] stringValue];
        _documentURL = [[xml firstChildWithTag:kDocument] stringValue];
        _downloadURL = [[xml firstChildWithTag:kDownload] stringValue];
        _logoURL = [[xml firstChildWithTag:kLogo] stringValue];
        _favoriteCount = [[[xml firstChildWithTag:kFavorite] numberValue] intValue];
        _tweetCount = [[[xml firstChildWithTag:kTweetCount] numberValue] intValue];
    }
    
    return self;
}

@end
