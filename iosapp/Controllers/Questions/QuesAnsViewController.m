//
//  QuesAnsViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsViewController.h"
#import "Utils.h"
#import "QuesListViewController.h"

@interface QuesAnsViewController ()

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) QuesListViewController *questListCtl;
@property (nonatomic, strong) QuesListViewController *shareListCtl;
@property (nonatomic, strong) QuesListViewController *generalListCtl;
@property (nonatomic, strong) QuesListViewController *jobListCtl;
@property (nonatomic, strong) QuesListViewController *forumListCtl;
@property (nonatomic, strong) NSArray *subVcs;
@end

@implementation QuesAnsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setButtonBoradWidthAndColor:_askQuesButton isSelected:YES];
    _buttons = @[_askQuesButton, _shareButton, _synthButton, _jobButton, _officeButton];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _questListCtl = [[QuesListViewController alloc] initWithQuestionType:1];
//    QuesListViewController *shareListCtl = [[QuesListViewController alloc] initWithQuestionType:2];
//    QuesListViewController *generalListCtl = [[QuesListViewController alloc] initWithQuestionType:3];
//    QuesListViewController *jobListCtl = [[QuesListViewController alloc] initWithQuestionType:4];
//    QuesListViewController *forumListCtl = [[QuesListViewController alloc] initWithQuestionType:5];
    
    CGRect subViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.tableSubView.frame), CGRectGetHeight(self.tableSubView.frame));
    _questListCtl.view.frame = subViewFrame;
//    shareListCtl.view.frame = subViewFrame;
//    generalListCtl.view.frame = subViewFrame;
//    jobListCtl.view.frame = subViewFrame;
//    forumListCtl.view.frame = subViewFrame;
    
//    _subVcs = @[questListCtl,shareListCtl,generalListCtl,jobListCtl,forumListCtl];
    
    
    
    [self addChildViewController:_questListCtl];
    
//    [self addChildViewController:_shareListCtl];
//    [self addChildViewController:_generalListCtl];
//    [self addChildViewController:_jobListCtl];
//    [self addChildViewController:_forumListCtl];
    
    [self.tableSubView addSubview:_questListCtl.view];
    
    self.buttonView.backgroundColor = [UIColor newCellColor];
    [_buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        {
            obj.backgroundColor = [UIColor colorWithHex:0x333333];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 小标题功能

- (IBAction)clickSubTitle:(UIButton *)sender {
    
    NSInteger tagNumber = sender.tag;
    
    [_buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == tagNumber-1) {
            [self setButtonBoradWidthAndColor:obj isSelected:YES];
        } else {
            [self setButtonBoradWidthAndColor:obj isSelected:NO];
        }
    }];
    

    
    
//    QuesListViewController *newCurrentVc = _subVcs[tagNumber];
//    if (_currentListCtl == newCurrentVc) {
//        return;
//    }else {
//        
//        [self addChildViewController:newCurrentVc];
//        [self transitionFromViewController:_currentListCtl toViewController:newCurrentVc duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
//            if (finished) {
//                
//                [newCurrentVc didMoveToParentViewController:self];
//                [_currentListCtl willMoveToParentViewController:nil];
//                [_currentListCtl removeFromParentViewController];
//                _currentListCtl = newCurrentVc;
//            }
//        }];
//    }
    
    _questListCtl.paraDic = @{
      @"catalog"   : @(tagNumber),
      @"pageToken" : @""
      };
    [_questListCtl refresh];
}

#pragma mark - 按钮设置边框、颜色
- (void)setButtonBoradWidthAndColor:(UIButton *)button isSelected:(BOOL)isSelected
{
    if (isSelected) {
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
        [button setTitleColor:[UIColor colorWithHex:0x24CF5F] forState:UIControlStateNormal];
    } else {
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor colorWithHex:0xF6F6F6].CGColor;
        [button setTitleColor:[UIColor colorWithHex:0x6A6A6A] forState:UIControlStateNormal];
    }
    
}

@end
