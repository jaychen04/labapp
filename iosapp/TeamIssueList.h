//
//  TeamIssueList.h
//  iosapp
//
//  Created by Holden on 15/4/28.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface TeamIssueList : OSCBaseObject
@property (nonatomic) int64_t listId;
@property (nonatomic,copy)NSString *listTitle;
@property (nonatomic,copy)NSString *listDescription;
@property (nonatomic) int64_t archive;
@property (nonatomic) int  openedIssueCount;
@property (nonatomic) int  closedIssueCount;
@property (nonatomic) int  allIssueCount;
@end
