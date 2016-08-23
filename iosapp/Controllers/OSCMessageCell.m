//
//  OSCMessageCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMessageCell.h"
#import "MessageItem.h"
#import "ImageDownloadHandle.h"

#import "UIImageView+CornerRadius.h"
#import "NSDate+Util.h"

#define OPERATION_BUTTON_W 200

@interface OSCMessageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userPortraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation OSCMessageCell{
    __weak UIButton* _deleteButton;
    __weak UIButton* _settingTopButton;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_userPortraitImageView zy_cornerRadiusRoundingRect];
}

+ (instancetype)returnReuseMessageCellWithTableView:(UITableView *)tableView
                                        identifier:(NSString *)reuseIdentifier
{
    OSCMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[OSCMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _openSlidingOperation = YES;
        
        [self addSubview:({//添加删除按钮到cell底部
            UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _deleteButton = deleteButton;
            [_deleteButton addTarget:self action:@selector(deleteOperation:) forControlEvents:UIControlEventTouchUpInside];
            [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
            [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_deleteButton setBackgroundColor:[UIColor redColor]];
            _deleteButton;
        })];
        [self addSubview:({//添加置顶按钮到cell底部
            UIButton* settingTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _settingTopButton = settingTopButton;
            [_settingTopButton addTarget:self action:@selector(setTopOperation:) forControlEvents:UIControlEventTouchUpInside];
            [_settingTopButton setTitle:@"置顶" forState:UIControlStateNormal];
            [_settingTopButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_settingTopButton setBackgroundColor:[UIColor orangeColor]];
            _settingTopButton;
        })];
        [self sendSubviewToBack:_deleteButton];
        [self sendSubviewToBack:_settingTopButton];
        
        UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(slidingDelete:)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:swipe];
    }
    return self;
}
#pragma mark --- Sliding Operation
- (void)slidingDelete:(UISwipeGestureRecognizer* )swipe{
    if (_openSlidingOperation) {
        [self.contentView setTransform:CGAffineTransformMakeTranslation(-(OPERATION_BUTTON_W * 2), 0)];
    }
}
- (void)_resetTranslation{
    [self.contentView setTransform:CGAffineTransformMakeTranslation(0, 0)];
}

#pragma mark --- set Model
- (void)setMessageItem:(MessageItem *)messageItem{
    _messageItem = messageItem;
    
    UIImage* portraitImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:messageItem.sender.portrait];
    if (!portraitImage) {
        [ImageDownloadHandle downloadImageWithUrlString:messageItem.sender.portrait SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [_userPortraitImageView setImage:portraitImage];
           });
        }];
    }else{
        [_userPortraitImageView setImage:portraitImage];
    }
    
    _userNameLabel.text = messageItem.sender.name;
    _timeLabel.text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:messageItem.pubDate] timeAgoSinceNow]]].string;
    _descLabel.text = messageItem.content;
}


#pragma mark --- layout
-(void)layoutSubviews{
    [super layoutSubviews];
    
    _settingTopButton.frame = (CGRect){{self.bounds.size.width - OPERATION_BUTTON_W * 2,0},{OPERATION_BUTTON_W,self.bounds.size.height}};
    _deleteButton.frame = (CGRect){{self.bounds.size.width - OPERATION_BUTTON_W,0},{OPERATION_BUTTON_W,self.bounds.size.height}};
}

#pragma mark --- operation Button Method
- (void)deleteOperation:(UIButton* )deleteBtn{
    [self _resetTranslation];
    if ([_delegate respondsToSelector:@selector(messageCellDidClickDelete:)]) {
        [_delegate messageCellDidClickDelete:self];
    }
}
- (void)setTopOperation:(UIButton* )setTopBtn{
    [self _resetTranslation];
    if ([_delegate respondsToSelector:@selector(messageCellDidClickSetTop:)]) {
        [_delegate messageCellDidClickSetTop:self];
    }
}

@end
