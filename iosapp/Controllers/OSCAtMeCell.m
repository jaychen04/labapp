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
#import "UIImageView+CornerRadius.h"

@interface OSCAtMeCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userPortraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *originDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAndSourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end

@implementation OSCAtMeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_userPortraitImageView zy_cornerRadiusRoundingRect];
}

+ (instancetype)returnReuseAtMeCellWithTableView:(UITableView *)tableView
                                      identifier:(NSString *)reuseIdentifier
{
    OSCAtMeCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[OSCAtMeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
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
    _descLabel.attributedText = [Utils contentStringFromRawString:atMeItem.content];
    _originDescLabel.attributedText = [Utils contentStringFromRawString:atMeItem.origin.desc];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:atMeItem.pubDate] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)atMeItem.appClient]];
    _timeAndSourceLabel.attributedText = att;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)atMeItem.commentCount];
}

@end
