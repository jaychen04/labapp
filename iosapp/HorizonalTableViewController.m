//
//  HorizonalTableViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-23.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "HorizonalTableViewController.h"
#import "Utils.h"

@interface HorizonalTableViewController ()

@property (nonatomic, strong) NSArray *controllers;

@end

static NSString *kHorizonalCellID = @"HorizonalCell";

@implementation HorizonalTableViewController

- (instancetype)initWithViewControllers:(NSArray *)controllers
{
    self = [super init];
    if (self) {
        self.controllers = controllers;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollsToTop = NO;
        self.tableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.pagingEnabled = YES;
        self.tableView.backgroundColor = [UIColor themeColor];
        self.tableView.bounces = NO;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kHorizonalCellID];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.controllers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.frame.size.width;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kHorizonalCellID forIndexPath:indexPath];
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    cell.contentView.backgroundColor = [UIColor themeColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIViewController *controller = [self.controllers objectAtIndex:indexPath.row];
    controller.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:controller.view];
    
    return cell;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollStop:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollStop:NO];
}




#pragma mark -

- (void)scrollToViewAtIndex:(NSUInteger)index
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:NO];
}

- (void)scrollStop:(BOOL)didScrollStop
{
    CGFloat horizonalOffset = self.tableView.contentOffset.y;
    CGFloat screenWidth = self.tableView.frame.size.width;
    CGFloat offsetRatio = (NSUInteger)horizonalOffset % (NSUInteger)screenWidth / screenWidth;
    NSUInteger index = horizonalOffset / screenWidth;;
    
    self.scrollView(offsetRatio, index);
    if (didScrollStop) {self.changeIndex(index);}
}




@end
