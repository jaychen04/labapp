//
//  OSCPrivateChatCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCPrivateChatCell;
@protocol OSCPrivateChatCellDelegate <NSObject>

@optional
- (void)privateChatNodeTextViewDidClickText:(OSCPrivateChatCell* )privateChatCell;///< 点击了文本的cell

- (void)privateChatNodeImageViewDidClickImage:(OSCPrivateChatCell* )privateChatCell;///< 点击了图片的cell

- (void)privateChatNodeFileViewDidClickImage:(OSCPrivateChatCell *)privateChatCell;///< 点击了文件的cell

@end

@class OSCPrivateChat;
@interface OSCPrivateChatCell : UITableViewCell

+ (instancetype)returnReusePrivateChatCellWithTableView:(UITableView* )tableView
                                             identifier:(NSString* )identifier;

@property (nonatomic,strong) OSCPrivateChat* privateChat;

@property (nonatomic,weak) id<OSCPrivateChatCellDelegate> delegate;

@end
