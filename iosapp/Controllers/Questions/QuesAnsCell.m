//
//  QuesAnsCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsCell.h"
#import "Utils.h"

@implementation QuesAnsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
 [cell.portrait loadPortrait:post.portraitURL];
 [cell.titleLabel setText:post.title];
 [cell.bodyLabel setText:post.body];
 [cell.authorLabel setText:post.author];
 [cell.timeLabel setText:[post.pubDate timeAgoSinceNow]];
 [cell.commentAndView setText:[NSString stringWithFormat:@"%d回 / %d阅", post.replyCount, post.viewCount]];
 
 cell.titleLabel.textColor = [UIColor titleColor];
 */
- (void)setcontentForQuestionsAns:(OSCPost *)post
{
    [_quesImageView loadPortrait:post.portraitURL];
    _titleLabel.text = post.title;
    _descLabel.text = post.body;
    
    _userNameLabel.text = [NSString stringWithFormat:@"%@ %@", post.author, [post.pubDate timeAgoSinceNow]];
    _watchCountLabel.text = [NSString stringWithFormat:@"%d", post.viewCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%d", post.replyCount];
}

@end
