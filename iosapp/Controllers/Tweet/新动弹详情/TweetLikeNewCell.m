//
//  TweetLikeNewCell.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetLikeNewCell.h"

@implementation TweetLikeNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_portraitIv.layer setCornerRadius:16];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
