//
//  ShakingViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ShakingViewController.h"

@interface ShakingViewController ()

@property (nonatomic, strong) UIView *layer;

@end

@implementation ShakingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"摇一摇";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLayout
{
    _layer = [UIView new];
    _layer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_layer];
    
    UIImageView *imageUp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_logo_up"]];
    imageUp.contentMode = UIViewContentModeScaleAspectFill;
    [_layer addSubview:imageUp];
    
    UIImageView *imageDown = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_logo_down"]];
    imageDown.contentMode = UIViewContentModeScaleAspectFill;
    [_layer addSubview:imageDown];
    
    _projectCell = [ProjectCell new];
    UITapGestureRecognizer *tapPC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProjectCell)];
    [_projectCell addGestureRecognizer:tapPC];
    [_projectCell setHidden:YES];
    [self.view addSubview:_projectCell];
    
    for (UIView *view in self.view.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    for (UIView *view in _layer.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_layer, imageUp, imageDown, _projectCell);
    
    // layer
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[_layer(195)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=50-[_layer(168.75)]->=50-|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_layer
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    
    // imageUp and imageDown
    
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=1-[_imageUp(95.25)][_imageDown(95.25)]|"
                                                                   options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                   metrics:nil views:views]];
    
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_imageUp(168.75)]|"
                                                                   options:0 metrics:nil views:views]];
    
    
    // projectCell
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_projectCell(>=81)]|"
                                                                      options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_projectCell]|"
                                                                      options:0 metrics:nil views:views]];
}




@end
