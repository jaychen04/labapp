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


static NSString *kCommentCellID = @"CommentCell";


@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (instancetype)initWithCommentsType:(CommentsType)type andID:(int64_t)objectID
{
    self = [super init];
    
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&id=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_COMMENTS_LIST, type, objectID, (unsigned long)page, OSCAPI_SUFFIX];
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
    
    UIMenuItem *menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyText:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:@[menuItemCopy]];
    [menuController setMenuVisible:YES animated:YES];
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

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(copyText:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
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
