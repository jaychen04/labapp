//
//  ShakingViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ShakingViewController.h"
#import "OSCRandomMessage.h"
#import "RandomMessageCell.h"
#import "Utils.h"
#import "OSCAPI.h"
#import <CoreMotion/CoreMotion.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "DetailsViewController.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCSoftware.h"

static const double accelerationThreshold = 2.0f;

@interface ShakingViewController ()

@property (nonatomic, strong) OSCRandomMessage *randomMessage;
@property (nonatomic, strong) UIImageView *layer;
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
    if (self.navigationController.viewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    }
    
    [self setLayout];
    
    _operationQueue = [NSOperationQueue new];
    _motionManager = [CMMotionManager new];
    _motionManager.accelerometerUpdateInterval = 0.1;
}

- (void)backButtonClick
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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



#pragma mark - 视图布局

- (void)setLayout
{
    _layer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake"]];
    _layer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_layer];
    
    _cell = [RandomMessageCell new];
    [_cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)]];
    _cell.hidden = YES;
    [self.view addSubview:_cell];
    
    for (UIView *view in self.view.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    for (UIView *view in _layer.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_layer, _cell);
    
    // layer
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_layer(195)]-200-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=50-[_layer(168.75)]->=50-|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_layer
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    // cell
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cell(70)]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_cell]|" options:0 metrics:nil views:views]];
}


#pragma mark - 监听动作

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
            [self getRandomMessage];
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



#pragma mark - 动画效果

- (void)rotate:(UIView *)view
{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:M_PI / 3.0];
    rotate.duration = 0.2;
    rotate.repeatCount = 2;
    rotate.autoreverses = YES;
    
    [self setAnchorPoint:CGPointMake(-0.2, 0.9) forView:view];
    
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



#pragma mark - 获取数据

- (void)getRandomMessage
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_RANDOM_MESSAGE]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _randomMessage = [[OSCRandomMessage alloc] initWithXML:responseObject.rootElement];
             [_cell setContentWithMessage:_randomMessage];
             _cell.hidden = NO;
             
             [self startAccelerometer];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUDInWindowOfView:self.view];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，请检测网络";
             
             [HUD hide:YES afterDelay:2];
             
             [self startAccelerometer];
         }];
}




#pragma mark - 响应点击事件

- (void)tapCell:(UITapGestureRecognizer *)recognizer
{
    switch (_randomMessage.type) {
        case RandomTypeNews: {
            OSCNews *news = [OSCNews new];
            news.newsID = _randomMessage.randomMessageID;
            [self.navigationController pushViewController:[[DetailsViewController alloc] initWithNews:news] animated:YES];
            break;
        }
        case RandomTypeBlog: {
            OSCBlog *blog = [OSCBlog new];
            blog.blogID = _randomMessage.randomMessageID;
            [self.navigationController pushViewController:[[DetailsViewController alloc] initWithBlog:blog] animated:YES];
            break;
        }
        case RandomTypeSoftware: {
            [Utils analysis:_randomMessage.url.absoluteString andNavController:self.navigationController];
            break;
        }
        default:
            break;
    }
    
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:_layer];
}




@end
