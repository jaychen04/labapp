//
//  TitleBarView.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-20.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TitleBarView.h"
#import "UIColor+Util.h"

@interface TitleBarView ()

@end

@implementation TitleBarView

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _currentIndex = 0;
        _titleButtons = [NSMutableArray new];
        
        CGFloat buttonWidth = frame.size.width / titles.count;
        CGFloat buttonHeight = frame.size.height;
        
        NSUInteger i = 0;
        for (NSString *title in titles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor colorWithHex:0xE1E1E1];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor colorWithHex:0x808080] forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateNormal];
            
            button.frame = CGRectMake(buttonWidth * i, 0, buttonWidth, buttonHeight);
            button.tag = i++;
            [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
            [_titleButtons addObject:button];
        }
        
        self.contentSize = CGSizeMake(buttonWidth * i, 25);
        self.showsHorizontalScrollIndicator = NO;
        UIButton *firstTitle = _titleButtons[0];
        [firstTitle setTitleColor:[UIColor colorWithHex:0x008000] forState:UIControlStateNormal];
    }
    
    return self;
}


- (void)onClick:(UIButton *)button
{
    if (_currentIndex != button.tag) {
//        NSLog(@"点击的按钮的tag值=====%ld => %p", button.tag, button);
//        NSLog(@"上一次按钮的tag值_currentIndex===>%ld ", _currentIndex);
        
        //获取点击的原来的那个按钮
        UIButton *preTitle = _titleButtons[_currentIndex];
        
        //设置原来按钮的颜色为统一色
        [preTitle setTitleColor:[UIColor colorWithHex:0x808080] forState:UIControlStateNormal];
        
        //设置被点击的按钮为显眼颜色
        [button setTitleColor:[UIColor colorWithHex:0x008000] forState:UIControlStateNormal];
        //记录上一次被点击按钮的tag值
        _currentIndex = button.tag;
        
        _titleButtonClicked(button.tag);
    }
    
}



@end
