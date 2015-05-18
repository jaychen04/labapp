//
//  TeamIssueDetailController.m
//  iosapp
//
//  Created by Holden on 15/4/30.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueDetailController.h"
#import "TeamIssueDetailCell.h"
#import "Utils.h"
#import "TeamAPI.h"
#import "TeamIssue.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import "NSString+FontAwesome.h"



@interface TeamIssueDetailController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic)int teamId;
@property (nonatomic)int issueId;

@property (nonatomic,strong)TeamIssue *detailIssue;
@property (nonatomic,strong)NSArray *iconTexts;
@property (nonatomic,strong)NSArray *titles;
@property (nonatomic,strong)NSArray *descriptions;

@property (nonatomic,strong)NSMutableArray *issueInfos;
@property (nonatomic,strong)NSMutableArray *subIssueInfos;
@end

@implementation TeamIssueDetailController

- (instancetype)initWithTeamId:(int)teamId andIssueId:(int)issueId
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        _teamId = teamId;
        _issueId = issueId;
    }
    
    return self;
}

-(void)getIssueDetailNetWorkingInfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    NSString *url = [NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_ISSUE_DETAIL];
    [manager GET:url
      parameters:@{
                   @"teamid": @(_teamId),
                   @"issueid": @(_issueId)
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _detailIssue = [[TeamIssue alloc]initWithDetailIssueXML:[responseObject.rootElement firstChildWithTag:@"issue"]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getIssueDetailNetWorkingInfo];
    
    _iconTexts = @[@"\uf067",@"\uf007",@"\uf073",@"\uf0c0",@"\uf080",@"\uf02c",@"\uf0c6",@"\uf0c1"];
    _titles = @[@"子任务",@"指派给",@"截止日期",@"协作者",@"阶段",@"",@"附件",@"关联"];
    _descriptions = @[@"暂无子任务",@"未指派",@"未指定截止日期",@"暂无协作者",@"待办中",@"",@"暂无附件",@"暂无关联"];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor themeColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    //registerCell
    NSArray *identifiers = @[kteamIssueDetailCellNomal,kTeamIssueDetailCellRemark,kTeamIssueDetailCellSubChild];
    for (int i=0; i<3; i++) {
        [_tableView registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:[identifiers objectAtIndex:i]];
    }
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:(UIView *)self.editingBar];
    
    NSDictionary *views = @{@"detailTableView": _tableView, @"bottomBar": self.editingBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailTableView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:views]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return _detailIssue.title;
    }else {
        return @"评论";
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 12;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TeamIssueDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kteamIssueDetailCellNomal];
    
    if(indexPath.row < _iconTexts.count)
    {
        cell.iconLabel.text =_iconTexts[indexPath.row];
        cell.titleLabel.text = _titles[indexPath.row];;
        cell.descriptionLabel.text = _descriptions[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *path = nil;
    path = [NSIndexPath indexPathForItem:(indexPath.row+1) inSection:indexPath.section];
//    if (indexPath.row%2 == 0) {
//        path = [NSIndexPath indexPathForItem:(indexPath.row+1) inSection:indexPath.section];
//    }
//    else
//    {
//        path = indexPath;
//    }
    
//    [tableView beginUpdates];
//    [tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationMiddle];
//    [tableView endUpdates];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be ;.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
