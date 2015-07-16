//
//  UIViewController+Segue.m
//  iosapp
//
//  Created by AeternChan on 7/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "UIViewController+Segue.h"
#import "SearchViewController.h"

@implementation UIViewController (Segue)

- (IBAction)pushSearchViewController:(id)sender
{
    [self.navigationController pushViewController:[SearchViewController new] animated:YES];
}
@end
