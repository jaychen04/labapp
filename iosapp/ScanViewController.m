//
//  ScanViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"

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
    
    [_session startRunning];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    
    [[[UIAlertView alloc] initWithTitle:nil
                                message:stringValue
                               delegate:self
                      cancelButtonTitle:@"确定"
                      otherButtonTitles:nil,nil]
     show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [_session startRunning];
    }
}


@end
