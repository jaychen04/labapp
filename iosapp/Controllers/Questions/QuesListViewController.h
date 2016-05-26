//
//  QuesListViewController.h
//  iosapp
//
//  Created by 李萍 on 16/5/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface QuesListViewController : OSCObjsViewController

@property (nonatomic, strong) NSMutableArray *questions;
-(instancetype)initWithQuestionType:(NSInteger)catalog;

@end
