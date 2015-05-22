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
        
        if ([reuseIdentifier isEqualToString:kteamIssueDetailCellNomal]) {
            [self initNomalStyleSubviews];
            [self setNomalStyleLayout];
        }else if ([reuseIdentifier isEqualToString:kTeamIssueDetailCellRemark]) {
            [self initRemarkStyleSubviews];
            [self setRemarkStyleLayout];
        }else if ([reuseIdentifier isEqualToString:kTeamIssueDetailCellSubChild]) {
            [self initSubIssueStyleSubviews];
            [self setSubIssueStyleLayout];
        }
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}
#pragma mark --普通cell
- (void)initNomalStyleSubviews
{
    _iconLabel = [UILabel new];
    _iconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    _iconLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_iconLabel];
    

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

}

- (void)setNomalStyleLayout
{
    for (UIView *view in self.contentView.subviews)
    {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    NSDictionary *views = NSDictionaryOfVariableBindings(_iconLabel, _titleLabel,_descriptionLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_iconLabel]|"
                                      options:0
                                      metrics:nil
                                      views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_iconLabel(30)]-4-[_titleLabel]-8-[_descriptionLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:views]];
//    CGFloat cellHeight =CGRectGetHeight(self.frame);
//    NSDictionary *heightDic = @{@"heightKey":[NSNumber numberWithFloat:cellHeight]};
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel(heightKey)]"
//                                                                             options:0
//                                                                             metrics:heightDic
//                                                                               views:views]];
}
#pragma mark --标签cell
- (void)initRemarkStyleSubviews
{
    _iconLabel = [UILabel new];
    _iconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    _iconLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_iconLabel];
    
    _remarkSv = [UIScrollView new];
    _remarkSv.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:_remarkSv];
}

- (void)setRemarkStyleLayout
{
    for (UIView *view in self.contentView.subviews)
    {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    NSDictionary *views = NSDictionaryOfVariableBindings(_iconLabel, _remarkSv);
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_iconLabel]|"
                                      options:0
                                      metrics:nil
                                      views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_iconLabel(30)]-4-[_remarkSv]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                             metrics:nil
                                                                               views:views]];
}

#pragma mark -- 设置标签cell
-(void)setupRemarkLabelsWithtexts:(NSArray*)texts
{
    CGFloat offsetX = 0;
    while (self.remarkSv.subviews.lastObject != nil) {
        [self.remarkSv.subviews.lastObject removeFromSuperview];
    }
    
    for (int j = 0; j<texts.count; j++) {
        NSDictionary *labelInfo = [texts objectAtIndex:j];
        NSString *labelText = [labelInfo valueForKey:@"name"];
        NSString *colorStr = [[labelInfo valueForKey:@"color"] stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
        unsigned colorInt = 0;
        [[NSScanner scannerWithString:colorStr] scanHexInt:&colorInt];
        UIFont *textFont = [UIFont systemFontOfSize:13];
        NSDictionary *attribute = @{NSFontAttributeName: textFont};
        CGSize size = [labelText boundingRectWithSize:CGSizeMake(999, 99) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        CGFloat labelWidth = ceilf(size.width);
        
        UILabel *issueLabel = [[UILabel alloc]initWithFrame:CGRectMake(offsetX, 0, labelWidth, CGRectGetHeight(self.frame)/2.5)];
        UIColor *textColor = [UIColor colorWithHex:colorInt];
        issueLabel.center = CGPointMake(issueLabel.center.x, self.contentView.center.y);
        [issueLabel setCornerRadius:5];
        [issueLabel setBorderWidth:.5 andColor:textColor];
        issueLabel.font = textFont;
        issueLabel.text = labelText;
        issueLabel.textColor=textColor;
        [self.remarkSv addSubview:issueLabel];
        offsetX = CGRectGetMaxX(issueLabel.frame)+10;
    }
    [self.remarkSv setContentSize:CGSizeMake(offsetX, self.remarkSv.frame.size.height)];
}

#pragma mark --子任务cell
- (void)initSubIssueStyleSubviews
{
    _iconLabel = [UILabel new];
    _iconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    _iconLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_iconLabel];
    
    _portraitIv = [UIImageView new];
    [_portraitIv setCornerRadius:10];
    [self.contentView addSubview:_portraitIv];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _descriptionLabel.font = [UIFont systemFontOfSize:13];
    _descriptionLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_descriptionLabel];
}
- (void)setSubIssueStyleLayout
{
    for (UIView *view in self.contentView.subviews)
    {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    NSDictionary *views = NSDictionaryOfVariableBindings(_iconLabel, _portraitIv,_descriptionLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_descriptionLabel]|"
                                      options:0
                                      metrics:nil
                                      views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[_iconLabel(20)]-4-[_portraitIv(20)]-8-[_descriptionLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portraitIv(20)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
}



@end
