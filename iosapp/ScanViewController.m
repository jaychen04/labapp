//
//  ScanViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ScanViewController.h"
#import "Utils.h"
#import "Config.h"

#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>


@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@end

@implementation ScanViewController

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
    
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    
    [self setUpCamera];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setScanRegion];
    [_session startRunning];
}

- (void)cancelButtonClicked
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpCamera
{
    _device  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input   = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    _output  = [AVCaptureMetadataOutput new];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [AVCaptureSession new];
    [_session addInput:_input];
    [_session addOutput:_output];
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_preview setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:_preview];
}

- (void)setScanRegion
{
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
    overlayImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:overlayImageView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view        attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:overlayImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view        attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:overlayImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    
    _output.rectOfInterest = CGRectMake((screenHeight - 200) / 2 / screenHeight,
                                        (screenWidth  - 260) / 2 / screenWidth,
                                        200 / screenHeight,
                                        260 / screenWidth);
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *message;
    
    if (metadataObjects.count > 0) {
        [_session stopRunning];
        
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        
        message = metadataObject.stringValue;
        
        if ([message hasPrefix:@"{"]) {
            if ([Config getOwnID] == 0) {
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                HUD.labelText = @"您还没登录，请先登录再扫描签到";
                
                [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                [HUD hide:YES afterDelay:2];
                
                return;
            }
            
            NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSNumber *requireLogin = json[@"require_login"];
            NSString *title = json[@"title"];
            NSNumber *type = json[@"type"];
            NSString *URL = json[@"url"];
            
            if (!requireLogin || !title || !type || !URL) {
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                HUD.labelText = @"无效二维码";
                
                [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                [HUD hide:YES afterDelay:2];
                
                return;
            }
            
            if ([type intValue] != 1) {
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = title;
                
                [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                [HUD hide:YES afterDelay:2];
            } else {
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                
                [manager GET:URL
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                         MBProgressHUD *HUD = [Utils createHUD];
                         HUD.mode = MBProgressHUDModeCustomView;
                         
                         NSString *message = responseObject[@"msg"];
                         NSString *error   = responseObject[@"error"];
                         
                         if (message) {
                             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                             HUD.labelText = message;
                         } else {
                             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                             HUD.labelText = error;
                         }
                         
                         [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                         [HUD hide:YES afterDelay:2];
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       MBProgressHUD *HUD = [Utils createHUD];
                       HUD.mode = MBProgressHUDModeCustomView;
                       HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                       HUD.labelText = @"网络连接故障";
                       
                       [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
                       [HUD hide:YES afterDelay:2];
                }];
            }
        } else if ([Utils isURL:message]) {
            [Utils analysis:message andNavController:self.navigationController];
        } else {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeText;
            HUD.detailsLabelText = message;
            
            [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
            [HUD hide:YES afterDelay:2];
        }
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



@end
