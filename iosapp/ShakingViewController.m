//
//  ShakingViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ShakingViewController.h"
#import "RandomMessageCell.h"
#import <CoreMotion/CoreMotion.h>
#import "Utils.h"

static const double accelerationThreshold = 2.0f;

@interface ShakingViewController ()

@property (nonatomic, strong) UIView *layer;
@property (nonatomic, strong) RandomMessageCell *cell;
@property CMMotionManager *motionManager;
@property NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL isShaking;

@end

@implementation ShakingViewController

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
    
    self.navigationItem.title = @"摇一摇";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setLayout];
    
    _operationQueue = [NSOperationQueue new];
    _motionManager = [CMMotionManager new];
    _motionManager.accelerometerUpdateInterval = 0.1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startAccelerometer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_motionManager stopAccelerometerUpdates];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setLayout
{
    _layer = [UIView new];
    _layer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_layer];
    
    UIImageView *imageUp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_up"]];
    imageUp.contentMode = UIViewContentModeScaleAspectFill;
    [_layer addSubview:imageUp];
    
    UIImageView *imageDown = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_down"]];
    imageDown.contentMode = UIViewContentModeScaleAspectFill;
    [_layer addSubview:imageDown];
    
#if 1
    _cell = [RandomMessageCell new];
    UITapGestureRecognizer *tapGestureRacognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell)];
    [_cell addGestureRecognizer:tapGestureRacognizer];
    [_cell setHidden:YES];
    [self.view addSubview:_cell];
#endif
    
    for (UIView *view in self.view.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    for (UIView *view in _layer.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_layer, imageUp, imageDown, _cell);
    
    // layer
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[_layer(195)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=50-[_layer(168.75)]->=50-|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_layer
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    
    // imageUp and imageDown
    
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageUp(168.75)]|" options:0 metrics:nil views:views]];
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=1-[imageUp(95.25)][imageDown(95.25)]|"
                                                                   options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                   metrics:nil views:views]];
    
    // cell
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cell(>=60)]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_cell]|" options:0 metrics:nil views:views]];
}

-(void)startAccelerometer
{
    //以push的方式更新并在block中接收加速度
    
    [_motionManager startAccelerometerUpdatesToQueue:_operationQueue
                                         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                             [self outputAccelertionData:accelerometerData.acceleration];
                                         }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    double accelerameter = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2));
    
    if (accelerameter > accelerationThreshold) {
        [_motionManager stopAccelerometerUpdates];
        [_operationQueue cancelAllOperations];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isShaking) {return;}
            _isShaking = YES;
            
            [self rotate:_layer];
            [self startAccelerometer];
#if 0
            if ([Tools isNetworkExist]) {
                [self requestProject];
            } else {
                [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
            }
#endif
            _isShaking = NO;
        });
    }
}

-(void)receiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [_motionManager stopAccelerometerUpdates];
    } else {
        [self startAccelerometer];
    }
}

- (void)rotate:(UIView *)view
{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:M_PI / 3.0];
    rotate.duration = 0.2;
    rotate.repeatCount = 2;
    rotate.autoreverses = YES;
    
    [self setAnchorPoint:CGPointMake(-0.2, 0.9) forView:view];
    //view.layer.anchorPoint = CGPointMake(0, 1);
    
    [view.layer addAnimation:rotate forKey:nil];
}

// 参考 http://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (void)tapCell
{
    
}




@end
