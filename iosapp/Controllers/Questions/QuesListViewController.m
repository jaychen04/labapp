//
//  QuesListViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesListViewController.h"
#import "QuesAnsCell.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCQuestion.h"

static NSString * const reuseIdentifier = @"QuesAnsCell";
@interface QuesListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *pageToken;
@property (nonatomic, strong) NSMutableArray *questions;

@end

@implementation QuesListViewController

- (void)viewWillAppear:(BOOL)animated
{
    _pageToken = @" ";
//    [self fetchQuestion:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _questions = [NSMutableArray new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QuesAnsCell class]) bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:reuseIdentifier];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - 获取数据
//- (void)fetchQuestion:(NSInteger)questionCatalog
//{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_HTTPS_PREFIX, OSCAPI_QUESTION]
//      parameters:@{
//                   @"catalog"   : @(questionCatalog),
//                   @"pageToken" : _pageToken,
//                   }
//         success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary * _Nonnull responseObject) {
//             //
//             NSLog(@"%@", responseObject);
//         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//             //
//             NSLog(@"%@", error);
//         }];
//}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_questions.count > 0) {
        return _questions.count;
    }
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

@end
