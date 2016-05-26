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
    _questListCtl.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableSubView.frame), CGRectGetHeight(self.tableSubView.frame));
    [self addChildViewController:_questListCtl];
    [self.tableSubView addSubview:_questListCtl.view];
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
