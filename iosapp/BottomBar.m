//
//  BottomBar.m
//  iosapp
//
//  Created by chenhaoxiang on 11/4/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "BottomBar.h"
#import "GrowingTextView.h"
#import "Utils.h"

@interface BottomBar () <UITextViewDelegate>

@end

@implementation BottomBar

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        [self setLayout];
    }
    
    return self;
}


- (void)setLayout
{
    _modeSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_modeSwitchButton setImage:[UIImage imageNamed:@"button_keyboard_normal"] forState:UIControlStateNormal];
    
    _inputViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inputViewButton setImage:[UIImage imageNamed:@"button_emoji_normal"] forState:UIControlStateNormal];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setImage:[UIImage imageNamed:@"button_comment_normal"] forState:UIControlStateNormal];
    
    _editView = [GrowingTextView new];
    [_editView setCornerRadius:5.0];
    [_editView setBorderWidth:1.0f andColor:[[UIColor colorWithHex:0xC8C8CD] CGColor]];
    _editView.backgroundColor = [UIColor colorWithHex:0xF5FAFA];
    
    [self addSubview:_editView];
    [self addSubview:_modeSwitchButton];
    [self addSubview:_inputViewButton];
    [self addSubview:commentButton];
    
    for (UIView *view in [self subviews]) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_modeSwitchButton, _inputViewButton, commentButton, _editView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_modeSwitchButton]-5-[_editView]-5-[_inputViewButton][commentButton]-5-|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_modeSwitchButton]-3-|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_inputViewButton]-3-|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[commentButton]-3-|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_editView]-5-|" options:0 metrics:nil views:viewsDict]];
}





#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
}




#pragma mark - 键盘和表情面板切换








@end
