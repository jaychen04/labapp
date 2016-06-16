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

#pragma mark - 处理长按操作

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return _canPerformAction(self, action);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copyText:(id)sender {
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_contentLabel.text];
}

- (void)deleteObject:(id)sender {
    _deleteObject(self);
}


@end
