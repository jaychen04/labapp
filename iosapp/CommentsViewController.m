//
//  CommentsViewController.m
//  iosapp
//
//  Created by ChanAetern on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "OSCComment.h"


static NSString *kCommentCellID = @"CommentCell";


@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (instancetype)initWithCommentsType:(CommentsType)type andID:(int64_t)objectID
{
    self = [super init];
    
    if (self) {
        self.generateURL = ^(NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&id=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_COMMENTS_LIST, type, objectID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.parseXML = ^NSArray * (ONOXMLDocument *xml) {
            return [[xml.rootElement firstChildWithTag:@"comments"] childrenWithTag:@"comment"];
        };
        
        self.objClass = [OSCComment class];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:kCommentCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark -

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
    if (indexPath.section == 0 && self.otherSectionCell) {
        UITableViewCell *cell = self.otherSectionCell(indexPath);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.row < self.objects.count) {
        CommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCommentCellID forIndexPath:indexPath];
        OSCComment *comment = [self.objects objectAtIndex:indexPath.row];
        
        [cell.portrait sd_setImageWithURL:comment.portraitURL placeholderImage:nil options:0];
        [cell.contentLabel setText:comment.content];
        [cell.authorLabel setText:comment.author];
        [cell.timeLabel setText:[Utils intervalSinceNow:comment.pubDate]];
        
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
        OSCComment *comment = [self.objects objectAtIndex:indexPath.row];
        [self.label setText:comment.content];
        
        CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 52, MAXFLOAT)];
        
        return size.height + 64;
    } else {
        return 60;
    }
}





@end
