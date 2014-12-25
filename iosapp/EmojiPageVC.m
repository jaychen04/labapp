//
//  EmojiPageVC.m
//  iosapp
//
//  Created by chenhaoxiang on 11/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EmojiPageVC.h"
#import "EmojiPanelVC.h"


@interface EmojiPageVC () <UIPageViewControllerDataSource>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, copy) void (^didSelectEmoji) (NSTextAttachment *);

@end


@implementation EmojiPageVC

- (instancetype)initWithTextView:(UITextView *)textView
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:nil];
    if (self) {
        _textView = textView;
        __weak UITextView *weakTextView = _textView;
        _didSelectEmoji = ^(NSTextAttachment *textAttachment) {
            NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:weakTextView.attributedText];
            [mutableAttributeString replaceCharactersInRange:[weakTextView selectedRange] withAttributedString:emojiAttributedString];
            weakTextView.attributedText = [mutableAttributeString copy];
        };
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    EmojiPanelVC *emojiPanelVC = [[EmojiPanelVC alloc] initWithPageIndex:0];
    emojiPanelVC.didSelectEmoji = _didSelectEmoji;
    if (emojiPanelVC != nil) {
        self.dataSource = self;
        [self setViewControllers:@[emojiPanelVC]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:NO
                      completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(EmojiPanelVC *)vc
{
    int index = vc.pageIndex;
    
    if (index == 0) {
        return nil;
    } else {
        EmojiPanelVC *emojiPanelVC = [[EmojiPanelVC alloc] initWithPageIndex:index-1];
        emojiPanelVC.didSelectEmoji = _didSelectEmoji;
        return emojiPanelVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(EmojiPanelVC *)vc
{
    int index = vc.pageIndex;
    
    if (index == 5) {
        return nil;
    } else {
        EmojiPanelVC *emojiPanelVC = [[EmojiPanelVC alloc] initWithPageIndex:index+1];
        emojiPanelVC.didSelectEmoji = _didSelectEmoji;
        return emojiPanelVC;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 6;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}





@end
