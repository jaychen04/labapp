//
//  ImageViewerController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//


// 参考 https://github.com/bogardon/GGFullscreenImageViewController

#import "ImageViewerController.h"

const double kAnimationDuration = 0.3;

@interface ImageViewerController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation ImageViewerController

#pragma mark - init method

- (instancetype)initWithImageURL:(NSURL *)imageURL thumbnail:(UIImageView *)thumbnail andTapLocation:(CGPoint)location
{
    self = [super init];
    if (!self) {return nil;}
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _thumbnail = thumbnail;
    _location = location;
    
    return self;
}




#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [_imageView addGestureRecognizer:singleTap];
    
    _imageView.userInteractionEnabled = YES;
    self.scrollView.contentSize = _imageView.frame.size;
    [self.scrollView addSubview:_imageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIView *window = [app keyWindow];
    
    _imageView.frame = _thumbnail.frame;
    
    _originalFrame = [self.thumbnail convertRect:self.thumbnail.bounds toView:window];
    _imageView.layer.position = CGPointMake(_originalFrame.origin.x + floorf(_originalFrame.size.width/2), _originalFrame.origin.y + floorf(_originalFrame.size.height/2));
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIApplication *app = [UIApplication sharedApplication];
    UIView *window = [app keyWindow];
    
    CGRect endFrame = [self.view convertRect:self.scrollView.bounds toView:window];
    CABasicAnimation *center = [CABasicAnimation animationWithKeyPath:@"position"];
    center.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    center.toValue = [NSValue valueWithCGPoint:CGPointMake(floorf(endFrame.size.width/2),floorf(endFrame.size.height/2))];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"bounds"];
    scale.fromValue = [NSValue valueWithCGRect:self.imageView.layer.bounds];
    CGSize imageSize = self.thumbnail.image.size;
    CGFloat maxHeight = MIN(endFrame.size.height, endFrame.size.width  * imageSize.height/imageSize.width);
    CGFloat maxWidth  = MIN(endFrame.size.width,  endFrame.size.height * imageSize.width/imageSize.height);
    scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, maxWidth, maxHeight)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.delegate = self;
    group.duration = kAnimationDuration;
    group.animations = @[scale, center];
    [group setValue:@"expand" forKey:@"type"];
    
    [self.imageView.layer addAnimation:group forKey:nil];
    
    _imageView.frame = self.scrollView.bounds;
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = [app keyWindow];
    [window addSubview:self.imageView];
    
    CABasicAnimation *center = [CABasicAnimation animationWithKeyPath:@"position"];
    center.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    center.toValue = [NSValue valueWithCGPoint:CGPointMake(_originalFrame.origin.x + floorf(_originalFrame.size.width/2), _originalFrame.origin.y + floorf(_originalFrame.size.height/2))];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"bounds"];
    scale.fromValue = [NSValue valueWithCGRect:self.imageView.layer.bounds];
    scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, _originalFrame.size.width, _originalFrame.size.height)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.delegate = self;
    group.duration = kAnimationDuration;
    group.animations = @[scale, center];
    [group setValue:@"contract" forKey:@"type"];
    
    self.imageView.layer.position = [center.toValue CGPointValue];
    self.imageView.layer.bounds = [scale.toValue CGRectValue];
    [self.imageView.layer addAnimation:group forKey:nil];
}




#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}




#pragma mark - handle gesture

- (void)handleSingleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    static BOOL zoomOut = NO;
    
    CGFloat power = zoomOut ? 1/self.scrollView.maximumZoomScale : self.scrollView.maximumZoomScale;
    zoomOut = !zoomOut;
    
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    CGFloat newZoomScale = self.scrollView.zoomScale * power;
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = self.scrollView.center.y - (height / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, width, height);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}


#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if ([[anim valueForKey:@"type"] isEqual:@"expand"]) {
        self.thumbnail.hidden = YES;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"type"] isEqual:@"contract"]) {
        self.thumbnail.hidden = NO;
        [self.imageView removeFromSuperview];
    }
}




@end
