//
//  MemberDetailCell.m
//  iosapp
//
//  Created by Holden on 15/5/7.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "MemberDetailCell.h"
#import "Utils.h"
@implementation MemberDetailCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    
    return self;
}

- (void)initSubviews
{
    _portraitIv = [UIImageView new];
    _portraitIv.contentMode = UIViewContentModeScaleAspectFit;
//    [_portraitIv setCornerRadius:5.0];
    [_portraitIv setCornerRadius:30];
    [self.contentView addSubview:_portraitIv];
    
    _nameLabel = [UILabel new];
    _nameLabel.numberOfLines = 0;
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    _eMailLabel = [UILabel new];
    _eMailLabel.numberOfLines = 0;
    _eMailLabel.adjustsFontSizeToFitWidth = YES;
    _eMailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _eMailLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_eMailLabel];
    
    _phoneLabel = [UILabel new];
    _phoneLabel.numberOfLines = 0;
    _phoneLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _phoneLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_phoneLabel];
    
    _addressLabel = [UILabel new];
    _addressLabel.numberOfLines = 0;
    _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _addressLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_addressLabel];
    
    _phoneIconIv = [UIImageView new];
    _phoneIconIv.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_phoneIconIv];
    
    _phoneIconIv.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeACall)];
    [_phoneIconIv addGestureRecognizer:tap];
}
-(void)makeACall
{
    if ([_phoneLabel.text length]>=2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_phoneLabel.text]]];
    }
}
- (void)setLayout
{
    for (UIView *view in self.contentView.subviews)
    {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portraitIv, _nameLabel, _eMailLabel, _phoneLabel, _addressLabel,_phoneIconIv);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_portraitIv(60)]"
                                                                              options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[_portraitIv(60)]-20-[_nameLabel]"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_nameLabel]-7-[_eMailLabel]-7-[_phoneLabel]-7-[_addressLabel]-7-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_eMailLabel]-75-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_phoneIconIv(50)]-20-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_phoneIconIv(50)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:_phoneIconIv    attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}


- (void)setContentWithTeamMember:(TeamMember *)teamMember
{
    [_portraitIv loadPortrait:teamMember.portraitURL];
    _nameLabel.text = [teamMember.name length]>0?teamMember.name:@"未填写姓名";
    _eMailLabel.text = [teamMember.email length]>0?teamMember.email:@"未填写邮箱";
    _phoneLabel.text = [teamMember.telephone length]>0?teamMember.telephone:@"未填写电话";
    _addressLabel.text = [teamMember.location length]>0?teamMember.location:@"未填写地址";
    [_phoneIconIv loadPortrait:teamMember.portraitURL];
    
    if ([teamMember.telephone length]<=0) {
        _phoneIconIv.hidden = YES;
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
