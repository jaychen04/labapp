//
//  NewHotBlogTableViewCell.m
//  iosapp
//
//  Created by Holden on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewHotBlogTableViewCell.h"
#import "Utils.h"


@implementation NewHotBlogTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNewHotBlogContent:(OSCNewHotBlog *)blog
{
    _titleLabel.attributedText = blog.attributedTitleString;
    _descLabel.text = blog.body;
    _authorLabel.text = blog.author;
    _timeLabel.attributedText = [Utils attributedTimeString:[NSDate dateFromString:blog.pubDate]];
    _commentCountLabel.text = [NSString stringWithFormat:@"%d", blog.commentCount];
    _viewCountLabel.text = [NSString stringWithFormat:@"%d", blog.viewCount];
}

@end
