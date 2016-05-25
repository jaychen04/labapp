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
#import "OSCQuestion.h"

static NSString * const reuseIdentifier = @"QuesAnsCell";
@interface QuesAnsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, copy) NSString *pageToken;
@property (nonatomic, strong) NSMutableArray *questions;

@end

@implementation QuesAnsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _questions = [NSMutableArray new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QuesAnsCell class]) bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:reuseIdentifier];
    
    [self setButtonBoradWidthAndColor:_askQuesButton isSelected:YES];
    _buttons = @[_askQuesButton, _shareButton, _synthButton, _jobButton, _officeButton];
    
    _pageToken = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 获取数据
- (void)fetchQuestion:(NSInteger)questionCatalog
{
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (_questions.count > 0) {
        OSCQuestion *question = _questions[indexPath.row];
        
        label.font = [UIFont systemFontOfSize:15];
        label.text = question.title;
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 85, MAXFLOAT)].height;
        
        label.font = [UIFont systemFontOfSize:14];
        label.text = question.body;
        height += [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 85, MAXFLOAT)].height;
        
        return height;
    }
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuesAnsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (_questions.count > 0) {
        OSCQuestion *question = _questions[indexPath.row];
        [cell setcontentForQuestionsAns:question];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    
    [self fetchQuestion:tagNumber];
    
    NSLog(@"按钮 = %ld", tagNumber);
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
