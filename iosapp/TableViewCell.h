//
//  TableViewCell.h
//  iosapp
//
//  Created by AeternChan on 5/26/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DataSourceType)
{
    DataSourceTypeProject,
    DataSourceTypeIssueGroup,
    DataSourceTypeMember,
};

@interface TableViewCell : UITableViewCell

- (void)setContentWithDataSource:(NSArray *)dataSource ofType:(DataSourceType)type;


@end
