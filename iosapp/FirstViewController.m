//
//  FirstViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-13.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "FirstViewController.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

@interface FirstViewController ()

@property (nonatomic, strong) NSMutableArray *tweets;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //self.tweets = [NSMutableArray new];
    //NSLog(@"self.tweets的应用计数:%ld", CFGetRetainCount((__bridge CFTypeRef)self.tweets));
    //NSLog(@"_tweets的应用计数:%ld", CFGetRetainCount((__bridge CFTypeRef)_tweets));
#if 0
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager GET:@"http://www.oschina.net/action/api/tweet_list?uid=0&pageIndex=0&pageSize=20"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             NSArray *tweets = [[responseDocument.rootElement firstChildWithTag:@"tweets"] childrenWithTag:@"tweet"];
             //NSLog(@"%@", tweets);
             for (ONOXMLElement *tweet in tweets) {
                 NSLog(@"%@", [[tweet firstChildWithTag:@"id"] numberValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"portrait"] stringValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"body"] stringValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"authorid"] numberValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"author"] stringValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"commentCount"] numberValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"pubDate"] stringValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"imgSmall"] stringValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"imgBig"] stringValue]);
                 NSLog(@"%@", [[tweet firstChildWithTag:@"attach"] stringValue]);
                 NSLog(@"%@\n", [[tweet firstChildWithTag:@"appclient"] stringValue]);
             }
         }
         failure:nil];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
