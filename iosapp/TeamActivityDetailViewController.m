//
//  TeamActivityDetailViewController.m
//  iosapp
//
//  Created by Holden on 15/5/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamActivityDetailViewController.h"
#import "Utils.h"
#import "TeamActivityInfoCell.h"
#import "CommentCell.h"

#import "TeamAPI.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import "Config.h"
#import "TeamActivity.h"
#import "TeamMember.h"
@class TeamActivity;
@class TeamMember;

@interface TeamActivityDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *detailTableView;
@property (nonatomic,strong)TeamActivity *activity;
@end

@implementation TeamActivityDetailViewController

- (instancetype)init
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _detailTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;

    _detailTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_detailTableView];
    
    [self.view bringSubviewToFront:(UIView *)self.editingBar];
    
    
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    CGFloat topBarHeight = navHeight+statusBarHeight;
    NSDictionary *heightDic =@{@"topBarHeight":[NSNumber numberWithFloat:topBarHeight]};
    NSDictionary *views = @{@"detailTableView": _detailTableView, @"bottomBar": self.editingBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topBarHeight)-[detailTableView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:heightDic views:views]];
    
    [self getActivityDetails];
}

- (void)getActivityDetails
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@?uid=%lld&teamid=%d&activeid=%d", TEAM_PREFIX, TEAM_ACTIVE_DETAIL, [Config getOwnID],_teamID,_activityID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {

             /*
             <active>
             <id>5368689</id>
             <type>112</type>
             <appclient>7</appclient>
             <appName/>
             <body>
             <title><![CDATA[      	<div class='git_tweet_title'>在 项目 <a href='http://team.oschina.net/osc/project?project=239270'><span class='tiny'>zouqilin / osc_rugged</span></a> 创建 <a href='http://team.oschina.net/osc/issues?source=Git@OSC&pid=239270&piid=2'>任务 #2</a></div><div class='git_tweet_body'>ruby 2.1.*版本内存问题讨论</div>
                             ]]></title>
             <detail><![CDATA[<div class='git_tweet_body'>ruby 2.1.*版本内存问题讨论</div>]]></detail>
             <code><![CDATA[]]></code>
             <codeType/>
             <image/>
             <imageOrigin/>
             </body>
             <reply>1</reply>
             <createTime>2015-04-28 09:56:50</createTime>
             <author>
             <id>1020272</id>
             <name><![CDATA[邹奇林]]></name>
             <portrait>http://static.oschina.net/uploads/user/510/1020272_100.jpg?t=1392545943000</portrait>
             </author>
             </active>
             */
             
             
             ONOXMLElement *activityDetailsXML = [responseObject.rootElement firstChildWithTag:@"active"];

             _activity = [[TeamActivity alloc] initWithXML:activityDetailsXML];

//             [cell.webView loadHTMLString:activity.detail baseURL:nil];
             
//             self.objectAuthorID = _tweet.authorID;
             
             _activity.detail = [NSString stringWithFormat:@"<style>a{color:#087221; text-decoration:none;}</style>\
                            <font size=\"3\"><strong>%@</strong></font>\
                            <br/>",
                            _activity.detail];

//             if (_tweet.hasAnImage) {
//                 _tweet.body = [NSString stringWithFormat:@"%@<a href='%@'>\
//                                <img style='max-width:300px;\
//                                margin-top:10px;\
//                                margin-bottom:15px'\
//                                src='%@'/>\
//                                </a>", _tweet.body, _tweet.bigImgURL, _tweet.bigImgURL];
//             }
//
//             if (_tweet.attach.length) {
//                 //有语音信息
//                 
//                 NSString *attachStr = [NSString stringWithFormat:@"<source src=\"%@?avthumb/mp3\" type=\"audio/mpeg\">", _tweet.attach];
//                 _tweet.body = [NSString stringWithFormat:@"%@<br/><audio controls>%@</audio>", _tweet.body, attachStr];
//             }

             dispatch_async(dispatch_get_main_queue(), ^{
                 [_detailTableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         }];
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==1){
        return @"开源中国";
    }else{
        return nil;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==1) {
        return 11;
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    TEAM_ACTIVE_DETAIL
    static NSString * const kActivityInfoCellIdentifier = @"kActivityInfoCellIdentifier";
    static NSString * const kCommentCellIdentifier = @"kCommentCellIdentifier";

    if (indexPath.section == 0) {
        TeamActivityInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kActivityInfoCellIdentifier];
        if (cell == nil) {
            cell = [[TeamActivityInfoCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: kActivityInfoCellIdentifier];
        }
        cell.portrait.backgroundColor = [UIColor redColor];
        cell.webView.backgroundColor = [UIColor greenColor];
        cell.authorLabel.text = _activity.author.name;
        cell.timeLabel.text = _activity.createTime;

        return cell;
    }else {
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: kCommentCellIdentifier];
        }
        return cell;
    }
    
//    if ([[cell class] isSubclassOfClass:[TeamActivityInfoCell class]]) {
//        cell.backgroundColor = [UIColor greenColor];
//    }else
//        cell.backgroundColor = [UIColor redColor];
    

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
