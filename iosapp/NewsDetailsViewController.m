//
//  NewsDetailsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "NewsDetailsViewController.h"
#import "OSCNews.h"
#import "OSCNewsDetails.h"
#import "Utils.h"
#import "OSCAPI.h"
#import <AFNetworking.h>
#import <Ono.h>
#import <AFOnoResponseSerializer.h>

#define HTML_STYLE @"<style>#oschina_title {color: #000000; margin-bottom: 6px; font-weight:bold;}#oschina_title img{vertical-align:middle;margin-right:6px;}#oschina_title a{color:#0D6DA8;}#oschina_outline {color: #707070; font-size: 12px;}#oschina_outline a{color:#0D6DA8;}#oschina_software{color:#808080;font-size:12px}#oschina_body img {max-width: 300px;}#oschina_body {font-size:16px;max-width:300px;line-height:24px;} #oschina_body table{max-width:300px;}#oschina_body pre { font-size:9pt;font-family:Courier New,Arial;border:1px solid #ddd;border-left:5px solid #6CE26C;background:#f6f6f6;padding:5px;}</style>"
#define HTML_BOTTOM @"<div style='margin-bottom:60px'/>"

@interface NewsDetailsViewController ()

@property (nonatomic, strong) OSCNews *news;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation NewsDetailsViewController

- (instancetype)initWithNews:(OSCNews *)news
{
    self = [super init];
    
    if (self) {
        self.news = news;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.scrollView.bounces = NO;
    [self.view addSubview:self.webView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_NEWS_DETAIL, _news.newsID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             ONOXMLElement *newsXML = [responseDocument.rootElement firstChildWithTag:@"news"];
             OSCNewsDetails *newsDetails = [[OSCNewsDetails alloc] initWithXML:newsXML];
             [self loadNewsDetails:newsDetails];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"网络异常，错误码：%ld", (long)error.code);
         }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)loadNewsDetails:(OSCNewsDetails *)newsDetails
{
    NSString *authorStr = [NSString stringWithFormat:@"<a href='http://my.oschina.net/u/%lld'>%@</a> 发布于 %@", self.news.authorID, self.news.author, self.news.pubDate];
    
    NSString *software = @"";
    if ([newsDetails.softwareName isEqualToString:@""] == NO) {
        software = [NSString stringWithFormat:@"<div id='oschina_software' style='margin-top:8px;color:#FF0000;font-size:14px;font-weight:bold'>更多关于:&nbsp;<a href='%@'>%@</a>&nbsp;的详细信息</div>", newsDetails.softwareLink, newsDetails.softwareName];
    }
    
    NSString *html = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr/><div id='oschina_body'>%@</div>%@%@%@</body>",HTML_STYLE, newsDetails.title, authorStr, newsDetails.body, software,[Utils generateRelativeNewsString:newsDetails.relatives], HTML_BOTTOM];
    
    [self.webView loadHTMLString:html baseURL:nil];
}



@end
