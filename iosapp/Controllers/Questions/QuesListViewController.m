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

-(instancetype)init{
    self = [super init];
    if (self) {
        __weak QuesListViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return @"http://192.168.1.72:1104/action/apiv2/news";
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        self.objClass = [OSCQuestion class];
        
        self.isJsonDataVc = YES;
        self.parametersDic = @{
//                               @"catalog"   : @(questionCatalog),
//                               @"pageToken" : _pageToken
                               };
        
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated
{
    _pageToken = @" ";
//    [self fetchQuestion:1];
    
//    self.responseJsonObject
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
