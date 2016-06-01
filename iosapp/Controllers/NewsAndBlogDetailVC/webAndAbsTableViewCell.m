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
    _abstractLabel.hidden = NO;
    _bodyWebView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:@"abstractType"]) {
        _abstractLabel.hidden = NO;
        _bodyWebView.hidden = YES;
    } else if ([identifier isEqualToString:@"bodyType"]) {
        _abstractLabel.hidden = YES;
        _bodyWebView.hidden = NO;
    }
}

- (void)setBlogDetail:(OSCBlogDetail *)blogDetail
{
    [self dequeueReusableCellWithIdentifier:_cellType];
    
    _abstractLabel.text = blogDetail.abstract;
    [_bodyWebView loadHTMLString:blogDetail.body baseURL:[NSBundle mainBundle].resourceURL];
}

@end
