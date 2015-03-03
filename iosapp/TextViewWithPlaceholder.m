//
//  TextViewWithPlaceholder.m
//  iosapp
//
//  Created by chenhaoxiang on 3/3/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TextViewWithPlaceholder.h"

@interface TextViewWithPlaceholder () <UITextViewDelegate>

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation TextViewWithPlaceholder

- (instancetype)initWithPlaceholder:(NSString *)placeholder
{
    self = [super init];
    if (self) {
        [self setUpPlaceholderLabel:placeholder];
        
        self.delegate = self;
    }
    
    return self;
}

- (void)setUpPlaceholderLabel:(NSString *)placeholder
{
    _placeholderLabel = [UILabel new];
    _placeholderLabel.textColor = [UIColor lightGrayColor];
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.text = placeholder;
    [self addSubview:_placeholderLabel];
    
    _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_placeholderLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-6-[_placeholderLabel]-6-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-9-[_placeholderLabel]"   options:0 metrics:nil views:views]];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholderLabel.text = placeholder;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self textViewDidChange:textView];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView hasText]) {
        _placeholderLabel.hidden = YES;
    } else {
        _placeholderLabel.hidden = NO;
    }  
}

@end
