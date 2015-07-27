//
//  LoginViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/4/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "LoginViewController.h"
#import "UserDetailsViewController.h"
#import "OSCAPI.h"
#import "OSCUser.h"
#import "Utils.h"
#import "Config.h"
#import "OSCThread.h"

#import "UIImage+FontAwesome.h"


#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import <RESideMenu.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <WeiboSDK.h>
#import "WXApi.h"


@interface LoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, TencentSessionDelegate>

@property (nonatomic, weak) IBOutlet UITextField *accountField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@property (nonatomic, weak) IBOutlet UIImageView *accountImageView;
@property (nonatomic, weak) IBOutlet UIImageView *passwordImageView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation LoginViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor themeColor];
    
    [self initSubviews];
    
    NSArray *accountAndPassword = [Config getOwnAccountAndPassword];
    _accountField.text = accountAndPassword? accountAndPassword[0] : @"";
    _passwordField.text = accountAndPassword? accountAndPassword[1] : @"";
    
    RACSignal *valid = [RACSignal combineLatest:@[_accountField.rac_textSignal, _passwordField.rac_textSignal]
                                         reduce:^(NSString *account, NSString *password) {
                                             return @(account.length > 0 && password.length > 0);
                                         }];
    RAC(_loginButton, enabled) = valid;
    RAC(_loginButton, alpha) = [valid map:^(NSNumber *b) {
        return b.boolValue ? @1: @0.4;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_HUD hide:YES];
}



#pragma mark - about subviews
- (void)initSubviews
{
    _accountImageView.image = [UIImage imageWithIcon:@"fa-envelope-o"
                                     backgroundColor:[UIColor clearColor]
                                           iconColor:[UIColor grayColor]
                                             andSize:CGSizeMake(20, 20)];
    
    _passwordImageView.image = [UIImage imageWithIcon:@"fa-lock"
                                      backgroundColor:[UIColor clearColor]
                                            iconColor:[UIColor grayColor]
                                              andSize:CGSizeMake(20, 20)];
    
    
    _accountField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    _accountField.delegate = self;
    
    _passwordField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    _passwordField.delegate = self;
    
    [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![_accountField isFirstResponder] && ![_passwordField isFirstResponder]) {
        return NO;
    }
    return YES;
}


#pragma mark - 第三方登录
#pragma mark QQ登录

- (IBAction)loginFromQQ:(id)sender
{
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"100942993" andDelegate:self];
    [_tencentOAuth authorize:@[kOPEN_PERMISSION_GET_USER_INFO]];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"登录失败");
}

- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && [_tencentOAuth.accessToken length]) {
        NSLog(@"%@", _tencentOAuth);
    } else {
//        _labelAccessToken.text = @"登录不成功 没有获取accesstoken";
    }
    NSLog(@"success");
}

- (void)tencentDidNotNetWork
{
    NSLog(@"没有网络");
}

#pragma mark 微信登录

- (IBAction)loginFromWechat:(id)sender
{
    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"osc_wechat_login" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}



#pragma mark 微博登录

- (IBAction)loginFromWeibo:(id)sender
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://sns.whalecloud.com/sina2/callback";
    request.scope = @"all";
    
    [WeiboSDK sendRequest:request];
}


#pragma mark - 键盘操作

- (void)hidenKeyboard
{
    [_accountField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

- (void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == _accountField) {
        [_passwordField becomeFirstResponder];
    } else if (sender == _passwordField) {
        [self hidenKeyboard];
        if (_loginButton.enabled) {
            [self login];
        }
    }
}

- (void)login
{
    _HUD = [Utils createHUD];
    _HUD.labelText = @"正在登录";
    _HUD.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_LOGIN_VALIDATE]
       parameters:@{@"username" : _accountField.text, @"pwd" : _passwordField.text, @"keep_login" : @(1)}
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              ONOXMLElement *userXML = [responseObject.rootElement firstChildWithTag:@"user"];
              
              NSInteger errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] integerValue];
              if (!errorCode) {
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  _HUD.mode = MBProgressHUDModeCustomView;
                  _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  _HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  [_HUD hide:YES afterDelay:1];
                  
                  return;
              }
              
              OSCUser *user = [[OSCUser alloc] initWithXML:userXML];
              [Config saveOwnAccount:_accountField.text andPassword:_passwordField.text];
              [Config saveOwnID:user.userID userName:user.name score:user.score favoriteCount:user.favoriteCount fansCount:user.fansCount andFollowerCount:user.followersCount];
              [OSCThread startPollingNotice];
              
              [self saveCookies];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
              [self.navigationController popViewControllerAnimated:YES];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              _HUD.mode = MBProgressHUDModeCustomView;
              _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              _HUD.labelText = @"网络异常，登录失败";
              
              [_HUD hide:YES afterDelay:1];
          }
     ];
}



/*** 不知为何有时退出应用后，cookie不保存，所以这里手动保存cookie ***/

- (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
    
}



@end
