//
//  SoftWareViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareViewController.h"

#import "SoftWareDetailCell.h"
#import "SoftWareDetailBodyCell.h"
#import "SoftWareDetailHeaderView.h"
#import "TweetTableViewController.h"

#import "OSCAPI.h"
#import "Utils.h"
#import "UMSocial.h"
#import "OSCNewSoftWare.h"

#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <MJExtension.h>

#define HEADERVIEW_HEIGHT 52
static NSString * const softWareDetailCellReuseIdentifier = @"SoftWareDetailCell";
static NSString * const softWareDetailBodyCellReuseIdentifier = @"SoftWareDetailBodyCell";

@interface SoftWareViewController () <UITableViewDelegate, UITableViewDataSource,SoftWareDetailHeaderViewDelegate,UIWebViewDelegate>

@property (nonatomic,assign) NSInteger id;
@property (nonatomic,strong) NSString* networkURL;
@property (nonatomic, strong) OSCNewSoftWare *model;

@property (nonatomic,weak) MBProgressHUD* HUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SoftWareDetailHeaderView* headerView;
@property (nonatomic,assign) CGFloat webHeight;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;

@end

@implementation SoftWareViewController

-(instancetype)initWithSoftWareID:(NSInteger)softWareID{
    self = [super init];
    if (self) {
        _id = softWareID;
        _networkURL = [NSString stringWithFormat:@"%@software?id=%ld",OSCAPI_V2_HTTPS_PREFIX,(long)_id];
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialized];
    [self sendNetWoringRequest];
    
}
-(void)dealloc{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


-(void)initialized{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"软件详情";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SoftWareDetailCell" bundle:nil] forCellReuseIdentifier:softWareDetailCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SoftWareDetailBodyCell" bundle:nil] forCellReuseIdentifier:softWareDetailBodyCellReuseIdentifier];
}


#pragma mark - Networking method 
-(void)sendNetWoringRequest{
    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:_networkURL parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             NSDictionary* resultDic = responseObject[@"result"];
             _model = [OSCNewSoftWare mj_objectWithKeyValues:resultDic];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 _HUD.hidden = YES;
                 [self.tableView reloadData];
                 [self updateBottomBtns];
             });
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             _HUD.hidden = YES;
    }];
    
}
-(void)sendFavoriteRequest{
    __weak typeof(self) weakSelf = self;

    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    _HUD.mode = MBProgressHUDModeCustomView;
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:[NSString stringWithFormat:@"%@favorite_reverse",OSCAPI_V2_HTTPS_PREFIX]
       parameters:@{
                    @"id"   : @(self.model.id),
                    @"type" : @(1)
                    }
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              NSInteger resultCode = [responseObject[@"code"] intValue];
              if (resultCode == 1) {
                  NSDictionary* resultDic = responseObject[@"result"];
                  NSInteger favoriteCode = [resultDic[@"favorite"] integerValue];
                  weakSelf.model.favorite = favoriteCode == 0 ? NO : YES;
                  _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  _HUD.labelText = weakSelf.model.favorite ? @"添加收藏成功" : @"删除收藏成功" ;
                  [_HUD hide:YES afterDelay:1];
              }else{
                  _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  _HUD.labelText = @"网络异常";
                  [_HUD hide:YES afterDelay:1];
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  [weakSelf updateBottomBtns];
              });
}
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              _HUD.labelText = @"网络异常，操作失败";
              
              [_HUD hide:YES afterDelay:1];}];
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SoftWareDetailCell *softWareCell = [tableView dequeueReusableCellWithIdentifier:softWareDetailCellReuseIdentifier forIndexPath:indexPath];
        if (self.model.logo.length > 0) {
            [softWareCell.softImageView sd_setImageWithURL:[NSURL URLWithString:self.model.logo] placeholderImage:[UIImage imageNamed:@"logo_software_default"]];
        }
        softWareCell.titleLabel.text = self.model.extName;
        softWareCell.tagImageView.hidden = !self.model.recommend;
        softWareCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return softWareCell;
    }else{
        SoftWareDetailBodyCell* cell = [tableView dequeueReusableCellWithIdentifier:softWareDetailBodyCellReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.webView.delegate = self;
        [cell.webView loadHTMLString:self.model.body baseURL:[NSBundle mainBundle].resourceURL];
        
        return cell;
    }
}

#pragma mark - headerView and height method
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return HEADERVIEW_HEIGHT;
    }else{
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return self.headerView;
    }else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 80;
    } else {
        return _webHeight + 30;
    }
}
#pragma mark - WebView delegate 
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webHeight == webViewHeight) {return;}
    _webHeight = webViewHeight;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}


#pragma mark - VC_xib click Button  &&  headerView delegate

-(void)updateBottomBtns{
    [_commentButton setTitle:[NSString stringWithFormat:@"评论（%ld）",self.model.commentCount] forState:UIControlStateNormal];
    UIImage* image = self.model.favorite ? [UIImage imageNamed:@"toolbar-starred"] : [UIImage imageNamed:@"ic_fav_normal"];
    [_collectButton setImage:image forState:UIControlStateNormal];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (IBAction)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 1:{//评论{
            TweetTableViewController* commentVC = [[TweetTableViewController alloc]initWithSoftwareID:self.model.id];
            [self.navigationController pushViewController:commentVC animated:YES];
            break;
        }
            
        case 2:{//收藏
            [self sendFavoriteRequest];
            break;
        }
            
        case 3:{//share按钮
            [self share];
            break;
        }
            
        default:
            break;
    }
    
}

-(void)softWareDetailHeaderViewClickLeft:(SoftWareDetailHeaderView *)headerView{
    [self.navigationController handleURL:[NSURL URLWithString:self.model.homePage]];
}
-(void)softWareDetailHeaderViewClickRight:(SoftWareDetailHeaderView *)headerView{
    [self.navigationController handleURL:[NSURL URLWithString:self.model.document]];
}

#pragma mark --- share method 
-(void)share{
    
    NSString *trimmedHTML = [self.model.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    NSString *digest = [trimmedHTML substringToIndex:length];
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = self.model.href;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.model.href;
    [UMSocialData defaultData].extConfig.title = self.model.extName;
    
    // 手机QQ相关设置
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = self.model.extName;
    //[UMSocialData defaultData].extConfig.qqData.shareText = weakSelf.objectTitle;
    [UMSocialData defaultData].extConfig.qqData.url = self.model.href;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:self.model.href];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"54c9a412fd98c5779c000752"
                                      shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, self.model.href]
                                     shareImage:[UIImage imageNamed:@"logo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}


#pragma mark --- lazy loading
- (SoftWareDetailHeaderView *)headerView {
	if(_headerView == nil) {
		SoftWareDetailHeaderView* headerView = [[SoftWareDetailHeaderView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,HEADERVIEW_HEIGHT}}];
//        headerView.backgroundColor = [UIColor redColor];
        headerView.delegate = self;
        _headerView = headerView;
    }
	return _headerView;
}

@end
