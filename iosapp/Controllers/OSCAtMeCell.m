//
//  OSCAtMeCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCAtMeCell.h"
#import "OSCMessageCenter.h"
#import "ImageDownloadHandle.h"
#import "Utils.h"
#import "Config.h"
#import "UIImageView+CornerRadius.h"

@interface OSCAtMeCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userPortraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *originDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAndSourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@end

@implementation OSCAtMeCell{
    BOOL _trackingTouch_userPortrait;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_userPortraitImageView zy_cornerRadiusRoundingRect];
}

+ (instancetype)returnReuseAtMeCellWithTableView:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                      identifier:(NSString *)reuseIdentifier
{
    OSCAtMeCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    return cell;
}

- (void)setAtMeItem:(AtMeItem *)atMeItem{
    _atMeItem = atMeItem;
    
    UIImage* portraitImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:atMeItem.author.portrait];
    if (!portraitImage) {
        [ImageDownloadHandle downloadImageWithUrlString:atMeItem.author.portrait SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_userPortraitImageView setImage:portraitImage];
            });
        }];
    }else{
        [_userPortraitImageView setImage:portraitImage];
    }
    
    _nameLabel.text = atMeItem.author.name;
    NSString* atUserName = [NSString stringWithFormat:@"@%@",[Config getOwnUserName]];
    NSRange range = [atMeItem.content localizedStandardRangeOfString:atUserName];
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc]initWithString:atMeItem.content];
    [attString addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHex:0x24cf5f]} range:range];
    _descLabel.attributedText = attString;
    if (atMeItem.origin.desc.length > 0) {
        _originDescLabel.attributedText = [Utils contentStringFromRawString:atMeItem.origin.desc];
    }else{
        _originDescLabel.text = @"相关动态";
    }
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:atMeItem.pubDate] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)atMeItem.appClient]];
    _timeAndSourceLabel.attributedText = att;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)atMeItem.commentCount];
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
        if ([_delegate respondsToSelector:@selector(atMeCellDidClickUserPortrait:)]) {
            [_delegate atMeCellDidClickUserPortrait:self];
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
