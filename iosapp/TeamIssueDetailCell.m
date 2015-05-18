//
//  TeamIssueDetailCell.m
//  iosapp
//
//  Created by Holden on 15/5/4.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueDetailCell.h"
#import "Utils.h"
#import "NSString+FontAwesome.h"


@implementation TeamIssueDetailCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviewsWithReuseIdentifier:reuseIdentifier];
        [self setLayoutWithReuseIdentifier:reuseIdentifier];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)initSubviewsWithReuseIdentifier:(NSString*)reuseIdentifier
{
    _iconLabel = [UILabel new];
    _iconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    _iconLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_iconLabel];
    
    if ([reuseIdentifier isEqualToString:kteamIssueDetailCellNomal]) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_titleLabel];
        
        _descriptionLabel = [UILabel new];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descriptionLabel.font = [UIFont systemFontOfSize:13];
        _descriptionLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_descriptionLabel];
    } else if ([reuseIdentifier isEqualToString:kTeamIssueDetailCellRemark]) {
        _remarkSv = [UIScrollView new];
        [self.contentView addSubview:_remarkSv];
    }
}

- (void)setLayoutWithReuseIdentifier:(NSString*)reuseIdentifier
{
    for (UIView *view in self.contentView.subviews)
    {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_iconLabel, _titleLabel,_descriptionLabel,_remarkSv);
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_iconLabel]|"
                                      options:0
                                      metrics:nil
                                      views:views]];
    if ([reuseIdentifier isEqualToString:kteamIssueDetailCellNomal]) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_iconLabel(30)]-4-[_titleLabel]-8-[_descriptionLabel]-8-|"
                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                 metrics:nil
                                                                                   views:views]];
    }else if ([reuseIdentifier isEqualToString:kTeamIssueDetailCellRemark]) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_iconLabel(30)]-4-[_remarkSv]-8-|"
                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                 metrics:nil
                                                                                   views:views]];
    }
}


//- (void)setContentWithIssue:(TeamIssue *)issue
//{
//    _titleLabel.text = issue.title;
//    
//    _projectNameLabel.text = issue.project.projectName;
//    _commentLabel.attributedText = [Utils attributedCommentCount:issue.replyCount];
//    _timeLabel.attributedText = [Utils attributedTimeString:issue.createTime];
//    
//    if (issue.user.name) {
//        _assignmentLabel.text = [NSString stringWithFormat:@"%@ 指派给 %@", issue.author.name, issue.user.name];
//    } else {
//        _assignmentLabel.text = [NSString stringWithFormat:@"%@ 未指派", issue.author.name];
//    }
//}


@end
