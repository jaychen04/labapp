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
