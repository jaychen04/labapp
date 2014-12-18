//
//  TweetEditingVC.m
//  iosapp
//
//  Created by ChanAetern on 12/18/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TweetEditingVC.h"

@interface TweetEditingVC ()

@property (nonatomic, strong) UITextView  *edittingArea;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIToolbar   *toolBar;

@end

@implementation TweetEditingVC

- (void)loadView
{
    [super loadView];
    
    [self initSubViews];
    [self setLayout];
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

- (void)initSubViews
{
    _edittingArea = [UITextView new];
    _edittingArea.scrollEnabled = NO;
    _edittingArea.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_edittingArea];
    
    _imageView = [UIImageView new];
    //[self.view addSubview:_imageView];
    
    _toolBar = [UIToolbar new];
#if 0
    for (int i = 0; i < 4; i++) {
        UIBarButtonItem *button = [
    }
    [_toolBar setItems:@[]];
#endif
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolBar]|" options:0 metrics:nil views:views]];
}

- (void)cancelButtonClicked
{
    [_edittingArea resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
