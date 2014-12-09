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
        for (NSString *title in titles)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor colorWithHex:0xE1E1E1];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
        firstTitle.titleLabel.font = [UIFont systemFontOfSize:16];
        [firstTitle setTitleColor:[UIColor colorWithHex:0x008000] forState:UIControlStateNormal];
    }
    
    return self;
}


- (void)onClick:(UIButton *)button
{
    if (_currentIndex != button.tag)
    {
        UIButton *preTitle = _titleButtons[_currentIndex];
        [preTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        preTitle.titleLabel.font = [UIFont systemFontOfSize:15];
        _currentIndex = button.tag;
        
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        
        _titleButtonClicked(button.tag);
    }
}

- (void)focusTitleAtIndex:(NSUInteger)index ratio:(CGFloat)ratio
{
    UIButton *preTitle = _titleButtons[_currentIndex];
    [preTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    preTitle.titleLabel.font = [UIFont systemFontOfSize:15];
    _currentIndex = index;
    
    UIButton *currentTitle = _titleButtons[_currentIndex];
    [currentTitle setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    currentTitle.titleLabel.font = [UIFont systemFontOfSize:16];
}




@end
