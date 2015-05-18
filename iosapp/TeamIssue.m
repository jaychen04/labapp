
//
//  TeamIssue.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamIssue.h"
#import "TeamProject.h"
#import "TeamProjectAuthority.h"
#import "TeamMember.h"

@implementation TeamIssue

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _issueID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _state = [[xml firstChildWithTag:@"state"] stringValue];
        _stateLevel = [[[xml firstChildWithTag:@"stateLevel"] numberValue] intValue];
        _priority = [[xml firstChildWithTag:@"priority"] stringValue];
        _gitPush = [[[xml firstChildWithTag:@"gitpush"] numberValue] boolValue];
        _source = [[xml firstChildWithTag:@"source"] stringValue];
        _catalogID = [[[xml firstChildWithTag:@"catalogid"] numberValue] intValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _issueDescription = [[xml firstChildWithTag:@"description"] stringValue];
        _createTime = [[xml firstChildWithTag:@"createTime"] stringValue];
        _updateTime = [[xml firstChildWithTag:@"updateTime"] stringValue];
        _acceptTime = [[xml firstChildWithTag:@"acceptTime"] stringValue];
        _deadline = [[xml firstChildWithTag:@"deadlineTime"] stringValue];
        
        _replyCount = [[[xml firstChildWithTag:@"replyCount"] numberValue] intValue];
        _gitIssueURL = [NSURL URLWithString:[[xml firstChildWithTag:@"gitIssueUrl"] stringValue]];
        //_authority = [[TeamProjectAuthority alloc] initWithXML:[xml firstChildWithTag:@"authority"]];
        _project = [[TeamProject alloc] initWithXML:[xml firstChildWithTag:@"project"]];
        
        //ONOXMLElement *childIssuesXML = [xml firstChildWithTag:@"childIssues"];
        //_childIssuesCount = [[[childIssuesXML firstChildWithTag:@"totalCount"] numberValue] intValue];
        //_closedChildIssuesCount = [[[childIssuesXML firstChildWithTag:@"closedCount"] numberValue] intValue];
        
        _author = [[TeamMember alloc] initWithXML:[xml firstChildWithTag:@"author"]];
        _user = [[TeamMember alloc] initWithXML:[xml firstChildWithTag:@"toUser"]];
    }
    
    return self;
}

- (instancetype)initWithDetailIssueXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _authority = [[TeamProjectAuthority alloc] initWithXML:[xml firstChildWithTag:@"authority"]];
        NSArray *xmlArr = [[xml firstChildWithTag:@"childIssues"] childrenWithTag:@"issue"];
        _childIssues = [NSMutableArray new];
        
        for (ONOXMLElement *xmlObject in xmlArr) {
            id obj = [[TeamIssue alloc] initWithXML:xmlObject];
            [_childIssues addObject:obj];
        }
    }
    return [self initWithXML:xml];
}
@end
