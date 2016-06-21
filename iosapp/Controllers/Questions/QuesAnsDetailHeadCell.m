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
    
    [(UIScrollView *)[[_contentWebView subviews] objectAtIndex:0] setBounces:NO];
    [(UIScrollView *)[[_contentWebView subviews] objectAtIndex:0] setScrollEnabled:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setQuestioinDetail:(OSCQuestion *)questioinDetail
{
    _titleLabel.text = questioinDetail.title;
    _tagLabel.text = @"标签、标签、标签、标签";
    
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", questioinDetail.author, [[NSDate dateFromString:questioinDetail.pubDate] timeAgoSinceNow]];
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)questioinDetail.viewCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)questioinDetail.commentCount];
}

@end
