//
//  OSCPrivateChatCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define SCREEN_PADDING_TOP 8//泡泡外边距
#define SCREEN_PADDING_BOTTOM SCREEN_PADDING_TOP
#define SCREEN_PADDING_LEFT 8
#define SCREEN_PADDING_RIGHT SCREEN_PADDING_LEFT

#define PRIVATE_POP_PADDING_TOP 15//泡泡内边距
#define PRIVATE_POP_PADDING_BOTTOM PRIVATE_POP_PADDING_TOP
#define PRIVATE_POP_PADDING_LEFT 15
#define PRIVATE_POP_PADDING_RIGHT PRIVATE_POP_PADDING_LEFT

#define PRIVATE_MAX_WIDTH ([UIScreen mainScreen].bounds.size.width * (0.6))
#define PRIVATE_FILE_TIP_W 200
#define PRIVATE_FILE_TIP_H 50

#define SELF_TEXT_COLOR [UIColor whiteColor]
#define OTHER_TEXT_COLOR [UIColor blackColor]
#define CHAT_TIME_COLOR [UIColor grayColor]

#define CHAT_TEXT_FONT_SIZE 14
#define CHAT_TIME_FONT_SIZE 12

@class OSCPrivateChatCell;
@protocol OSCPrivateChatCellDelegate <NSObject>

@optional
- (void)privateChatNodeTextViewDidClickText:(OSCPrivateChatCell* )privateChatCell;///< 点击了文本的cell

- (void)privateChatNodeImageViewDidClickImage:(OSCPrivateChatCell* )privateChatCell;///< 点击了图片的cell

- (void)privateChatNodeFileViewDidClickFile:(OSCPrivateChatCell *)privateChatCell;///< 点击了文件的cell

@end

@class OSCPrivateChat;
@interface OSCPrivateChatCell : UITableViewCell

+ (instancetype)returnReusePrivateChatCellWithTableView:(UITableView* )tableView
                                             identifier:(NSString* )identifier;

@property (nonatomic,strong) OSCPrivateChat* privateChat;

@property (nonatomic,weak) id<OSCPrivateChatCellDelegate> delegate;

@end
