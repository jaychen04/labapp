//
//  ProjectCell.m
//  iosapp
//
//  Created by Holden on 15/4/27.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "ProjectCell.h"
#import "UIColor+Util.h"
#import "TeamProject.h"
#import "NSString+FontAwesome.h"

@interface ProjectCell ()

@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation ProjectCell

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
    _iconLabel = [UILabel new];
    _iconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
    _iconLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_iconLabel];
    
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.contentView addSubview:_titleLabel];
    
    _countLabel = [UILabel new];
    _countLabel.font = [UIFont systemFontOfSize:13];
    _countLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_countLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_iconLabel, _titleLabel, _countLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_titleLabel]-15-|" options:0 metrics:nil views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_iconLabel]-8-[_titleLabel]-8-[_countLabel]-15-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
}


- (void)setContentWithTeamProject:(TeamProject *)project
{
    _titleLabel.text = [NSString stringWithFormat:@"%@ / %@", project.ownerName, project.projectName];
    _countLabel.text = [NSString stringWithFormat:@"%d/%d", project.openedIssueCount, project.allIssueCount];
    
    if ([project.source containsString:@"Git"]) {
        _iconLabel.text = [NSString fontAwesomeIconStringForEnum:FAgitSquare];
    } else {
        _iconLabel.text = @"";
    }
}





@end
