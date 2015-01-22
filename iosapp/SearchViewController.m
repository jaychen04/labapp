//
//  SearchViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/22/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "Utils.h"

@interface SearchViewController () <UISearchBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SearchViewController

- (instancetype)init
{
    self = [super initWithTitle:nil
                   andSubTitles:@[@"软件", @"问答", @"博客", @"新闻"]
                 andControllers:@[
                                  [[SearchResultsViewController alloc] initWithType:@"software"],
                                  [[SearchResultsViewController alloc] initWithType:@"post"],
                                  [[SearchResultsViewController alloc] initWithType:@"blog"],
                                  [[SearchResultsViewController alloc] initWithType:@"news"]
                                  ]];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar = [UISearchBar new];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"请输入关键字";
    _searchBar.tintColor = [UIColor colorWithHex:0x15A230];
    
    self.navigationItem.titleView = _searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBar.text.length == 0) {return;}
    
    [searchBar resignFirstResponder];
    
    for (SearchResultsViewController *searchVC in self.viewPager.childViewControllers) {
        searchVC.keyword = searchBar.text;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}






@end
