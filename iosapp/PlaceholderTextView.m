//
//  PlaceholderTextView.m
//  Test
//
//  Created by AeternChan on 7/15/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "PlaceholderTextView.h"

static NSString * const kTextKey = @"text";


@interface PlaceholderTextView ()

@property (nonatomic, strong) UITextView *placeholderView;

@end



@implementation PlaceholderTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpPlaceholderView];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpPlaceholderView];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:kTextKey];
}


#pragma mark - observation

- (void)setUpPlaceholderView
{
//    如果使用autolayout布局的话，self.frame = CGRectZer，所以placeholderView应该用autolayout布局
//    _placeholderView = [[UITextView alloc] initWithFrame:self.bounds];
    
    _placeholderView = [UITextView new];
    [self addSubview:_placeholderView];
    
    _placeholderView.editable = NO;
    _placeholderView.scrollEnabled = NO;
    _placeholderView.showsHorizontalScrollIndicator = NO;
    _placeholderView.showsVerticalScrollIndicator = NO;
    _placeholderView.userInteractionEnabled = NO;
    _placeholderView.font = self.font;
    _placeholderView.contentInset = self.contentInset;
    _placeholderView.contentOffset = self.contentOffset;
    _placeholderView.textContainerInset = self.textContainerInset;
    _placeholderView.textColor = [UIColor lightGrayColor];
    _placeholderView.backgroundColor = [UIColor clearColor];
    
    _placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_placeholderView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_placeholderView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_placeholderView]|" options:0 metrics:nil views:views]];
    
    
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(textDidChange:)
                          name:UITextViewTextDidChangeNotification object:self];
    
    [self addObserver:self forKeyPath:kTextKey options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kTextKey]) {
        _placeholderView.hidden = [self hasText];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)textDidChange:(NSNotification *)notification
{
    _placeholderView.hidden = [self hasText];
}



#pragma mark - property accessor


- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    _placeholderView.font = font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    _placeholderView.textAlignment = textAlignment;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    _placeholderView.contentInset = contentInset;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    _placeholderView.contentOffset = contentOffset;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];
    _placeholderView.textContainerInset = textContainerInset;
}

#pragma mark placeholder

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholderView.text = placeholder;
}

- (NSString *)placeholder
{
    return _placeholderView.text;
}


@end
