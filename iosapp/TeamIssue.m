
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

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

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


- (NSMutableAttributedString *)attributedProjectName
{
    if (!_attributedProjectName) {
        NSString *stateString;
        NSString *sourceString;
        
        if ([_state isEqualToString:@"opened"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FACircleO];
        } else if ([_state isEqualToString:@"underway"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FADotCircleO];
        } else if ([_state isEqualToString:@"closed"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FACheckCircleO];
        } else if ([_state isEqualToString:@"accepted"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FALock];
        } else if ([_state isEqualToString:@"outdate"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FATimesCircleO];
        } else {
            stateString = @"";
        }
        
        if ([_source isEqualToString:@"Git@OSC"]) {
            sourceString = [NSString fontAwesomeIconStringForEnum:FAgitSquare];
        } else if ([_source isEqualToString:@"Github"]) {
            sourceString = [NSString fontAwesomeIconStringForEnum:FAGithubSquare];
        } else {
            sourceString = [NSString fontAwesomeIconStringForEnum:FAInfoCircle];
        }
        
        
        _attributedProjectName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", stateString]
                                                                        attributes:@{
                                                                                     NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:16],
                                                                                     NSForegroundColorAttributeName: [UIColor grayColor]
                                                                                     }];
        [_attributedProjectName appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", sourceString]
                                                                                       attributes:@{
                                                                                                    NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:16],
                                                                                                    NSForegroundColorAttributeName: [UIColor grayColor]
                                                                                                    }]];
        [_attributedProjectName appendAttributedString:[[NSAttributedString alloc] initWithString:_title]];
    }
    
    return _attributedProjectName;
}





@end
