//
//  AccountBindingViewController.m
//  iosapp
//
//  Created by AeternChan on 7/28/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AccountBindingViewController.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCUser.h"
#import "Utils.h"
#import "Config.h"
#import "OSCThread.h"
#import "UIImage+FontAwesome.h"

#import <ReactiveCocoa.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

@interface AccountBindingViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *accountImageView;
@property (nonatomic, weak) IBOutlet UIImageView *passwordImageView;

@property (nonatomic, weak) IBOutlet UITextField *accountField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIButton *bindingButton;

@end

@implementation AccountBindingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    RACSignal *valid = [RACSignal combineLatest:@[_accountField.rac_textSignal, _passwordField.rac_textSignal]
                                         reduce:^(NSString *account, NSString *password) {
                                             return @(account.length > 0 && password.length > 0);
                                         }];
    RAC(_bindingButton, enabled) = valid;
    RAC(_bindingButton, alpha) = [valid map:^(NSNumber *b) {
        return b.boolValue ? @1: @0.4;
    }];
}


#pragma mark - about subviews

- (void)setUpSubviews
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
    
    [_accountField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_passwordField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    
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
        if (_bindingButton.enabled) {
            [self accountBinding];
        }
    }
}



- (IBAction)accountBinding
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_OPENID_BINDING]
       parameters:@{
                    @"catalog": _catalog,
                    @"openid_info": _info,
                    @"username": _accountField.text,
                    @"pwd": _passwordField.text,
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [result firstChildWithTag:@"errorCode"].numberValue.intValue;
              NSString *errorMessage = [result firstChildWithTag:@"errorMessage"].stringValue;
              
              if (errorCode == 1) {
                  ONOXMLElement *userXML = [responseObject.rootElement firstChildWithTag:@"user"];
                  OSCUser *user = [[OSCUser alloc] initWithXML:userXML];
                  
                  [Config saveOwnID:user.userID
                           userName:user.name
                              score:user.score
                      favoriteCount:user.favoriteCount
                          fansCount:user.fansCount
                   andFollowerCount:user.followersCount];
                  
                  [OSCThread startPollingNotice];
                  
                  [self saveCookies];
              } else {
                  MBProgressHUD *hud = [Utils createHUD];
                  hud.mode = MBProgressHUDModeCustomView;
                  hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  hud.detailsLabelText = errorMessage;
                  
                  [hud hide:YES afterDelay:1];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *hud = [Utils createHUD];
              hud.mode = MBProgressHUDModeCustomView;
              hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              hud.labelText = [@(operation.response.statusCode) stringValue];
              hud.detailsLabelText = error.userInfo[NSLocalizedDescriptionKey];
              
              [hud hide:YES afterDelay:1];
          }];
}


#pragma mark - save cookie

- (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


@end
