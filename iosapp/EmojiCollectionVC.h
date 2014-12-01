//
//  EmojiCollectionVC.h
//  iosapp
//
//  Created by chenhaoxiang on 11/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiCollectionVC : UICollectionViewController

@property (nonatomic, assign) NSInteger pageIndex;

- (instancetype)initWithPageIndex:(NSInteger)pageIndex;

@end
