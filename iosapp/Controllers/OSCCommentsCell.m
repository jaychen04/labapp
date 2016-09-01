//
//  OSCCommentsCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCommentsCell.h"
#import "OSCMessageCenter.h"
#import "UIImageView+CornerRadius.h"
#import "ImageDownloadHandle.h"
#import "Utils.h"
#import "Config.h"
#import "UIColor+Util.h"

@interface OSCCommentsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userPortraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *originDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAndSourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end

@implementation OSCCommentsCell{
    BOOL _trackingTouch_userPortrait;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_userPortraitImageView zy_cornerRadiusRoundingRect];
}
+ (instancetype)returnReuseCommentsCellWithTableView:(UITableView *)tableView
                                           indexPath:(NSIndexPath *)indexPath
                                          identifier:(NSString *)reuseIdentifier
{
    OSCCommentsCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    return cell;
}

- (void)setCommentItem:(CommentItem *)commentItem{
    _commentItem = commentItem;
    
    UIImage* portraitImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:commentItem.author.portrait];
    if (!portraitImage) {
        [ImageDownloadHandle downloadImageWithUrlString:commentItem.author.portrait SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_userPortraitImageView setImage:image];
            });
        }];
    }else{
        [_userPortraitImageView setImage:portraitImage];
    }
    
    _nameLabel.text = commentItem.author.name;
    _descLabel.attributedText = [Utils contentStringFromRawString:commentItem.content];
    NSMutableAttributedString* descAtt = [[NSMutableAttributedString alloc]initWithString:[Config getOwnUserName]];
    [descAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"："]];
    [descAtt appendAttributedString:[Utils contentStringFromRawString:commentItem.origin.desc]];
    [descAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x24cf5f]} range:NSMakeRange(0, [Config getOwnUserName].length)];
    _originDescLabel.attributedText = descAtt;
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:commentItem.pubDate] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)commentItem.appClient]];
    _timeAndSourceLabel.attributedText = att;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)commentItem.commentCount];
}
#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_userPortrait = NO;
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:_userPortraitImageView];
    if (CGRectContainsPoint(_userPortraitImageView.bounds, p)) {
        _trackingTouch_userPortrait = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(commentsCellDidClickUserPortrait:)]) {
            [_delegate commentsCellDidClickUserPortrait:self];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch_userPortrait) {
        [super touchesCancelled:touches withEvent:event];
    }
}

@end
