//
//  OSCActivityViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityViewController.h"
#import "OSCActivityTableViewCell.h"
#import "SDCycleScrollView.h"

#define OSC_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define OSC_BANNER_HEIGHT 215

static NSString * const activityReuseIdentifier = @"OSCActivityTableViewCellReuseIdenfitier";

@interface OSCActivityViewController ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate>
@property (nonatomic,strong) SDCycleScrollView* bannerView;

@end

@implementation OSCActivityViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self layoutUI];
}


#pragma mark - layout UI
-(void)layoutUI{
    self.tableView.tableHeaderView = self.bannerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - tableView datasource && delegate 
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}
-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCActivityTableViewCell* cell = [OSCActivityTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:activityReuseIdentifier];
    
    return cell;
}


#pragma mark - 生成bannerItem View 并转换成最终的UIImage
-(UIImage* )mapBannerItem:(id)model{
    
    
    return [self imageWithUIView:nil];
}

#pragma mark - UIView 通过Graphics 转换成 UIImage

-(UIImage*)imageWithUIView:(UIView*) view{
    UIGraphicsBeginImageContext(view.bounds.size);
    
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - lazy laoding

- (SDCycleScrollView *)bannerView {
	if(_bannerView == nil) {
        _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:(CGRect){{0,0},{OSC_SCREEN_WIDTH,OSC_BANNER_HEIGHT}} delegate:self placeholderImage:[UIImage imageNamed:@""]];

    }
	return _bannerView;
}

@end
