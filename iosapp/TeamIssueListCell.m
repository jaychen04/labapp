//
//  TeamIssueListCell.m
//  iosapp
//
//  Created by Holden on 15/4/29.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueListCell.h"
#import "UIColor+Util.h"
@implementation TeamIssueListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
    }
    return self;
}

- (void)initSubviews
{
    self.titleLabel = [UILabel new];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:self.titleLabel];
    
    self.detailLabel = [UILabel new];
    self.detailLabel.textColor = [UIColor grayColor];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.detailLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:self.detailLabel];
    
    self.countLabel = [UILabel new];
    self.countLabel.numberOfLines = 0;
    self.countLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.countLabel.font = [UIFont systemFontOfSize:13];
    self.countLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.countLabel];
    
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_titleLabel,_detailLabel,_countLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_titleLabel]-3-[_detailLabel]-8-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDict]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[_titleLabel]-5-[_countLabel]-20-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
