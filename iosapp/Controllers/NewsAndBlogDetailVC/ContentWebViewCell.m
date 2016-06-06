//
//  ContentWebViewCell.m
//  iosapp
//
//  Created by Holden on 16/6/6.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ContentWebViewCell.h"

@implementation ContentWebViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _contentWebView.scalesPageToFit = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
