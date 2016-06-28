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

#import "OSCAPI.h"
#import "Utils.h"
#import "OSCNewSoftWare.h"

#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <MJExtension.h>

static NSString * const softWareDetailCellReuseIdentifier = @"SoftWareDetailCell";
static NSString * const softWareDetailBodyCellReuseIdentifier = @"SoftWareDetailBodyCell";

@interface SoftWareViewController () <UITableViewDelegate, UITableViewDataSource,SoftWareDetailHeaderViewDelegate,UIWebViewDelegate>

@property (nonatomic,assign) NSInteger id;
@property (nonatomic,strong) NSString* networkURL;
@property (nonatomic, strong) OSCNewSoftWare *model;

@property (nonatomic,weak) MBProgressHUD* HUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) SoftWareDetailHeaderView* headerView;
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

-(void)initialized{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"软件详情";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
             });
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
    }];
    
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
        
        return softWareCell;
    }else{
        SoftWareDetailBodyCell* cell = [tableView dequeueReusableCellWithIdentifier:softWareDetailBodyCellReuseIdentifier forIndexPath:indexPath];
        cell.webView.delegate = self;
        [cell.webView loadHTMLString:self.model.body baseURL:[NSBundle mainBundle].resourceURL];
        
        return cell;
    }
}

#pragma mark - headerView and height method
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 82;
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
    if (indexPath.row == 0) {
        return 80;
    } else {
        return _webHeight + 40;
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

- (IBAction)buttonClick:(UIButton *)sender {
    
}

-(void)softWareDetailHeaderViewClickLeft:(SoftWareDetailHeaderView *)headerView{

}
-(void)softWareDetailHeaderViewClickRight:(SoftWareDetailHeaderView *)headerView{

}

#pragma mark --- lazy loading
- (SoftWareDetailHeaderView *)headerView {
	if(_headerView == nil) {
		SoftWareDetailHeaderView* headerView = [[SoftWareDetailHeaderView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,82}}];
        headerView.delegate = self;
        _headerView = headerView;
    }
	return _headerView;
}

@end
