//
//  AccountOperationViewController.m
//  iosapp
//
//  Created by AeternChan on 7/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AccountOperationViewController.h"
#import "AccountBindingViewController.h"

@interface AccountOperationViewController ()

@property (nonatomic, weak) IBOutlet UILabel *greetingLabel;
@property (nonatomic, weak) IBOutlet UIButton *bindingAccountButton;
@property (nonatomic, weak) IBOutlet UIButton *createAccountButton;

@end

@implementation AccountOperationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)createAcount:(id)sender
{
    
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AccountBindingViewController *accountBindingVC = segue.destinationViewController;
    accountBindingVC.catalog = _catalog;
    accountBindingVC.info = _info;
    
}


@end
