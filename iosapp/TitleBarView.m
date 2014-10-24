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

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *titleButtons;

@end

@implementation TitleBarView

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.currentIndex = 0;
        self.titleButtons = [NSMutableArray new];
        
        //CGFloat barWidth = 0;
        CGFloat buttonWidth = frame.size.width / titles.count;
        CGFloat buttonHeight = frame.size.height - 2;
        
        NSUInteger i = 0;
        for (NSString *title in titles)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor colorWithHex:0xE1E1E1];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateNormal];
            
            
            //CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, buttonHeight) lineBreakMode:NSLineBreakByWordWrapping];
            //button.frame = CGRectMake(barWidth, 0, size.width, buttonHeight);
            button.frame = CGRectMake(buttonWidth * i, 0, buttonWidth, buttonHeight);
            button.tag = i++;
            [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
            [self.titleButtons addObject:button];
            //barWidth += size.width + 20;
        }
        
        self.contentSize = CGSizeMake(buttonWidth * i, 25);
        self.showsHorizontalScrollIndicator = NO;
        
        
        //CGRect rc  = [self viewWithTag:selectedIndex+kButtonTagStart].frame;
        //lineView = [[UIView alloc]initWithFrame:CGRectMake(rc.origin.x, self.frame.size.height - 2, rc.size.width, 2)];
        //lineView.backgroundColor = RGBCOLOR(190, 2, 1);
        //[self addSubview:lineView];
    }
    
    return self;
}


- (void)onClick:(UIButton *)button
{
    if (self.currentIndex != button.tag)
    {
        UIButton *preTitle = [self.titleButtons objectAtIndex:self.currentIndex];
        [preTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.currentIndex = button.tag;
        
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        self.titleButtonClicked(button.tag);
    }
}

- (void)focusTitleAtIndex:(NSUInteger)index
{
    UIButton *preTitle = [self.titleButtons objectAtIndex:self.currentIndex];
    [preTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.currentIndex = index;
    
    UIButton *currentTitle = [self.titleButtons objectAtIndex:self.currentIndex];
    [currentTitle setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}




@end
