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
        self.currentIndex = 0;
        self.titleButtons = [NSMutableArray new];
        
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
            [self.titleButtons addObject:button];
        }
        
        self.contentSize = CGSizeMake(buttonWidth * i, 25);
        self.showsHorizontalScrollIndicator = NO;
        UIButton *firstTitle = self.titleButtons[0];
        firstTitle.titleLabel.font = [UIFont systemFontOfSize:16];
        [firstTitle setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
    return self;
}


- (void)onClick:(UIButton *)button
{
    if (self.currentIndex != button.tag)
    {
        UIButton *preTitle = [self.titleButtons objectAtIndex:self.currentIndex];
        [preTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        preTitle.titleLabel.font = [UIFont systemFontOfSize:15];
        self.currentIndex = button.tag;
        
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        
        self.titleButtonClicked(button.tag);
    }
}

- (void)focusTitleAtIndex:(NSUInteger)index ratio:(CGFloat)ratio
{
    UIButton *preTitle = [self.titleButtons objectAtIndex:self.currentIndex];
    [preTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    preTitle.titleLabel.font = [UIFont systemFontOfSize:15];
    self.currentIndex = index;
    
    UIButton *currentTitle = [self.titleButtons objectAtIndex:self.currentIndex];
    [currentTitle setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    currentTitle.titleLabel.font = [UIFont systemFontOfSize:16];
}




@end
