//
//  AccountOperationViewController.m
//  iosapp
//
//  Created by AeternChan on 7/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AccountOperationViewController.h"
#import "AccountBindingViewController.h"
#import "OSCAPI.h"
#import "OSCUser.h"
#import "Utils.h"
#import "Config.h"
#import "OSCThread.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

#import <MBProgressHUD.h>

@interface AccountOperationViewController ()

@property (nonatomic, weak) IBOutlet UILabel *greetingLabel;

@end

@implementation AccountOperationViewController

- (IBAction)createAcount:(id)sender
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_OPENID_REGISTER]
       parameters:@{
                    @"catalog": _catalog,
                    @"openid_info": _info,
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
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
                  [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count-3]
                                                        animated:YES];
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
    AccountBindingViewController *accountBindingVC = segue.destinationViewController;
    accountBindingVC.catalog = _catalog;
    accountBindingVC.info = _info;
    
}


@end
