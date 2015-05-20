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

#import "TeamReplyCell.h"
#import "TeamReply.h"

@interface TeamIssueDetailController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic)int teamId;
@property (nonatomic)int issueId;

@property (nonatomic,copy)NSString *issueTitle;
@property (nonatomic,strong)TeamIssue *detailIssue;

@property (nonatomic,strong)NSMutableArray *originDatas;
//@property (nonatomic,strong)NSMutableArray *iconTexts;
//@property (nonatomic,strong)NSMutableArray *titles;
@property (nonatomic,strong)NSMutableArray *descriptions;

@property (nonatomic,strong)NSMutableArray *replies;
@property (nonatomic,strong)NSMutableArray *subIssueInfos;

@property (nonatomic)BOOL isOpeningSubIssue;
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

#pragma mark --评论列表
-(void)getIssueCommentList
{
    //    teamid 团队id
    //    type 实体的类型，例如：(diary|discuss|issue)
    //    id 对应类型实体的id
    //    pageIndex 页数
    //    pageSize 每页条数
    //    [manager GET:url
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    NSString *url = [NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_REPLY_LIST_BY_TYPE];
    NSDictionary *dic = @{
                          @"teamid": @(_teamId),
                          @"id": @(_issueId),
                          @"type":@"issue",
                          @"pageIndex":@0,
                          @"pageSize":@20
                          };
    [manager GET:url
      parameters:dic
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             NSArray *tempArr = [[responseObject.rootElement firstChildWithTag:@"replies"] childrenWithTag:@"reply"];
             if (tempArr.count > 0) {
                 _replies = [NSMutableArray new];
                 for (int j = 0; j < tempArr.count; j++) {
                     ONOXMLElement *element = [tempArr objectAtIndex:j];
                     TeamReply *reply = [[TeamReply alloc]initWithXML:element];
                     [_replies addObject:reply];
                 }
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}




#pragma mark --任务详情信息
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
             _subIssueInfos = _detailIssue.childIssues;
             
             _issueTitle = _detailIssue.title;
             
             NSString *subIssueCount = _detailIssue.childIssues.count >0 ?[NSString stringWithFormat:@"%d个子任务，%d个已完成",_detailIssue.childIssuesCount,_detailIssue.closedChildIssuesCount] : @"暂无子任务";
             NSString *toUser = [_detailIssue.user.name length] > 0 ? _detailIssue.user.name : @"未指派";
             NSString *deadLineTime = _detailIssue.deadline ?:@"未指定截止日期";
             NSString *state = [self translateState:_detailIssue.state];
             NSString *attachmentsCount = _detailIssue.attachmentsCount > 0 ?[NSString stringWithFormat:@"%d",_detailIssue.attachmentsCount] : @"暂无附件";
             NSString *relationIssueCount = _detailIssue.relationIssueCount > 0 ?[NSString stringWithFormat:@"%d",_detailIssue.relationIssueCount] : @"暂无关联";
             NSString *allCollaborator = [self getCollaboratorsStringWithcollabortorsArray:_detailIssue.collaborators];
             
             _descriptions = [NSMutableArray arrayWithArray:@[@"",subIssueCount, toUser, deadLineTime, allCollaborator, state, @"", attachmentsCount, relationIssueCount]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}
//设置MainCellcell的数据
-(void)setMainCellData
{
    NSDictionary *iconTitleDic0 = @{@"icon":@"\uf10c",@"title":@"",@"cellLevel":@1};
    NSDictionary *iconTitleDic1 = @{@"icon":@"\uf067",@"title":@"子任务",@"cellLevel":@1};
    NSDictionary *iconTitleDic2 = @{@"icon":@"\uf007",@"title":@"指派给",@"cellLevel":@1};
    NSDictionary *iconTitleDic3 = @{@"icon":@"\uf073",@"title":@"截止日期",@"cellLevel":@1};
    NSDictionary *iconTitleDic4 = @{@"icon":@"\uf0c0",@"title":@"协作者",@"cellLevel":@1};
    NSDictionary *iconTitleDic5 = @{@"icon":@"\uf080",@"title":@"阶段",@"cellLevel":@1};
    NSDictionary *iconTitleDic6 = @{@"icon":@"\uf02c",@"title":@"-",@"cellLevel":@1};
    NSDictionary *iconTitleDic7 = @{@"icon":@"\uf0c6",@"title":@"附件",@"cellLevel":@1};
    NSDictionary *iconTitleDic8 = @{@"icon":@"\uf0c1",@"title":@"关联",@"cellLevel":@1};
    
    _originDatas = [NSMutableArray arrayWithArray:@[iconTitleDic0,iconTitleDic1,iconTitleDic2,iconTitleDic3,iconTitleDic4,iconTitleDic5,iconTitleDic6,iconTitleDic7,iconTitleDic8]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setMainCellData];
    
    //    _iconTexts = [NSMutableArray arrayWithArray:@[@"\uf10c", @"\uf067", @"\uf007", @"\uf073", @"\uf0c0", @"\uf080", @"\uf02c", @"\uf0c6", @"\uf0c1"]];
    //    _titles = [NSMutableArray arrayWithArray:@[@"", @"子任务", @"指派给", @"截止日期", @"协作者", @"阶段", @"", @"附件", @"关联"]];
    //    _descriptions = [NSMutableArray arrayWithArray:@[@"",@"暂无子任务", @"未指派", @"未指定截止日期", @"暂无协作者", @"待办中", @"", @"暂无附件", @"暂无关联"]];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor themeColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    //    _tableView.allowsSelection = NO;
    //registerCell
    NSArray *identifiers = @[kteamIssueDetailCellNomal,kTeamIssueDetailCellRemark,kTeamIssueDetailCellSubChild];
    for (int i=0; i<3; i++) {
        [_tableView registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:[identifiers objectAtIndex:i]];
    }
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:(UIView *)self.editingBar];
    
    NSDictionary *views = @{@"detailTableView": _tableView, @"bottomBar": self.editingBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailTableView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:views]];
    
    [self getIssueCommentList];
    [self getIssueDetailNetWorkingInfo];
}

//任务状态显示
-(NSString*)translateState:(NSString*)state
{
    NSString *translatedState;
    if ([state isEqualToString:@"opened"]) {
        translatedState = @"待办中";
    }else if ([state isEqualToString:@"underway"]) {
        translatedState = @"进行中";
    }else if ([state isEqualToString:@"closed"]) {
        translatedState = @"已完成";
    }else if ([state isEqualToString:@"accepted"]) {
        translatedState = @"已验收";
    }else {
        translatedState = @"待办中";
    }
    return translatedState;
}
//协助者显示
-(NSString*)getCollaboratorsStringWithcollabortorsArray:(NSArray*)collaborators {
    NSString *allCollaborators = @"";
    if (collaborators.count > 0) {
        for (int k = 0; k < collaborators.count; k++) {
            TeamMember *member = [collaborators objectAtIndex:k];
            if (k == 0) {
                allCollaborators = [allCollaborators stringByAppendingFormat:@"%@",member.name];
            } else {
                allCollaborators = [allCollaborators stringByAppendingFormat:@",%@",member.name];
            }
            if (k == 3) {
                allCollaborators = [allCollaborators stringByAppendingString:@"等"];
                break;
            }
        }
        
    }else {
        allCollaborators = @"暂无协作者";
    }
    return allCollaborators;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 55;
    }else {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        TeamReply *reply = _replies[indexPath.row];
        label.font = [UIFont systemFontOfSize:14];
        label.text = reply.content;
        
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        
        return height + 66;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return _projectName ?: @"";
    }else {
        return @"评论";
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _originDatas.count;
    }else {
        return _replies.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
    {
        TeamIssueDetailCell *cell;
        
        NSDictionary *tempDic = _originDatas[indexPath.row];
        if (![tempDic[@"title"] isEqualToString:@"-"]) {    //根据原始设定数据判断当前cell的风格
            if ([tempDic[@"cellLevel"] intValue] == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:kteamIssueDetailCellNomal];
                cell.iconLabel.text = tempDic[@"icon"];
                
                if(_descriptions.count > 0) {
                    cell.descriptionLabel.text = _descriptions[indexPath.row] ?: @"";
                }
                if ([tempDic[@"title"] isEqualToString:@""]) {
                    cell.titleLabel.text =  _issueTitle;
                    cell.titleLabel.font =[UIFont systemFontOfSize:18];
                    cell.titleLabel.textColor = [UIColor blackColor];
                    
                    //                UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetHeight(cell.bounds), [UIScreen mainScreen].bounds.size.width-60, 1)];
                    //                lineView.backgroundColor = [UIColor redColor];
                    //                [cell addSubview:lineView];
                }else {
                    cell.titleLabel.text = tempDic[@"title"];
                }
            }else if ([tempDic[@"cellLevel"] intValue] == 2) {   //cellLevel=2 子任务的cell
                cell = [tableView dequeueReusableCellWithIdentifier:kTeamIssueDetailCellSubChild];
                
                NSDictionary *tempDic = _originDatas[indexPath.row];
                [cell.portraitIv loadPortrait:tempDic[@"portraitUrl"]];
                cell.descriptionLabel.text = tempDic[@"title"];
                cell.iconLabel.text = tempDic[@"icon"];
            }
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:kTeamIssueDetailCellRemark];
            cell.iconLabel.text = tempDic[@"icon"];
            if (_detailIssue.issueLabels.count > 0) {
                [cell setupRemarkLabelsWithtexts:_detailIssue.issueLabels];
            }
            
        }
        return cell;
    }else {
        if (_replies.count > 0) {
            TeamReplyCell *cell = [TeamReplyCell new];
            TeamReply *reply = _replies[indexPath.row];
            [cell setContentWithReply:reply];
            return cell;
        }else {
            return [UITableViewCell new];
        }
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > _originDatas.count) {
        return;
    }
    NSDictionary *selectedIssue = [_originDatas objectAtIndex:indexPath.row];
    if ([selectedIssue[@"title"] isEqualToString:@"子任务"]) {
        if (_isOpeningSubIssue) {   //关闭子任务
            NSIndexSet *sets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row+1, _subIssueInfos.count)];
            [_originDatas removeObjectsAtIndexes:sets];
            [_descriptions removeObjectsAtIndexes:sets];
            NSMutableArray *pathArray = [NSMutableArray new];
            for (int k=1; k<=_subIssueInfos.count; k++) {
                NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row+k) inSection:indexPath.section];
                [pathArray addObject:path];
            }
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }else {     //展开子任务
            NSArray *subIssueInfo = [self setupSubIssueCellData];
            NSMutableArray *pathArray = [NSMutableArray new];
            for (int k=1; k<=subIssueInfo.count; k++) {
                NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row+k) inSection:indexPath.section];
                [pathArray addObject:path];
            }
            NSIndexSet *sets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row+1, subIssueInfo.count)];
            [_originDatas insertObjects:subIssueInfo atIndexes:sets];
            [_descriptions insertObjects:subIssueInfo atIndexes:sets];
            
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        _isOpeningSubIssue = !_isOpeningSubIssue;
    }
}

-(NSMutableArray*)setupSubIssueCellData
{
    //    待办中：f10c
    //    进行中：f192
    //    已完成：f05d
    //    已验收：f023
    
    NSMutableArray *subArray = [NSMutableArray new];
    for (TeamIssue *issue in _subIssueInfos) {
        NSString *iconString = [self getIconStringWithState:issue.state];
        NSURL *portraitUrl = issue.author.portraitURL ?: [NSURL URLWithString:@""];
        NSString *subIssueTitle = issue.title ?: @"";
        NSDictionary *subIssueDic = @{@"icon":iconString,
                                      @"title":subIssueTitle,
                                      @"portraitUrl":portraitUrl,
                                      @"cellLevel":@2
                                      };
        [subArray addObject:subIssueDic];
    }
    return subArray;
}
-(NSString*)getIconStringWithState:(NSString*)state
{
    NSString *iconString;
    
    if ([state isEqualToString:@"opened"]) {
        iconString = @"\uf10c";
    }else if ([state isEqualToString:@"underway"]) {
        iconString = @"\uf192";
    }else if ([state isEqualToString:@"closed"]) {
        iconString = @"\uf05d";
    }else if ([state isEqualToString:@"accepted"]) {
        iconString = @"\uf023";
    }else {
        iconString = @"";
    }
    return iconString;
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
