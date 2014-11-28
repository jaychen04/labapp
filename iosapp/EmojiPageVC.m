//
//  EmojiPageVC.m
//  iosapp
//
//  Created by ChanAetern on 11/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EmojiPageVC.h"
#import "EmojiCollectionVC.h"

@interface EmojiPageVC ()

@end

@implementation EmojiPageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    EmojiCollectionVC *emojiCollectionVC = [[EmojiCollectionVC alloc] initWithPageIndex:0];
    if (emojiCollectionVC != nil) {
        self.dataSource = self;
        [self setViewControllers:@[emojiCollectionVC]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:NO
                      completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(EmojiCollectionVC *)vc
{
    NSUInteger index = vc.pageIndex;
    
    if (index == 0) {
        return nil;
    }
    return [[EmojiCollectionVC alloc] initWithPageIndex:0];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(EmojiCollectionVC *)vc
{
    NSUInteger index = vc.pageIndex;
    
    if (index == 2) {
        return nil;
    }
    return [[EmojiCollectionVC alloc] initWithPageIndex:0];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}





@end
