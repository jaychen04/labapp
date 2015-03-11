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
#import "MyInfoViewController.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import <RESideMenu.h>

@interface LoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"登录";
    self.view.backgroundColor = [UIColor themeColor];
    
    [self initSubviews];
    [self setLayout];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - about subviews
- (void)initSubviews
{
    _accountField = [UITextField new];
    _accountField.placeholder = @"Email";
    _accountField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    _accountField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _accountField.keyboardType = UIKeyboardTypeEmailAddress;
    _accountField.delegate = self;
    _accountField.returnKeyType = UIReturnKeyNext;
    _accountField.enablesReturnKeyAutomatically = YES;
    
    self.passwordField = [UITextField new];
    _passwordField.placeholder = @"Password";
    _passwordField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    _passwordField.secureTextEntry = YES;
    _passwordField.delegate = self;
    _passwordField.returnKeyType = UIReturnKeyDone;
    _passwordField.enablesReturnKeyAutomatically = YES;
    
    [_accountField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_passwordField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.view addSubview: _accountField];
    [self.view addSubview: _passwordField];
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginButton.titleLabel.font = [UIFont systemFontOfSize:17];
    _loginButton.backgroundColor = [UIColor redColor];
    [_loginButton setCornerRadius:5.0];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _loginButton];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
}

- (void)setLayout
{
    UIImageView *loginLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo"]];
    loginLogo.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImageView *email = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email"]];
    email.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImageView *password = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    password.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:loginLogo];
    [self.view addSubview:email];
    [self.view addSubview:password];
    
    for (UIView *view in [self.view subviews]) { view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(loginLogo, email, password, _accountField, _passwordField, _loginButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[loginLogo(90)]-25-[email(20)]-20-[password(20)]" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=50-[loginLogo(90)]->=50-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginLogo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[email(20)]-[_accountField]-30-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[password(20)]-[_passwordField]-30-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[password]->=20-[_loginButton(35)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_passwordField]-30-[_loginButton]" options:NSLayoutFormatAlignAllRight metrics:nil views:views]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![_accountField isFirstResponder] && ![_passwordField isFirstResponder]) {
        return NO;
    }
    return YES;
}


#pragma mark - 键盘操作

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat y = -50;
    CGRect rect = CGRectMake(0.0f, y, width, height);
    self.view.frame = rect;
    
    [UIView commitAnimations];
    
    return YES;
}

- (void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGRect rect  =CGRectMake(0.0f, 64, width, height);
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)hidenKeyboard
{
    [_accountField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [self resumeView];
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    _loginButton.enabled = NO;
    return YES;
}

//点击键盘上的Return按钮响应的方法
- (void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == _accountField) {
        [_passwordField becomeFirstResponder];
    }else if (sender == _passwordField) {
        [self hidenKeyboard];
        if (_loginButton.enabled) {
            [self login];
        }
    }
}

- (void)login
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_LOGIN_VALIDATE]
       parameters:@{@"username" : _accountField.text, @"pwd" : _passwordField.text, @"keep_login" : @(1)}
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              ONOXMLElement *userXML = [responseObject.rootElement firstChildWithTag:@"user"];
              
              NSInteger errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] integerValue];
              if (!errorCode) {
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  MBProgressHUD *HUD = [Utils createHUDInWindowOfView:self.view];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  [HUD hide:YES afterDelay:1];
                  
                  return;
              }
              
              OSCUser *user = [[OSCUser alloc] initWithXML:userXML];
              [Config saveOwnAccount:_accountField.text andPassword:_passwordField.text];
              [Config saveOwnUserName:user.name andUserScore:user.score andUserFavoriteCount:user.favoriteCount andUserFans:user.fansCount andUserFollower:user.followersCount andOwnID:user.userID];
              [OSCThread startPollingNotice];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
              [self.navigationController popViewControllerAnimated:YES];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"网络异常，错误码：%ld", (long)error.code);
          }
     ];
}



@end
