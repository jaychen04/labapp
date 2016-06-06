//
//  webAndAbsTableViewCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "webAndAbsTableViewCell.h"

@implementation webAndAbsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _abstractLabel.hidden = NO;
//    _bodyWebView.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBlogDetail:(OSCBlogDetail *)blogDetail
{
    self.abstractLabel.hidden = NO;
    self.bodyWebView.hidden = YES;
    _abstractLabel.text = blogDetail.abstract;
}

@end
