//
//  QuesAnsDetailHeadCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsDetailHeadCell.h"
#import "Utils.h"

@implementation QuesAnsDetailHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _contentWebView.scrollView.bounces = NO;
//    _contentWebView.scrollView.scrollEnabled = NO;
//    _contentWebView.opaque = NO;
//    _contentWebView.backgroundColor = [UIColor themeColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setQuestioinDetail:(OSCQuestion *)questioinDetail
{
    _titleLabel.text = questioinDetail.title;
    _tagLabel.text = @"";
    
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", questioinDetail.author, [[NSDate dateFromString:questioinDetail.pubDate] timeAgoSinceNow]];
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)questioinDetail.viewCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)questioinDetail.commentCount];
}

@end
