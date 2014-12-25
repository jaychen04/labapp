//
//  TweetEditingVC.m
//  iosapp
//
//  Created by ChanAetern on 12/18/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TweetEditingVC.h"
#import "EmojiPageVC.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface TweetEditingVC () <UIActionSheetDelegate>

@property (nonatomic, strong) UITextView         *edittingArea;
@property (nonatomic, strong) UIImageView        *imageView;
@property (nonatomic, strong) UIToolbar          *toolBar;
@property (nonatomic, assign) NSLayoutConstraint *keyboardHeight;
@property (nonatomic, strong) EmojiPageVC        *emojiPageVC;

@end

@implementation TweetEditingVC

- (void)loadView
{
    [super loadView];
    
    [self initSubViews];
    [self setLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"弹一弹";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonClicked)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:nil];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initSubViews
{
    _edittingArea = [UITextView new];
    _edittingArea.scrollEnabled = NO;
    _edittingArea.font = [UIFont systemFontOfSize:18];
    _edittingArea.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:_edittingArea];
    
    _imageView = [UIImageView new];
    //[self.view addSubview:_imageView];
    
    _toolBar = [UIToolbar new];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 25.0f;
    NSMutableArray *barButtonItems = [[NSMutableArray alloc] initWithObjects:fixedSpace, nil];
    NSArray *iconName = @[@"compose_toolbar_picture_normal", @"compose_toolbar_mention_normal", @"compose_toolbar_trend_normal", @"compose_toolbar_emoji_normal"];
    NSArray *action   = @[@"addImage", @"mentionSomenone", @"referSoftware", @"switchInputView"];
    for (int i = 0; i < 4; i++) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:iconName[i]]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:NSSelectorFromString(action[i])];
        button.tintColor = [UIColor grayColor];
        [barButtonItems addObject:button];
        if (i < 3) {[barButtonItems addObject:flexibleSpace];}
    }
    [barButtonItems addObject:fixedSpace];
    [_toolBar setItems:barButtonItems];
    
    [self.view addSubview:_toolBar];
}

- (void)setLayout
{
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_edittingArea, _imageView, _toolBar);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_edittingArea]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_edittingArea]-8-|" options:0 metrics:nil views:views]];
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_toolBar]|" options:0 metrics:nil views:views]];
    _keyboardHeight = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                      toItem:_toolBar  attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    
    [self.view addConstraint:_keyboardHeight];
}

- (void)cancelButtonClicked
{
    [_edittingArea resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keyboardHeight.constant = keyboardBounds.size.height;
    [self.view setNeedsUpdateConstraints];
    
    NSTimeInterval animationDuration;
    [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _keyboardHeight.constant = 0;
    [self.view setNeedsUpdateConstraints];
    
    NSTimeInterval animationDuration;
    [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}




#pragma mark - ToolBar 操作

#pragma mark - 插入字符串操作（@人和引用软件）

- (void)mentionSomenone
{
    [self insertEditingString:@"@请输入用户名 "];
}

- (void)referSoftware
{
    [self insertEditingString:@"#请输入软件名#"];
}

- (void)insertEditingString:(NSString *)string
{
    [_edittingArea becomeFirstResponder];
    
    NSUInteger cursorLocation = _edittingArea.selectedRange.location;
    [_edittingArea replaceRange:_edittingArea.selectedTextRange withText:string];
    
    UITextPosition *selectedStartPos = [_edittingArea positionFromPosition:_edittingArea.beginningOfDocument offset:cursorLocation + 1];
    UITextPosition *selectedEndPos   = [_edittingArea positionFromPosition:_edittingArea.beginningOfDocument offset:cursorLocation + string.length - 1];
    
    UITextRange *newRange = [_edittingArea textRangeFromPosition:selectedStartPos toPosition:selectedEndPos];
    
    [_edittingArea setSelectedTextRange:newRange];
}




#pragma mark - 表情面板与键盘切换

- (void)switchInputView
{
    // 还要考虑一下用外接键盘输入时，置空inputView后，字体小的情况
    
    if (_edittingArea.inputView == self.emojiPageVC.view) {
        [_toolBar.items[7] setImage:[UIImage imageNamed:@"compose_toolbar_emoji_normal"]];
        _edittingArea.inputView = nil;
        _edittingArea.font = [UIFont systemFontOfSize:18];
        [_edittingArea reloadInputViews];
    } else {
        _keyboardHeight.constant = 216;
        [self.view layoutIfNeeded];
        
        [_toolBar.items[7] setImage:[UIImage imageNamed:@"compose_toolbar_keyboard_normal"]];
        _edittingArea.inputView = _emojiPageVC.view;
        [_edittingArea reloadInputViews];
    }
}

- (EmojiPageVC *)emojiPageVC
{
    if (!_emojiPageVC) {
        _emojiPageVC = [[EmojiPageVC alloc] initWithTextView:_edittingArea];
        [self addChildViewController:_emojiPageVC];
        [self.view addSubview:_emojiPageVC.view];
        
        NSDictionary *views = @{@"emojiView": _emojiPageVC.view};
        _emojiPageVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emojiView(216)]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[emojiView]|" options:0 metrics:nil views:views]];
    }
    
    return _emojiPageVC;
}




#pragma mark - 添加图片

- (void)addImage
{
    [[[UIActionSheet alloc] initWithTitle:@"添加图片"
                                 delegate:self
                        cancelButtonTitle:@"取消"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"相册", @"相机", nil]
     
     showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == 0) {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Device has no camera"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            
            [alertView show];
        } else {
            UIImagePickerController *imagePickerController = [UIImagePickerController new];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.allowsEditing = YES;
            imagePickerController.showsCameraControls = YES;
            imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}




@end
