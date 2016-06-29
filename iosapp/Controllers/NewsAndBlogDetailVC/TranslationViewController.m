//
//  TranslationViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TranslationViewController.h"

@interface TranslationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@end

@implementation TranslationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 收藏
- (IBAction)favClick:(id)sender {
    
}

#pragma mark - 分享
- (IBAction)shareClick:(id)sender {
    
}

@end
