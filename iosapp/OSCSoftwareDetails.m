//
//  OSCSoftwareDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCSoftwareDetails.h"

NSString * const kID = @"id";
NSString * const kTitle = @"title";
NSString * const kExtensionTitle = @"extensionTitle";
NSString * const kLicense = @"license";
NSString * const kBody = @"body";
NSString * const kOS = @"os";
NSString * const kLanguage = @"language";
NSString * const kRecordTime = @"recordtime";
NSString * const kURL = @"url";
NSString * const kHomepage = @"homepage";
NSString * const kDocument = @"document";
NSString * const kDownload = @"download";
NSString * const kLogo = @"logo";
NSString * const kFavorite = @"favorite";
NSString * const kTweetCount = @"tweetCount";

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
