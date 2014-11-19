//
//  DetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "DetailsViewController.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

#import "OSCAPI.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCPost.h"
#import "OSCNewsDetails.h"
#import "OSCBlogDetails.h"
#import "OSCPostDetails.h"
#import "OSCSoftwareDetails.h"
#import "Utils.h"


#define HTML_STYLE @"<style>#oschina_title {color: #000000; margin-bottom: 6px; font-weight:bold;}#oschina_title img{vertical-align:middle;margin-right:6px;}#oschina_title a{color:#0D6DA8;}#oschina_outline {color: #707070; font-size: 12px;}#oschina_outline a{color:#0D6DA8;}#oschina_software{color:#808080;font-size:12px}#oschina_body img {max-width: 300px;}#oschina_body {font-size:16px;max-width:300px;line-height:24px;} #oschina_body table{max-width:300px;}#oschina_body pre { font-size:9pt;font-family:Courier New,Arial;border:1px solid #ddd;border-left:5px solid #6CE26C;background:#f6f6f6;padding:5px;}</style>"

#define HTML_BOTTOM @"<div style='margin-bottom:60px'/>"



@interface DetailsViewController () <UIWebViewDelegate>

@property (nonatomic, strong) OSCNews *news;
@property (nonatomic, copy) NSString *detailsURL;
@property (nonatomic, strong) UIWebView *detailsView;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, assign) SEL loadMethod;
@property (nonatomic, assign) Class detailsClass;

@end

@implementation DetailsViewController

- (instancetype)initWithNews:(OSCNews *)news
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _news = news;
        switch (news.type) {
            case NewsTypeStandardNews:
                self.detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_NEWS_DETAIL, news.newsID];
                self.tag = @"news";
                self.detailsClass = [OSCNewsDetails class];
                self.loadMethod = @selector(loadNewsDetails:);
                break;
            case NewsTypeSoftWare:
                self.detailsURL = [NSString stringWithFormat:@"%@%@?ident=%@", OSCAPI_PREFIX, OSCAPI_SOFTWARE_DETAIL, news.attachment];
                self.tag = @"software";
                self.detailsClass = [OSCSoftwareDetails class];
                self.loadMethod = @selector(loadSoftwareDetails:);
                break;
            case NewsTypeQA:
                self.detailsURL = [NSString stringWithFormat:@"%@%@?id=%@", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, news.attachment];
                self.tag = @"post";
                self.detailsClass = [OSCPostDetails class];
                self.loadMethod = @selector(loadPostDetails:);
                break;
            case NewsTypeBlog:
                self.detailsURL = [NSString stringWithFormat:@"%@%@?id=%@", OSCAPI_PREFIX, OSCAPI_BLOG_DETAIL, news.attachment];
                self.tag = @"blog";
                self.detailsClass = [OSCBlogDetails class];
                self.loadMethod = @selector(loadBlogDetails:);
                break;
            default:
                break;
        }
    }
    
    return self;
}

- (instancetype)initWithBlog:(OSCBlog *)blog
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_BLOG_DETAIL, blog.blogID];
        self.tag = @"blog";
        self.detailsClass = [OSCBlogDetails class];
        self.loadMethod = @selector(loadBlogDetails:);
    }
    
    return self;
}

- (instancetype)initWithPost:(OSCPost *)post
{
    self = [super init];
    if (!self) {return nil;}
    
    self.hidesBottomBarWhenPushed = YES;
    self.detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, post.postID];
    self.tag = @"post";
    self.detailsClass = [OSCPostDetails class];
    self.loadMethod = @selector(loadPostDetails:);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detailsView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.detailsView.scrollView.bounces = NO;
    [self.view addSubview:self.detailsView];
    [self.view bringSubviewToFront:(UIView *)self.bottomBar];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:self.detailsURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             ONOXMLElement *XML = [responseDocument.rootElement firstChildWithTag:self.tag];
             
             id details = [[self.detailsClass alloc] initWithXML:XML];
             [self performSelector:_loadMethod withObject:details];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"网络异常，错误码：%ld", (long)error.code);
         }
     ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




- (void)loadNewsDetails:(OSCNewsDetails *)newsDetails
{NSLog(@"%@", [self.view subviews]);
    NSString *authorStr = [NSString stringWithFormat:@"<a href='http://my.oschina.net/u/%lld'>%@</a> 发布于 %@", _news.authorID, _news.author, _news.pubDate];
    
    NSString *software = @"";
    if ([newsDetails.softwareName isEqualToString:@""] == NO) {
        software = [NSString stringWithFormat:@"<div id='oschina_software' style='margin-top:8px;color:#FF0000;font-size:14px;font-weight:bold'>更多关于:&nbsp;<a href='%@'>%@</a>&nbsp;的详细信息</div>", newsDetails.softwareLink, newsDetails.softwareName];
    }
    
    NSString *html = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr/><div id='oschina_body'>%@</div>%@%@%@</body>", HTML_STYLE, newsDetails.title, authorStr, newsDetails.body, software,[Utils generateRelativeNewsString:newsDetails.relatives], HTML_BOTTOM];
    
    [self.detailsView loadHTMLString:html baseURL:nil];
}

- (void)loadBlogDetails:(OSCBlogDetails *)blogDetails
{
    NSString *authorStr = [NSString stringWithFormat:@"<a href='http://my.oschina.net/u/%lld'>%@</a>&nbsp;发表于&nbsp;%@", blogDetails.authorID, blogDetails.author,  [Utils intervalSinceNow:blogDetails.pubDate]];
    NSString *html = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr/><div id='oschina_body'>%@</div>%@</body>",HTML_STYLE, blogDetails.title, authorStr, blogDetails.body, HTML_BOTTOM];
    
    [self.detailsView loadHTMLString:html baseURL:nil];
}

- (void)loadSoftwareDetails:(OSCSoftwareDetails *)softwareDetails
{
    NSString *titleStr = [NSString stringWithFormat:@"%@ %@", softwareDetails.extensionTitle, softwareDetails.title];
    
    NSString *tail = [NSString stringWithFormat:@"<div><table><tr><td style='font-weight:bold'>授权协议:&nbsp;</td><td>%@</td></tr><tr><td style='font-weight:bold'>开发语言:</td><td>%@</td></tr><tr><td style='font-weight:bold'>操作系统:</td><td>%@</td></tr><tr><td style='font-weight:bold'>收录时间:</td><td>%@</td></tr></table></div>", softwareDetails.license, softwareDetails.language, softwareDetails.os, softwareDetails.recordTime];
    
    NSString *html = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3'>%@<div id='oschina_title'><img src='%@' width='34' height='34'/>%@</div><hr/><div id='oschina_body'>%@</div><div>%@</div>%@%@</body>", HTML_STYLE, softwareDetails.logoURL, titleStr, softwareDetails.body, tail, [self createButtonsWithHomepageURL:softwareDetails.homepageURL andDocumentURL:softwareDetails.documentURL andDownloadURL:softwareDetails.downloadURL], HTML_BOTTOM];
    
    [self.detailsView loadHTMLString:html baseURL:nil];
}

- (NSString *)createButtonsWithHomepageURL:(NSString *)homepageURL andDocumentURL:(NSString *)documentURL andDownloadURL:(NSString *)downloadURL
{
    NSString *strHomePage = @"";
    NSString *strDocument = @"";
    NSString *strDownload = @"";
    
    if ([homepageURL isEqualToString:@""] == NO) {
        strHomePage = [NSString stringWithFormat:@"<a href=%@><input type='button' value='软件首页' style='font-size:14px;'/></a>", homepageURL];
    }
    if ([documentURL isEqualToString:@""] == NO) {
        strDocument = [NSString stringWithFormat:@"<a href=%@><input type='button' value='软件文档' style='font-size:14px;'/></a>", documentURL];
    }
    if ([downloadURL isEqualToString:@""] == NO) {
        strDownload = [NSString stringWithFormat:@"<a href=%@><input type='button' value='软件下载' style='font-size:14px;'/></a>", downloadURL];
    }
    
    return [NSString stringWithFormat:@"<p>%@&nbsp;&nbsp;%@&nbsp;&nbsp;%@</p>", strHomePage, strDocument, strDownload];
}

- (void)loadPostDetails:(OSCPostDetails *)postDetails
{
    NSString *authorStr = [NSString stringWithFormat:@"<a href='http://my.oschina.net/u/%lld'>%@</a> 发布于 %@", postDetails.authorID, postDetails.author, [Utils intervalSinceNow:postDetails.pubDate]];
    
    NSString *html = [NSString stringWithFormat:@"<body style='background-color:#EBEBF3;'>%@<div id='oschina_title'>%@</div><div id='oschina_outline'>%@</div><hr/><div id='oschina_body'>%@</div>%@%@</body>",HTML_STYLE, postDetails.title, authorStr, postDetails.body, [Utils GenerateTags:postDetails.tags], HTML_BOTTOM];
    
    [self.detailsView loadHTMLString:html baseURL:nil];
}







@end
