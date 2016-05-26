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

//- (NSMutableAttributedString *)attributedTitleString
//{
//    if (_attributedTitleString == nil) {
//        
//        _attributedTitleString = [NSMutableAttributedString new];
//        if (_newHotBlog.recommend) {
//            NSTextAttachment *textAttachment = [NSTextAttachment new];
//            textAttachment.image = [UIImage imageNamed:@"ic_label_recommend"];
//            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
//            _attributedTitleString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
//            [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
//            [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:_newHotBlog.title]];
//        } else {
//            if (_newHotBlog.original) {
//                NSTextAttachment *textAttachment = [NSTextAttachment new];
//                textAttachment.image = [UIImage imageNamed:@"ic_label_originate"];
//                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
//                _attributedTitleString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
//                [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
//                [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:_newHotBlog.title]];
//            } else {
//                NSTextAttachment *textAttachment = [NSTextAttachment new];
//                textAttachment.image = [UIImage imageNamed:@"ic_label_reprint"];
//                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
//                _attributedTitleString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
//                [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
//                [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:_newHotBlog.title]];
//            }
//        }
//    }
//    return _attributedTitleString;
//}

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
