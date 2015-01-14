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

@property (nonatomic, strong) EmojiPageVC *emojiPageVC;

@end

@implementation BottomBarViewController

- (instancetype)initWithModeSwitchButton:(BOOL)hasAModeSwitchButton
{
    self = [super init];
    if (self) {
        _bottomBar = [[BottomBar alloc] initWithModeSwitchButton:hasAModeSwitchButton];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (void)setup
{
    [self addBottomBar];
    _emojiPageVC = [[EmojiPageVC alloc] initWithTextView:_bottomBar.editView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidUpdate:) name:UITextViewTextDidChangeNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewText:) name:UITextViewTextDidChangeNotification object:nil];
}


- (void)addBottomBar
{
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_bottomBar];
    
    _bottomBarYConstraint = [NSLayoutConstraint constraintWithItem:self.view    attribute:NSLayoutAttributeBottom   relatedBy:NSLayoutRelationEqual
                                                            toItem:_bottomBar   attribute:NSLayoutAttributeBottom   multiplier:1.0 constant:0];
    
    _bottomBarHeightConstraint = [NSLayoutConstraint constraintWithItem:_bottomBar attribute:NSLayoutAttributeHeight         relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[self minimumInputbarHeight]];
    
    [self.view addConstraint:_bottomBarYConstraint];
    [self.view addConstraint:_bottomBarHeightConstraint];
    
    
    [_bottomBar.inputViewButton addTarget:self action:@selector(switchInputView) forControlEvents:UIControlEventTouchUpInside];
}


- (void)switchInputView
{
    if (_bottomBar.editView.inputView == self.emojiPageVC.view) {
        [_bottomBar.editView becomeFirstResponder];
        
        [_bottomBar.inputViewButton setImage:[UIImage imageNamed:@"compose_toolbar_emoji_normal"] forState:UIControlStateNormal];
        _bottomBar.editView.inputView = nil;
        _bottomBar.editView.font = [UIFont systemFontOfSize:18];
        [_bottomBar.editView reloadInputViews];
    } else {
        [_bottomBar.editView becomeFirstResponder];
        
        [_bottomBar.inputViewButton setImage:[UIImage imageNamed:@"compose_toolbar_keyboard_normal"] forState:UIControlStateNormal];
        _bottomBar.editView.inputView = _emojiPageVC.view;
        [_bottomBar.editView reloadInputViews];
        
        [self setBottomBarHeight:216];
    }
}



#pragma mark - textView的基本设置

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





#pragma mark - 调整bar的高度

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self setBottomBarHeight:keyboardBounds.size.height];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    [self setBottomBarHeight:0];
}

- (void)setBottomBarHeight:(CGFloat)height
{
    _bottomBarYConstraint.constant = height;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}



#pragma mark - 编辑框相关

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


- (void)didchangeTextViewText:(NSNotification *)notification
{
    
}


- (void)textDidUpdate:(NSNotification *)notification
{
    CGFloat inputbarHeight = [self appropriateInputbarHeight];
    
    if (inputbarHeight != self.bottomBarHeightConstraint.constant) {
        self.bottomBarHeightConstraint.constant = inputbarHeight;
        
        [self.view layoutIfNeeded];
    }
}






@end
