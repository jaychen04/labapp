//
//  TeamCell.m
//  iosapp
//
//  Created by AeternChan on 4/28/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamCell.h"

@implementation TeamCell

- (void)setFrame:(CGRect)frame
{
    frame.origin.x += 8;
    frame.size.width -= 2 * 8;
    [super setFrame:frame];
}

@end
