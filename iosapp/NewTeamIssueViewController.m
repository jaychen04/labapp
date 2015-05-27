//
//  NewTeamIssueViewController.m
//  iosapp
//
//  Created by Holden on 15/5/21.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "NewTeamIssueViewController.h"
#import "NSString+FontAwesome.h"
#include "TeamIssueDetailCell.h"
#import "UIColor+Util.h"
#import "JKAlertDialog.h"
static NSString *kteamIssueTitleCell = @"teamIssueTitleCell";

@interface NewTeamIssueViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSArray *iconArray;
@property (nonatomic,strong)NSArray *titlteArray;
@property (nonatomic,strong)NSArray *valueArray;
@end

@implementation NewTeamIssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor themeColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UITableView *infoTv = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 300) style:UITableViewStylePlain];
    infoTv.delegate = self;
    infoTv.dataSource = self;
    infoTv.scrollEnabled = NO;
    [infoTv registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:kteamIssueDetailCellNomal];
    [infoTv registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:kteamIssueTitleCell];
    [self.view addSubview:infoTv];
    
    _iconArray = @[@"\uf01c",@"\uf03a",@"\uf007",@"\uf017"];
    _titlteArray = @[@"项目",@"任务分组",@"指派人员",@"完成时间"];
    _valueArray = @[@"不指定项目",@"未指定列表",@"未指派",@""];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kteamIssueTitleCell forIndexPath:indexPath];
        UITextField *titleTf = [[UITextField alloc]initWithFrame:CGRectMake(20, 5, CGRectGetWidth([[UIScreen mainScreen] bounds])-40, CGRectGetHeight(cell.frame)-10)];
        titleTf.placeholder = @"任务标题";
        [cell addSubview:titleTf];
        return cell;
    } else {
        TeamIssueDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kteamIssueDetailCellNomal forIndexPath:indexPath];
        cell.iconLabel.text = [_iconArray objectAtIndex:indexPath.row-1];
        cell.titleLabel.text = [_titlteArray objectAtIndex:indexPath.row-1];
        cell.descriptionLabel.text = [_valueArray objectAtIndex:indexPath.row-1];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableView *_table=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 270, 200) style:UITableViewStylePlain];
    JKAlertDialog *alert = [[JKAlertDialog alloc]initWithTitle:@"提示" message:@"选择吧"];
    alert.contentView =  _table;
    
    [alert show];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
