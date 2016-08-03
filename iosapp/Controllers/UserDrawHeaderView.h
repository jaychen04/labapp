//
//  UserDrawHeaderView.h
//  iosapp
//
//  Created by Graphic-one on 16/8/3.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCUser;
@interface UserDrawHeaderView : UIView

@property (nonatomic, strong) UIView* imageBackView;
@property (nonatomic, strong) UIImageView* portrait;
@property (nonatomic, strong) UIImageView* genderImageView;

@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* signatureLabel;
@property (nonatomic, strong) UILabel* integralLabel;

@property (nonatomic, strong) UIButton* followsBtn;
@property (nonatomic, strong) UIButton* fansBtn;

@property (nonatomic, strong) UIButton* creditsButton;
@property (nonatomic, strong) UIButton* followsButton;
@property (nonatomic, strong) UIButton* fansButton;

- (void)setContentWithUser:(OSCUser *)user;

@end
