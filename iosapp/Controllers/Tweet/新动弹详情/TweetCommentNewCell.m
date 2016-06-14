//
//  TweetCommentNewCell.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetCommentNewCell.h"
#import "UIImageView+Util.h"
#import "utils.h"
@implementation TweetCommentNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_portraitIv.layer setCornerRadius:16];
    _commentTagIv.userInteractionEnabled = YES;
    _portraitIv.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setCommentModel:(OSCComment *)commentModel {
    [self.portraitIv loadPortrait:commentModel.portraitURL];
    [self.nameLabel setText:commentModel.author];
    self.interalTimeLabel.attributedText = [Utils newTweetAttributedTimeString:commentModel.pubDate];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:commentModel.content]];
    if (commentModel.replies.count > 0) {
        [contentString appendAttributedString:[OSCComment attributedTextFromReplies:commentModel.replies]];
    }
    [self.contentLabel setAttributedText:contentString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
