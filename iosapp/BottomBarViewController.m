//
//  BottomBarViewController.m
//  iosapp
//
//  Created by ChanAetern on 11/19/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "BottomBarViewController.h"
#import "BottomBar.h"
#import "GrowingTextView.h"

@interface BottomBarViewController ()

@end

@implementation BottomBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBottomBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewText:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _bottomConstraint.constant = keyboardBounds.size.height;
    [self.view layoutIfNeeded];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    _bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}



- (void)addBottomBar
{
    _bottomBar = [BottomBar new];
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_bottomBar];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_bottomBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bottomBar)]];
    _bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:_bottomBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraint:_bottomConstraint];
}






- (GrowingTextView *)textView
{
    return self.bottomBar.textView;
}

- (CGFloat)minimumInputbarHeight
{
    return self.bottomBar.intrinsicContentSize.height;
}

- (CGFloat)deltaInputbarHeight
{
    return self.textView.intrinsicContentSize.height - self.textView.font.lineHeight;
}

- (CGFloat)barHeightForLines:(NSUInteger)numberOfLines
{
    CGFloat height = [self deltaInputbarHeight];
    
    height += roundf(self.textView.font.lineHeight * numberOfLines);
    height += 10;
    
    return height;
}


- (CGFloat)appropriateInputbarHeight
{
    CGFloat height = 0.0;
    CGFloat minimumHeight = [self minimumInputbarHeight];
    
    if (self.textView.numberOfLines == 1) {
        height = minimumHeight;
    } else if (self.textView.numberOfLines < self.textView.maxNumberOfLines) {
        height = [self barHeightForLines:self.textView.numberOfLines];
    } else {
        height = [self barHeightForLines:self.textView.maxNumberOfLines];
    }
    
    if (height < minimumHeight) {
        height = minimumHeight;
    }
    
    return roundf(height);
}









@end
