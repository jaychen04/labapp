//
//  QuesAnsViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsViewController.h"
#import "QuesAnsCell.h"
#import "Utils.h"

static NSString * const reuseIdentifier = @"QuesAnsCell";
@interface QuesAnsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *buttons;

@end

@implementation QuesAnsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QuesAnsCell class]) bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:reuseIdentifier];
    
    [self setButtonBoradWidthAndColor:_askQuesButton isSelected:YES];
    _buttons = @[_askQuesButton, _shareButton, _synthButton, _jobButton, _officeButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuesAnsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - 小标题功能

- (IBAction)clickSubTitle:(UIButton *)sender {
    
    NSInteger tagNumber = sender.tag-1;
    
    [_buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == tagNumber) {
            [self setButtonBoradWidthAndColor:obj isSelected:YES];
        } else {
            [self setButtonBoradWidthAndColor:obj isSelected:NO];
        }
    }];
    
    NSLog(@"按钮 = %ld", (long)sender.tag);
}

#pragma mark - 按钮设置边框、颜色
- (void)setButtonBoradWidthAndColor:(UIButton *)button isSelected:(BOOL)isSelected
{
    if (isSelected) {
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
        [button setTitleColor:[UIColor colorWithHex:0x24CF5F] forState:UIControlStateNormal];
    } else {
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor colorWithHex:0xF6F6F6].CGColor;
        [button setTitleColor:[UIColor colorWithHex:0x6A6A6A] forState:UIControlStateNormal];
    }
    
}

@end
