//
//  PersonSearchViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/26/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "PersonSearchViewController.h"

@interface PersonSearchViewController () <UISearchResultsUpdating>

@end

@implementation PersonSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchResultsUpdater = self;
    self.dimsBackgroundDuringPresentation = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
