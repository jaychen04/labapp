//
//  TweetDetailNewTableViewController.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetDetailNewTableViewController.h"
#import "UIColor+Util.h"
#import <UITableView+FDTemplateLayoutCell.h>
//#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCTweet.h"
#import "UserDetailsViewController.h"
#import "ImageViewerController.h"
#import "UserDetailsViewController.h"
#import "Config.h"
#import "OSCUser.h"
#import "OSCComment.h"
#import "NSString+FontAwesome.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>



#import "TweetsDetailNewCell.h"
#import "TweetLikeNewCell.h"
#import "TweetCommentNewCell.h"

static NSString * const tDetailReuseIdentifier = @"TweetsDetailTableViewCell";
static NSString * const tLikeReuseIdentifier = @"TweetLikeTableViewCell";
static NSString * const tCommentReuseIdentifier = @"TweetCommentTableViewCell";

@interface TweetDetailNewTableViewController ()<UIWebViewDelegate>
@property (nonatomic, strong)UIView *headerView;
@property (nonatomic)BOOL isShowCommentList;
//@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong)NSMutableArray *tweetLikeList;
@property (nonatomic, strong)NSMutableArray *tweetCommentList;
@property (nonatomic)NSInteger likeListPage;
@property (nonatomic)NSInteger commentListPage;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) OSCTweet *tweet;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) MBProgressHUD *HUD;
@end

@implementation TweetDetailNewTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetsDetailNewCell" bundle:nil] forCellReuseIdentifier:tDetailReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetLikeNewCell" bundle:nil] forCellReuseIdentifier:tLikeReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCommentNewCell" bundle:nil] forCellReuseIdentifier:tCommentReuseIdentifier];
    self.tableView.tableFooterView = [UIView new];
    
    _tweetLikeList = [NSMutableArray new];
    _tweetCommentList = [NSMutableArray new];
    _label = [[UILabel alloc]init];
    _label.numberOfLines = 0;
    
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadTweetLikeListIsrefresh:NO];
        [self loadTweetCommentListIsrefresh:NO];
    }];
    [self loadTweetDetails];
    [self loadTweetLikeListIsrefresh:YES];
    [self loadTweetCommentListIsrefresh:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- headerView
- (UIView*) headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,40}}];
        _headerView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
        
        for (int k=0; k<2; k++) {
            UIButton* subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            subBtn.tag = k+1;
            NSString* likeBtnTitle = subBtn.tag==1?@"赞":@"评论";
            BOOL isSelected = subBtn.tag==1;
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:likeBtnTitle isSelected:isSelected];
            [subBtn setAttributedTitle:att forState:UIControlStateNormal];
            
            [subBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat btnWidth = _headerView.bounds.size.width/2;
            subBtn.frame = (CGRect){{btnWidth*k,0},{btnWidth,40}};
            [_headerView addSubview:subBtn];
        }

    }
    return _headerView;
}
-(NSMutableAttributedString*)getSubBtnAttributedStringWithTitle:(NSString*)title isSelected:(BOOL)isSelected {
    NSMutableAttributedString* attributedStrNormal = [[NSMutableAttributedString alloc]initWithString:title];
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    UIColor *currentColor = isSelected?[UIColor colorWithHex:0x24cf5f]:[UIColor colorWithHex:0x6a6a6a];
    [attributedStrNormal setAttributes:@{NSForegroundColorAttributeName:currentColor,NSFontAttributeName:font} range:(NSRange){0,title.length}];
    return attributedStrNormal;
}


-(void)clickBtn:(UIButton*)btn {
    if (btn.tag == 1) { //赞
        _isShowCommentList = NO;
        NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:@"赞" isSelected:YES];
        [btn setAttributedTitle:att forState:UIControlStateNormal];
        
        NSMutableAttributedString *attr = [self getSubBtnAttributedStringWithTitle:@"评论" isSelected:NO];
        [((UIButton*)[_headerView viewWithTag:2]) setAttributedTitle:attr forState:UIControlStateNormal];
    }else if (btn.tag == 2) {     //评论
        _isShowCommentList = YES;
        NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:@"评论" isSelected:YES];
        [btn setAttributedTitle:att forState:UIControlStateNormal];
        
        NSMutableAttributedString *attr = [self getSubBtnAttributedStringWithTitle:@"赞" isSelected:NO];
        [((UIButton*)[_headerView viewWithTag:1]) setAttributedTitle:attr forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}
- (void)loadTweetDetails
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_TWEET_DETAIL, _tweetID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *tweetDetailsXML = [responseObject.rootElement firstChildWithTag:@"tweet"];
             
             if (!tweetDetailsXML || tweetDetailsXML.children.count <= 0) {
                 [self.navigationController popViewControllerAnimated:YES];
             } else {
                 _tweet = [[OSCTweet alloc] initWithXML:tweetDetailsXML];
//                 self.objectAuthorID = _tweet.authorID;
                 NSDictionary *data = @{
                                        @"content": _tweet.body,
                                        @"imageURL": _tweet.bigImgURL.absoluteString,
                                        @"audioURL": _tweet.attach ?: @"",
                                        @"newTweetBgColor":@(YES)
                                        };
                 
                 _tweet.body = [Utils HTMLWithData:data usingTemplate:@"newTweet"];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_HUD hide:YES];
         }];
}
-(void)loadTweetLikeListIsrefresh:(BOOL)isRefresh {
    if (isRefresh) {
        _likeListPage = 0;
    }
    NSDictionary *paraDic = @{@"tweetid":@(_tweetID),
                              @"pageIndex":@(_likeListPage),
                              @"pageSize":@(20)
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE_LIST]
       parameters:paraDic
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
              NSArray *objectsXML = [[responseDocument.rootElement firstChildWithTag:@"likeList"] childrenWithTag:@"user"];
              if (isRefresh && objectsXML.count > 0) {
                  [_tweetLikeList removeAllObjects];
              }
              
              if (objectsXML.count == 0) {
                  
              }else {
                  if (objectsXML.count < 20) {
                      [self.tableView.mj_footer endRefreshingWithNoMoreData];
                  }else {
                      _likeListPage++;
                  }
                  for (ONOXMLElement *objectXML in objectsXML) {
                      OSCUser *obj = [[OSCUser alloc] initWithXML:objectXML];
                      [_tweetLikeList addObject:obj];
                  }
              }
              
              if (self.tableView.mj_footer.isRefreshing) {
                  [self.tableView.mj_footer endRefreshing];
              }
              if (!_isShowCommentList) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self networkingError:error];
          }
     ];
}
-(void)loadTweetCommentListIsrefresh:(BOOL)isRefresh {
    if (isRefresh) {
        _commentListPage = 0;
    }
    NSDictionary *paraDic = @{@"id":@(_tweetID),
                              @"catalog":@(3),
                              @"pageIndex":@(_commentListPage),
                              @"pageSize":@(20)
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENTS_LIST]
      parameters:paraDic
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             NSArray *objectsXML = [[responseDocument.rootElement firstChildWithTag:@"comments"] childrenWithTag:@"comment"];
             if (isRefresh && objectsXML.count > 0) {
                 [_tweetCommentList removeAllObjects];
             }
             
             if (objectsXML.count == 0) {
                 
             }else {
                 if (objectsXML.count < 20) {
                     [self.tableView.mj_footer endRefreshingWithNoMoreData];
                 }else {
                     _commentListPage++;
                 }
                 for (ONOXMLElement *objectXML in objectsXML) {
                     OSCComment *obj = [[OSCComment alloc] initWithXML:objectXML];
                     [_tweetCommentList addObject:obj];
                 }
             }
             if (self.tableView.mj_footer.isRefreshing) {
                 [self.tableView.mj_footer endRefreshing];
             }
             if (_isShowCommentList) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self networkingError:error];
         }
     ];
}
-(void)networkingError:(NSError*)error {
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
    HUD.detailsLabelText = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
    [HUD hide:YES afterDelay:1];
    
    if (self.tableView.mj_footer.isRefreshing) {
        [self.tableView.mj_footer endRefreshing];
    }
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }else if (section==1) {
        return _isShowCommentList?_tweetCommentList.count:_tweetLikeList.count;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0:40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [tableView fd_heightForCellWithIdentifier:tDetailReuseIdentifier configuration:^(TweetsDetailNewCell *cell) {
        }] + _webViewHeight + 10;
    }else if (indexPath.section == 1) {
        if (!_isShowCommentList) {
            return 56;
        }else {
            
            OSCComment *comment = self.tweetCommentList[indexPath.row];
            
            if (comment.cellHeight) {return comment.cellHeight;}
            
            self.label.font = [UIFont boldSystemFontOfSize:14];
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.content]];
            if (comment.replies.count > 0) {
                [contentString appendAttributedString:[OSCComment attributedTextFromReplies:comment.replies]];
            }
            
            self.label.font = [UIFont boldSystemFontOfSize:15];
            [self.label setAttributedText:contentString];
            __block CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;
            
            
            CGFloat width = self.tableView.frame.size.width - 60;
            NSArray *references = comment.references;
            if (references.count > 0) {height += 3;}
            
            self.label.font = [UIFont systemFontOfSize:13];
            [references enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OSCReference *reference, NSUInteger idx, BOOL *stop) {
                self.label.text = [NSString stringWithFormat:@"%@\n%@", reference.title, reference.body];
                height += [self.label sizeThatFits:CGSizeMake(width - (references.count-idx)*8, MAXFLOAT)].height + 13;
            }];
            comment.cellHeight = height + 61;
            return comment.cellHeight;
            
            
            
//            return [tableView fd_heightForCellWithIdentifier:tCommentReuseIdentifier configuration:^(TweetCommentNewCell *cell) {
//                cell.commentModel = _tweetCommentList[indexPath.row];
//            }];
        }
    }
    return 0;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TweetsDetailNewCell *detailCell = [self.tableView dequeueReusableCellWithIdentifier:tDetailReuseIdentifier forIndexPath:indexPath];
        [self setUpTweetDetailCell:detailCell];
        return detailCell;
    }else if (indexPath.section == 1) {
        if (_isShowCommentList) {
            TweetCommentNewCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:tCommentReuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < _tweetCommentList.count) {
                OSCComment *commentModel = _tweetCommentList[indexPath.row];
                [commentCell setCommentModel:commentModel];
            }
            return commentCell;
        }else {
            TweetLikeNewCell *likeCell = [self.tableView dequeueReusableCellWithIdentifier:tLikeReuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < _tweetLikeList.count) {
                OSCUser *likedUser = [_tweetLikeList objectAtIndex:indexPath.row];
                [likeCell.portraitIv loadPortrait:likedUser.portraitURL];
                likeCell.nameLabel.text = likedUser.name;
            }
            return likeCell;
        }
    }
    
    return [UITableViewCell new];
}


-(void)setUpTweetDetailCell:(TweetsDetailNewCell*)cell {
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_tweet) {
        [cell.portraitIv loadPortrait:_tweet.portraitURL];
        [cell.nameLabel setText:_tweet.author];
        
        [cell.portraitIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetails)]];
        [cell.likeTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeThisTweet)]];
        [cell.commentTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTweet)]];
        
        [cell.intervalTimeLabel setAttributedText:[Utils newTweetAttributedTimeString:_tweet.pubDate]];
        NSString *likeImgNameStr = _tweet.isLike?@"ic_thumbup_actived":@"ic_thumbup_normal";
        [cell.likeTagIv setImage:[UIImage imageNamed:likeImgNameStr]];
        
        [cell.platformLabel setAttributedText:[Utils newTweetGetAppclient:_tweet.appclient]];
        cell.contentWebView.delegate = self;
        [cell.contentWebView loadHTMLString:_tweet.body baseURL:[NSBundle mainBundle].resourceURL];
    }
}
-(void)pushUserDetails {
    NSLog(@"pushUserDetails");
}
-(void)likeThisTweet {
    NSLog(@"likeThisTweet");
}
-(void)commentTweet {
    NSLog(@"commentTweet");
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webViewHeight == webViewHeight) {return;}
    
    _webViewHeight = webViewHeight;
    [_HUD hide:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}
@end
