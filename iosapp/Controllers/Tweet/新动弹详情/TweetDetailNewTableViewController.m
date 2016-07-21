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
#import "UserDetailsViewController.h"
#import "ImageViewerController.h"
#import "UserDetailsViewController.h"
#import "Config.h"
#import "OSCUser.h"
#import "OSCTweet.h"
#import "OSCTweetItem.h"
#import "NSString+FontAwesome.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import <MJExtension.h>


#import "TweetsDetailNewCell.h"
#import "TweetLikeNewCell.h"
#import "TweetCommentNewCell.h"

static NSString * const tDetailReuseIdentifier = @"TweetsDetailTableViewCell";
static NSString * const tLikeReuseIdentifier = @"TweetLikeTableViewCell";
static NSString * const tCommentReuseIdentifier = @"TweetCommentTableViewCell";

@interface TweetDetailNewTableViewController ()<UIWebViewDelegate>
@property (nonatomic, strong)UIView *headerView;
@property (nonatomic)BOOL isShowCommentList;
@property (nonatomic, strong)NSMutableArray *tweetLikeList;
@property (nonatomic, strong)NSMutableArray *tweetCommentList;
@property (nonatomic)NSInteger likeListPage;
@property (nonatomic)NSInteger commentListPage;

@property (nonatomic, strong) UILabel *label;
//@property (nonatomic, strong) OSCTweet *tweet;
@property (nonatomic, strong) OSCTweetItem *tweetDetail;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) UITableViewCell *lastSelectedCell;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation TweetDetailNewTableViewController

- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:self.view.bounds];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    _hud = [[MBProgressHUD alloc] initWithWindow:window];
    _hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    [window addSubview:_hud];
    [self.tableView addSubview:coverView];
    [_hud showAnimated:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}
- (void)hideHubView {
    [_hud hideAnimated:YES];
    [[self.tableView viewWithTag:10] removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideHubView];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetsDetailNewCell" bundle:nil] forCellReuseIdentifier:tDetailReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetLikeNewCell" bundle:nil] forCellReuseIdentifier:tLikeReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCommentNewCell" bundle:nil] forCellReuseIdentifier:tCommentReuseIdentifier];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 250;
    
    _tweetLikeList = [NSMutableArray new];
    _tweetCommentList = [NSMutableArray new];
    _label = [[UILabel alloc]init];
    _label.numberOfLines = 0;
    
    _isShowCommentList = YES;       //默认展示评论列表
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadTweetLikeListIsrefresh:NO];
        [self loadTweetCommentListIsrefresh:NO];
    }];
    
    // 添加等待动画
    [self showHubView];
    
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
            BOOL isSelected = subBtn.tag==2;
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:likeBtnTitle isSelected:isSelected];
            [subBtn setAttributedTitle:att forState:UIControlStateNormal];
            
            [subBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat btnWidth = _headerView.bounds.size.width/2;
            subBtn.frame = (CGRect){{btnWidth*k,0},{btnWidth,40}};
            [_headerView addSubview:subBtn];
        }

    }else {
        if (_tweetDetail.likeCount > 0) {
            UIButton *likeBtn = [(UIButton*)_headerView viewWithTag:1];
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:[NSString stringWithFormat:@"赞 (%ld)", (long)_tweetDetail.likeCount] isSelected:!_isShowCommentList];
            [likeBtn setAttributedTitle:att forState:UIControlStateNormal];
        }
        if (_tweetDetail.commentCount > 0) {
            UIButton *commentBtn = [(UIButton*)_headerView viewWithTag:2];
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:[NSString stringWithFormat:@"评论 (%ld)", (long)_tweetDetail.commentCount] isSelected:_isShowCommentList];
            [commentBtn setAttributedTitle:att forState:UIControlStateNormal];
        }

    }
    
    return _headerView;
}

-(NSMutableAttributedString*)getSubBtnAttributedStringWithTitle:(NSString*)title isSelected:(BOOL)isSelected {
    NSMutableAttributedString* attributedStrNormal = [[NSMutableAttributedString alloc]initWithString:title];
    UIFont *font = [UIFont systemFontOfSize:15];
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
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_TWEET_DETAIL, _tweetID]
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
//             ONOXMLElement *tweetDetailsXML = [responseObject.rootElement firstChildWithTag:@"tweet"];
//             
//             if (!tweetDetailsXML || tweetDetailsXML.children.count <= 0) {
//                 [self.navigationController popViewControllerAnimated:YES];
//             } else {
//                 _tweet = [[OSCTweet alloc] initWithXML:tweetDetailsXML];
//                 NSDictionary *data = @{
//                                        @"content": _tweet.body,
//                                        @"imageURL": _tweet.bigImgURL.absoluteString,
//                                        @"audioURL": _tweet.attach ?: @""
//                                        };
//                 
//                 _tweet.body = [Utils HTMLWithData:data usingTemplate:@"newTweet"];
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.tableView reloadData];
//                 });
//             }
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             [_HUD hideAnimated:YES];
//         }];

    

//    self.tweetID = 9752556;
    NSString *tweetDetailUrlStr = [NSString stringWithFormat:@"%@tweet?id=%ld", OSCAPI_V2_PREFIX, (long)self.tweetID];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:tweetDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _tweetDetail = [OSCTweetItem mj_objectWithKeyValues:responseObject[@"result"]];
                OSCTweetImages* imageData = [_tweetDetail.images lastObject];
                
                NSDictionary *data;
                if (_tweetDetail.images.count) {
                    data = @{
                             @"content" : _tweetDetail.content,
//                             @"imageURL": [_tweetDetail.images[0] objectForKey:@"href"],
//                                       @"audioURL": _tweetDetail.audio ?: @""
                             };
                } else {
                    data = @{
                             @"content" : _tweetDetail.content,
//                                       @"audioURL": _tweetDetail.audio ?: @""
                             };
                }
                
                _tweetDetail.content = [Utils HTMLWithData:data usingTemplate:@"newTweet"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
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
                  _likeListPage++;
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
//发表评论后，为了更新总的评论数
-(void)reloadCommentList {
    _tweetDetail.commentCount++;
    [self loadTweetCommentListIsrefresh:YES];
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
                 _commentListPage++;
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
    HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
    [HUD hideAnimated:YES afterDelay:1];
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0:40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [tableView fd_heightForCellWithIdentifier:tDetailReuseIdentifier configuration:^(TweetsDetailNewCell *cell) {
        }] + _webViewHeight + 10;
    }else if (indexPath.section == 1) {
        if (!_isShowCommentList) {
            return 56;
        }else {
            return UITableViewAutomaticDimension;
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
                
                [self setBlockForCommentCell:commentCell];
                
                commentCell.commentTagIv.tag = indexPath.row;
                [commentCell.commentTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replyReviewer:)]];
                
                commentCell.portraitIv.tag = commentModel.authorID;
                [commentCell.portraitIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetails:)]];
            }
            return commentCell;
        }else {
            TweetLikeNewCell *likeCell = [self.tableView dequeueReusableCellWithIdentifier:tLikeReuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < _tweetLikeList.count) {
                OSCUser *likedUser = [_tweetLikeList objectAtIndex:indexPath.row];
                [likeCell.portraitIv loadPortrait:likedUser.portraitURL];
                likeCell.nameLabel.text = likedUser.name;
                
                likeCell.touchButton.tag = likedUser.userID;
                [likeCell.touchButton addTarget:self action:@selector(likedUserDetails:) forControlEvents:UIControlEventTouchUpInside];
            }
            return likeCell;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isShowCommentList) {
        OSCComment *comment = _tweetCommentList[indexPath.row];
        if (self.didCommentSelected) {
            self.didCommentSelected(comment);
        }
    }
//    else {
//        OSCUser *likedUser = _tweetLikeList[indexPath.row];
//        UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:likedUser.userID];
//        [self.navigationController pushViewController:userDetailsVC animated:YES];
//    }
}
#pragma mark -- Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    _lastSelectedCell.backgroundColor = [UIColor whiteColor];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor selectCellSColor];
    _lastSelectedCell = cell;
    
    return indexPath.section != 0;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
//    NSLog(@".....");
}

#pragma mark -- 设置动弹详情cell
-(void)setUpTweetDetailCell:(TweetsDetailNewCell*)cell {
    
    if (_tweetDetail) {
        [cell.portraitIv loadPortrait:[NSURL URLWithString:_tweetDetail.author.portrait]];
        [cell.nameLabel setText:_tweetDetail.author.name];
        
        cell.portraitIv.tag = _tweetDetail.author.id;
        [cell.portraitIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetails:)]];
        [cell.likeTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeThisTweet:)]];
        [cell.commentTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTweet)]];
        
        [cell.intervalTimeLabel setAttributedText:[Utils newTweetAttributedTimeString:[NSDate dateFromString:_tweetDetail.pubDate]]];
        NSString *likeImgNameStr = _tweetDetail.liked?@"ic_thumbup_actived":@"ic_thumbup_normal";
        [cell.likeTagIv setImage:[UIImage imageNamed:likeImgNameStr]];
        
        [cell.platformLabel setAttributedText:[Utils getAppclientName:(int)_tweetDetail.appClient]];
        cell.contentWebView.delegate = self;
        [cell.contentWebView loadHTMLString:_tweetDetail.content baseURL:[NSBundle mainBundle].resourceURL];
    }
}
#pragma  mark -- 用户详情界面
-(void)pushUserDetails:(UITapGestureRecognizer*)tap {
    [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithUserID:tap.view.tag] animated:YES];
}
- (void)likedUserDetails:(UIButton*)btn {
    [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithUserID:btn.tag] animated:YES];
}

-(void)likeThisTweet:(UITapGestureRecognizer*)tap {
    UIImageView *likeTagIv = (UIImageView*)tap.view;
    [self praiseTweetAndUpdateTagIv:likeTagIv];
}
-(void)commentTweet {
    if (self.didActivatedInputBar) {
        self.didActivatedInputBar();
    }
}
-(void)replyReviewer:(UITapGestureRecognizer*)tap {
    OSCComment *comment = _tweetCommentList[tap.view.tag];
    if (self.didCommentSelected) {
        self.didCommentSelected(comment);
    }
}
#pragma mark -- 点赞
- (void)praiseTweetAndUpdateTagIv:(UIImageView*)likeTagIv {
    if (_tweetDetail.id == 0) {
        return;
    }
    
    NSString *postUrl;
    if (_tweetDetail.liked) {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_UNLIKE];
    } else {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:postUrl
       parameters:@{
                    @"uid": @([Config getOwnID]),
                    @"tweetid": @(_tweetDetail.id),
                    @"ownerOfTweet": @( _tweetDetail.author.id)
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];

              if (errorCode == 1) {
                  if (_tweetDetail.liked) {
                      //取消点赞
                      _tweetDetail.likeCount--;
                      [likeTagIv setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
                      for (OSCUser *likeUser in _tweetLikeList) {
                          OSCUser *currentUser = [Config myProfile];
                          if (currentUser.userID == likeUser.userID) {
                              [_tweetLikeList removeObject:likeUser];
                              break;
                          }
                      }
                      _tweetDetail.liked = NO;
                  } else {
                      //点赞
                      _tweetDetail.likeCount++;
                      [likeTagIv setImage:[UIImage imageNamed:@"ic_thumbup_actived"]];
                      [_tweetLikeList insertObject:[Config myProfile] atIndex:0];
                      _tweetDetail.liked = YES;
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                  });
                  
              } else {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}

#pragma mark - scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && self.didScroll) {
        self.didScroll();
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webViewHeight == webViewHeight) {return;}
    
    _webViewHeight = webViewHeight;
    [_HUD hideAnimated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self hideHubView];
    });
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

#pragma mark -- 删除动弹
- (void)setBlockForCommentCell:(TweetCommentNewCell *)cell {
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            OSCComment *comment = self.tweetCommentList[indexPath.row];
            int64_t ownID = [Config getOwnID];
            return (comment.authorID == ownID || _tweetDetail.id == ownID);
        }
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCComment *comment = self.tweetCommentList[indexPath.row];
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"正在删除评论";
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        [manager POST:[NSString stringWithFormat:@"%@%@?", OSCAPI_PREFIX, OSCAPI_COMMENT_DELETE]
           parameters:@{
                        @"catalog": @(3),
                        @"id": @(_tweetDetail.id),
                        @"replyid": @(comment.commentID),
                        @"authorid": @(comment.authorID)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"评论删除成功";
                      
                      [self.tweetCommentList removeObjectAtIndex:indexPath.row];
//                      self.allCount--;
                      if (self.tweetCommentList.count > 0) {
                          [self.tableView beginUpdates];
                          [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                          [self.tableView endUpdates];
                      }
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  } else {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = @"网络异常，操作失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}
@end
