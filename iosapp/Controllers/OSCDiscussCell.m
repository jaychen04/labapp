//
//  OSCDiscussCell.m
//  iosapp
//
//  Created by Graphic-one on 16/9/6.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCDiscussCell.h"
#import "OSCDiscuss.h"

@interface OSCDiscussCell ()

@end

@implementation OSCDiscussCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

+ (instancetype)returnReuseDiscussCellWithTableView:(UITableView *)tableView
                                          indexPath:(NSIndexPath *)indexPath
                                         identifier:(NSString *)reuseIdentifier
{
    OSCDiscussCell* discussCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    return discussCell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

#pragma mark --- setting model
- (void)setDiscuss:(OSCDiscuss *)discuss{
    _discuss = discuss;
    
    
}


@end
