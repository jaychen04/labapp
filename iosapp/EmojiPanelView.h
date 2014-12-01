//
//  EmojiPanelView.h
//  iosapp
//
//  Created by chenhaoxiang on 11/26/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiPanelView : UIView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithPanelHeight:(CGFloat)panelHeight;

@property (nonatomic, strong) UICollectionView *emojiCollectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end
