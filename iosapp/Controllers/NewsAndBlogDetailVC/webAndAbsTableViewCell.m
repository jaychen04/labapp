//
//  webAndAbsTableViewCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "webAndAbsTableViewCell.h"
#define Line_Spacing 0
#define Line_Height 22


@implementation webAndAbsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setAbstractText:(NSString* )abstract{
    NSMutableAttributedString* attributedStr = [[NSMutableAttributedString alloc]initWithData:[abstract dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSFontAttributeName: @"STSongti-SC"}documentAttributes:nil error:nil];
    
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:Line_Spacing];
    [paragraphStyle1 setLineHeightMultiple:Line_Height];

    
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, attributedStr.length)];
    
    _abstractLabel.attributedText = attributedStr;
    _abstractLabel.textAlignment = NSTextAlignmentLeft;
    _abstractLabel.font = [UIFont fontWithName:@"STSongti-SC" size:14];
}

@end
