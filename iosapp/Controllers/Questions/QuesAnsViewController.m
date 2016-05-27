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

@property (nonatomic, strong) QuesListViewController *currentListCtl;
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
    _shareListCtl = [[QuesListViewController alloc] initWithQuestionType:2];
    _generalListCtl = [[QuesListViewController alloc] initWithQuestionType:3];
    _jobListCtl = [[QuesListViewController alloc] initWithQuestionType:4];
    _forumListCtl = [[QuesListViewController alloc] initWithQuestionType:5];
    
    CGRect subViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.tableSubView.frame), CGRectGetHeight(self.tableSubView.frame));
    _questListCtl.view.frame = subViewFrame;
    _shareListCtl.view.frame = subViewFrame;
    _generalListCtl.view.frame = subViewFrame;
    _jobListCtl.view.frame = subViewFrame;
    _forumListCtl.view.frame = subViewFrame;
    
    _subVcs = @[_questListCtl,_shareListCtl,_generalListCtl,_jobListCtl,_forumListCtl];
    
    
    
    [self addChildViewController:_questListCtl];
//    [self addChildViewController:_shareListCtl];
//    [self addChildViewController:_generalListCtl];
//    [self addChildViewController:_jobListCtl];
//    [self addChildViewController:_forumListCtl];
    
    [self.tableSubView addSubview:_questListCtl.view];
    _currentListCtl = _questListCtl;
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
    
//    [self removeFromParentViewController];
//    [self.tableSubView removeFromSuperview];
    
//    _questListCtl = [[QuesListViewController alloc] initWithQuestionType:tagNumber];
//    _questListCtl.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableSubView.frame), CGRectGetHeight(self.tableSubView.frame));

//    [self addChildViewController:_questListCtl];
//    [self.tableSubView addSubview:_questListCtl.view];
//    [_questListCtl.tableView reloadData];
    
    
    QuesListViewController *newCurrentVc = _subVcs[tagNumber];
    if (_currentListCtl == newCurrentVc) {
        return;
    }else {
        
        [self addChildViewController:newCurrentVc];
        [self transitionFromViewController:_currentListCtl toViewController:newCurrentVc duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
            if (finished) {
                [newCurrentVc didMoveToParentViewController:self];
                [_currentListCtl willMoveToParentViewController:nil];
                [_currentListCtl removeFromParentViewController];
                _currentListCtl = newCurrentVc;
            }
        }];
    }
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
