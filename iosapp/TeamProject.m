//
//  TeamProject.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamProject.h"
#import <UIKit/UIKit.h>
#import "Utils.h"
@implementation TeamProject

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _projectID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _source = [[xml firstChildWithTag:@"source"] stringValue];
        _teamID = [[[xml firstChildWithTag:@"teamid"] numberValue] intValue];
        
        ONOXMLElement *gitXML = [xml firstChildWithTag:@"git"];
        _gitID = [[[gitXML firstChildWithTag:@"id"] numberValue] intValue];
        _projectName = [[gitXML firstChildWithTag:@"name"] stringValue];
        _projectPath = [[gitXML firstChildWithTag:@"path"] stringValue];
        _ownerName = [[gitXML firstChildWithTag:@"ownerName"] stringValue];
        _ownerUserName = [[gitXML firstChildWithTag:@"ownerUserName"] stringValue];
        
        ONOXMLElement *issueXML = [xml firstChildWithTag:@"issue"];
        _openedIssueCount = [[[issueXML firstChildWithTag:@"opened"] numberValue] intValue];
        _allIssueCount = [[[issueXML firstChildWithTag:@"all"] numberValue] intValue];
        
        _gitPush = [[xml firstChildWithTag:@"gitpush"].stringValue isEqualToString:@"true"];
    }
    
    return self;
}

- (NSAttributedString *)attributedTittle
{
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = [UIImage imageNamed:@"widget_repost"];

    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    NSMutableAttributedString *attributedTittle = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    [attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:_projectName]];
    
    return attributedTittle;
}

@end
