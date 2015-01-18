//
//  CommentsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "OSCComment.h"
#import "UserDetailsViewController.h"
#import "Config.h"
#import <MBProgressHUD.h>


static NSString *kCommentCellID = @"CommentCell";


@interface CommentsViewController ()

@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) CommentType commentType;

@end

@implementation CommentsViewController

- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID
{
    self = [super init];
    
    if (self) {
        _objectID = objectID;
        _commentType = commentType;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&id=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_COMMENTS_LIST, commentType, objectID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCComment class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"comments"] childrenWithTag:@"comment"];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:kCommentCellID];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:YES animated:YES];
    [menuController setMenuItems:@[
                                   [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyText:)],
                                   [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteComment:)]
                                   ]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.otherSectionCell) {
        return 1;
    } else {
        return self.objects.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (indexPath.section == 0 && self.otherSectionCell) {
        UITableViewCell *cell = self.otherSectionCell(indexPath);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (row < self.objects.count) {
        CommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCommentCellID forIndexPath:indexPath];
        OSCComment *comment = self.objects[row];
        
        [self setBlockForCommentCell:cell];
        [cell setContentWithComment:comment];
        
        cell.portrait.tag = row; cell.authorLabel.tag = row;
        [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
        [cell.authorLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
        
        return cell;
    } else {
        return self.lastCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.otherSectionCell) {
        return self.heightForOtherSectionCell(indexPath);
    } else if (indexPath.row < self.objects.count) {
        OSCComment *comment = self.objects[indexPath.row];
        [self.label setAttributedText:[Utils emojiStringFromRawString:comment.content]];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 52, MAXFLOAT)];
        
        return size.height + 64;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.otherSectionCell) {
        /* 不响应点击 */
    } else if (indexPath.row < self.objects.count) {
        OSCComment *comment = self.objects[indexPath.row];
        
        if (self.didCommentSelected) {
            self.didCommentSelected(comment.author);
        }
    } else {
        [self fetchMore];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// 参考 http://stackoverflow.com/questions/12290828/how-to-show-a-custom-uimenuitem-for-a-uitableviewcell

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
}

- (void)setBlockForCommentCell:(CommentCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteComment:)) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            
            OSCComment *comment = self.objects[indexPath.row];
            int64_t ownID = [Config getOwnID];
            
            return (comment.authorID == ownID || _objectAuthorID == ownID);
        }
        
        return NO;
    };
    
    cell.deleteComment = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCComment *comment = self.objects[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUDInWindowOfView:self.view];
        HUD.labelText = @"正在删除评论";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
        [manager POST:[NSString stringWithFormat:@"%@%@?", OSCAPI_PREFIX, OSCAPI_COMMENT_DELETE]
           parameters:@{
                        @"catalog": @(_commentType),
                        @"id": @(_objectID),
                        @"replyid": @(comment.commentID),
                        @"authorid": @(comment.authorID)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  switch (errorCode) {
                      case 1: {
                          HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                          HUD.labelText = @"评论删除成功";
                          
                          [self.objects removeObjectAtIndex:indexPath.row];
                          [self.tableView beginUpdates];
                          [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                          [self.tableView endUpdates];
                          
                          break;
                      }
                      case 0:
                      case -2:
                      case -1: {
                          HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                          HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                          break;
                      }
                      default: break;
                  }
                  
                  [HUD hide:YES afterDelay:2];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = @"网络异常，操作失败";
                  
                  [HUD hide:YES afterDelay:2];
              }];
    };
}



#pragma mark - scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.didScroll) {
        self.didScroll();
    }
}




#pragma mark - 跳转到用户详情页

- (void)pushDetailsView:(UITapGestureRecognizer *)tapGesture
{
    OSCComment *comment = self.objects[tapGesture.view.tag];
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:comment.authorID];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}



@end
