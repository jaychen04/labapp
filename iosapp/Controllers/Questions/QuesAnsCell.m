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
- (void)setcontentForQuestionsAns:(OSCQuestion *)question
{
    [_quesImageView loadPortrait:[NSURL URLWithString:question.authorPortraitUrl]];
    _titleLabel.text = question.title;
    _descLabel.text = question.body;
    
    _userNameLabel.text = [NSString stringWithFormat:@"%@ %@", question.authorName, [question.pubDate timeAgoSinceNow]];
    _watchCountLabel.text = [NSString stringWithFormat:@"%d", question.viewCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%d", question.commentCount];
}

@end
