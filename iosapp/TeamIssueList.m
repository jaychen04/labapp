//
//  TeamIssueList.m
//  iosapp
//
//  Created by Holden on 15/4/28.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueList.h"

@implementation TeamIssueList

//<catalog>
//<id>1011</id>
//<title>
//<![CDATA[ 消息队列 ]]>
//</title>
//<archive>0</archive>
//<openedIssueCount>0</openedIssueCount>
//<closedIssueCount>0</closedIssueCount>
//<allIssueCount>0</allIssueCount>
//</catalog>

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _teamIssueId = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _listTitle = [[xml firstChildWithTag:@"title"] stringValue];
        _listDescription = [[xml firstChildWithTag:@"description"] stringValue];
        _openedIssueCount = [[[xml firstChildWithTag:@"openedIssueCount"] numberValue] intValue];
        _closedIssueCount = [[[xml firstChildWithTag:@"closedIssueCount"] numberValue] intValue];
        _allIssueCount = [[[xml firstChildWithTag:@"allIssueCount"] numberValue] intValue];

    }
    
    return self;
}

@end
