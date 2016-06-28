//
//  SoftWareDetailHeaderView.m
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareDetailHeaderView.h"
#import "Utils.h"

#define PADDING_LEFT 16
#define PADDING_RIGHT PADDING_LEFT
#define PADDING_TOP 16
#define PADDING_BOTTOM PADDING_TOP
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SPACE_BUTTON 16
#define HEIGHT_BUTTON 50

@implementation SoftWareDetailHeaderView{
    __weak UIButton* _leftButton;
    __weak UIButton* _rightButton;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
        [self setLayoutSubViews];
    }
    return self;
}

#pragma mark --- setting subViews
-(void)setupSubViews{
    UIButton* leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.layer.borderWidth = 3;
    leftBtn.layer.borderColor = [UIColor colorWithHex:0xd6d6d6].CGColor;
    leftBtn.tag = 100;
    [leftBtn setTitle:@"软件官网" forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"ic_website"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn];
    _leftButton = leftBtn;
    
    
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.layer.borderWidth = 3;
    rightBtn.layer.borderColor = [UIColor colorWithHex:0xd6d6d6].CGColor;
    rightBtn.tag = 200;
    [rightBtn setTitle:@"软件文档" forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"ic_documents"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn];
    _rightButton = rightBtn;
}

-(void)setLayoutSubViews{
    _leftButton.frame = (CGRect){{PADDING_LEFT,PADDING_TOP},{(SCREEN_WIDTH - PADDING_LEFT - PADDING_RIGHT - SPACE_BUTTON)*0.5,HEIGHT_BUTTON}};
    CGFloat buttonWidth = CGRectGetWidth(_leftButton.frame);
    _rightButton.frame = (CGRect){{(PADDING_LEFT + buttonWidth + SPACE_BUTTON),PADDING_TOP},{buttonWidth,HEIGHT_BUTTON}};
}



#pragma mark --- click method 
-(void)buttonDidClick:(UIButton* )button{
    if (button.tag == 100) {//leftButton
        if ([_delegate respondsToSelector:@selector(softWareDetailHeaderViewClickLeft:)]) {
            [_delegate softWareDetailHeaderViewClickLeft:self];
        }
    }else{//rightButton
        if ([_delegate respondsToSelector:@selector(softWareDetailHeaderViewClickRight:)]) {
            [_delegate softWareDetailHeaderViewClickRight:self];
        }
    }
}

@end
