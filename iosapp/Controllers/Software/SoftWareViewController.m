//
//  SoftWareViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareViewController.h"
#import "SoftWareDetailCell.h"


#import "Utils.h"
#import "OSCNewSoftWare.h"

static NSString * const softWareDetailReuseIdentifier = @"SoftWareDetailCell";


@interface SoftWareViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;

@property (nonatomic, strong) OSCNewSoftWare *softwareDetail;

@end

@implementation SoftWareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"软件详情";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SoftWareDetailCell" bundle:nil] forCellReuseIdentifier:softWareDetailReuseIdentifier];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SoftWareDetailCell *softWareCell = [tableView dequeueReusableCellWithIdentifier:softWareDetailReuseIdentifier forIndexPath:indexPath];
        
        return softWareCell;
    }
    
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    } else {
        return 200;
    }
}



#pragma mark - click Button
- (IBAction)buttonClick:(UIButton *)sender {
    
}


@end
