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
    
    self.contentView.backgroundColor = [UIColor newCellColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setBlog:(OSCNewHotBlog *)blog
{
    _titleLabel.attributedText = blog.attributedTitleString;
    _descLabel.text = blog.body;
    _authorLabel.text = blog.author;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils attributedTimeString:[NSDate dateFromString:blog.pubDate]]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor newAssistTextColor] range:NSMakeRange(0, attributedString.length)];
    _timeLabel.attributedText = attributedString;
    
    _commentCountLabel.text = [NSString stringWithFormat:@"%d", blog.commentCount];
    _viewCountLabel.text = [NSString stringWithFormat:@"%d", blog.viewCount];
}

@end
