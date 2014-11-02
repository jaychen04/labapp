//
//  DetailsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "DetailsViewController.h"
#import "OSCAPI.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

@interface DetailsViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSString *detailsURL;
@property (nonatomic, strong) UIWebView *detailsView;

@end

@implementation DetailsViewController

- (instancetype)initWithDetailsType:(DetailsType)type andID:(int64_t)detailsID
{
    self = [super init];
    if (self) {
        switch (type) {
            case DetailsTypeNews:
                self.detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_NEWS_DETAIL, detailsID];
                break;
            case DetailsTypeBlog:
                self.detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_BLOG_DETAIL, detailsID];
                break;
            default:
                self.detailsURL = [NSString stringWithFormat:@"%@%@?ident=%lld", OSCAPI_PREFIX, OSCAPI_SOFTWARE_DETAIL, detailsID];
                break;
        }
        self.detailsView = [UIWebView new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:self.detailsURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         }
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
