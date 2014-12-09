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
#import "EmojiPageVC.h"

@interface BottomBarViewController ()

@end

@implementation BottomBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBottomBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidUpdate:) name:UITextViewTextDidChangeNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewText:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)addBottomBar
{
    _bottomBar = [BottomBar new];
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_bottomBar];
    
    //_emojiPanel = [[EmojiPanelView alloc] initWithPanelHeight:150];
    //_emojiPanel.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.view addSubview:_emojiPanel];
    
    //_emojiPanelVC = [[EmojiPageVC alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    //[self addChildViewController:_emojiPanelVC];
    //[self.view addSubview:_emojiPanelVC.view];
    
#if 1
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_bottomBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bottomBar)]];
    _bottomBarYConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:_bottomBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    _bottomBarHeightConstraint = [NSLayoutConstraint constraintWithItem:_bottomBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[self minimumInputbarHeight]];
    
    [self.view addConstraint:_bottomBarYConstraint];
    [self.view addConstraint:_bottomBarHeightConstraint];
#endif
    
#if 0
    //CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    //NSDictionary *metrics = @{@"panelWidth": @(screenWidth * 5)};
    _emojiPanel = _emojiPanelVC.view;
    [self.view addSubview:_emojiPanel];
    NSDictionary *views = NSDictionaryOfVariableBindings(_emojiPanel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_emojiPanel]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_emojiPanel(150)]|" options:0 metrics:nil views:views]];
#endif
}





- (GrowingTextView *)textView
{
    return _bottomBar.editView;
}

- (CGFloat)minimumInputbarHeight
{
    return _bottomBar.intrinsicContentSize.height;
}

- (CGFloat)deltaInputbarHeight
{
    return _bottomBar.intrinsicContentSize.height - self.textView.font.lineHeight;
}

- (CGFloat)barHeightForLines:(NSUInteger)numberOfLines
{
    CGFloat height = [self deltaInputbarHeight];
    
    height += roundf(self.textView.font.lineHeight * numberOfLines);
    
    return height;
}


- (CGFloat)appropriateInputbarHeight
{
    CGFloat height = 0.0;
    CGFloat minimumHeight = [self minimumInputbarHeight];
    NSUInteger numberOfLines = self.textView.numberOfLines;
    
    if (numberOfLines == 1) {
        height = minimumHeight;
    } else if (numberOfLines < self.textView.maxNumberOfLines) {
        height = [self barHeightForLines:self.textView.numberOfLines];
    } else {
        height = [self barHeightForLines:self.textView.maxNumberOfLines];
    }
    
    if (height < minimumHeight) {
        height = minimumHeight;
    }
    
    return roundf(height);
}




- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _bottomBarYConstraint.constant = keyboardBounds.size.height;
    [self.view layoutIfNeeded];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    _bottomBarYConstraint.constant = 0;
    [self.view layoutIfNeeded];
}


- (void)didchangeTextViewText:(NSNotification *)notification
{
    
}


- (void)textDidUpdate:(NSNotification *)notification
{
    // Disables animation if not first responder
    //if (![self.textView isFirstResponder]) {
    //    animated = NO;
    //}
    
    CGFloat inputbarHeight = [self appropriateInputbarHeight];
    
    if (inputbarHeight != self.bottomBarHeightConstraint.constant) {
        self.bottomBarHeightConstraint.constant = inputbarHeight;
        //self.scrollViewHC.constant = [self appropriateScrollViewHeight];
        
#if 0
        if (animated) {
            
            //BOOL bounces = self.bounces && [self.textView isFirstResponder];
            
            [UIView animateWithDuration:0.5
                                  delay:0.0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:0.7
                                options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [self.view layoutIfNeeded];
                                 
                                 if (animations) {
                                     animations();
                                 }
                             }
                             completion:NULL];
            
            [self.view slk_animateLayoutIfNeededWithBounce:bounces
                                                   options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                                                animations:^{
                                                    if (self.isEditing) {
                                                        [self.textView slk_scrollToCaretPositonAnimated:NO];
                                                    }
                                                }];
        }
        else {
            [self.view layoutIfNeeded];
        }
#endif
        
        [self.view layoutIfNeeded];
    }
    
    // Only updates the input view if the number of line changed
    //[self reloadInputAccessoryViewIfNeeded];
    
    // Toggles auto-correction if requiered
    //[self enableTypingSuggestionIfNeeded];
}






@end
